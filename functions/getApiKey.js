/**
 * DEPRECATED: Do not use this to expose the OpenAI API key to clients.
 * The iOS app uses deviceRegistration to get a per-device API key, and generateStory
 * fetches the OpenAI key server-side from Secrets Manager.
 *
 * If you need a different secret (e.g. a public config key), use a dedicated secret
 * and never return long-lived or high-privilege keys to the client.
 */
import { SecretsManager } from '@aws-sdk/client-secrets-manager';

const secretsManager = new SecretsManager({ region: process.env.AWS_REGION || 'us-east-2' });

const corsHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': '*',
};

export const handler = async (event) => {
  try {
    const secretId = process.env.SECRET_ID || 'openai_api_key';
    const data = await secretsManager.getSecretValue({ SecretId: secretId });

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({
        apiKey: data.SecretString,
      }),
    };
  } catch (error) {
    console.error('getApiKey error:', error.message);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        error: 'Failed to retrieve secret',
        details: error.message,
      }),
    };
  }
};
