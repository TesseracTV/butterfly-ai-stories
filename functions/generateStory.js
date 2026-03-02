import { SecretsManager } from '@aws-sdk/client-secrets-manager';
import { DynamoDB } from '@aws-sdk/client-dynamodb';
import OpenAI from 'openai';

const dynamodb = new DynamoDB();

const corsHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type,x-api-key',
};

export const handler = async (event) => {
  try {
    if (!event.body) {
      return { statusCode: 400, headers: corsHeaders, body: JSON.stringify({ message: 'No body in request' }) };
    }

    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    const { image, prompt, device_id } = body;

    if (!image || !prompt || !device_id) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({ message: 'Missing required fields: image, prompt, or device_id' }),
      };
    }

    const apiKey = event.headers?.['x-api-key'] ?? event.headers?.['X-Api-Key'];
    if (!apiKey) {
      return { statusCode: 403, headers: corsHeaders, body: JSON.stringify({ message: 'API key required' }) };
    }

    const deviceRecord = await dynamodb.getItem({
      TableName: 'DeviceRegistry',
      Key: { device_id: { S: device_id } },
    });

    if (!deviceRecord?.Item || deviceRecord.Item.api_key?.S !== apiKey) {
      return { statusCode: 403, headers: corsHeaders, body: JSON.stringify({ message: 'Invalid API key' }) };
    }

    const secretsManager = new SecretsManager({ region: process.env.AWS_REGION || 'us-east-2' });
    const data = await secretsManager.getSecretValue({
      SecretId: process.env.OPENAI_SECRET_ARN || 'arn:aws:secretsmanager:us-east-2:976193230293:secret:openai_api_key-Tg3zFm',
    });
    const secret = JSON.parse(data.SecretString);
    const openaiApiKey = secret['openai-api-key'];

    const openai = new OpenAI({ apiKey: openaiApiKey });

    const response = await openai.chat.completions.create({
      model: process.env.OPENAI_MODEL || 'gpt-4o-mini',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: prompt },
            { type: 'image_url', image_url: { url: image } },
          ],
        },
      ],
      max_tokens: parseInt(process.env.OPENAI_MAX_TOKENS, 10) || 500,
    });

    const tokensUsed = response.usage?.total_tokens ?? 0;

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        story: response.choices[0]?.message?.content ?? '',
        tokens_used: tokensUsed,
      }),
    };
  } catch (error) {
    console.error('generateStory error:', error.message);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        error: error.message,
        type: error.name,
      }),
    };
  }
};
