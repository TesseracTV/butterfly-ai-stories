import { APIGateway } from '@aws-sdk/client-api-gateway';
import { DynamoDB } from '@aws-sdk/client-dynamodb';

const apigateway = new APIGateway();
const dynamodb = new DynamoDB();

const corsHeaders = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type',
};

export const handler = async (event) => {
  try {
    if (!event.body) {
      return { statusCode: 400, headers: corsHeaders, body: JSON.stringify({ error: 'Missing request body' }) };
    }

    const { device_id } = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    if (!device_id) {
      return { statusCode: 400, headers: corsHeaders, body: JSON.stringify({ error: 'Missing device_id' }) };
    }

    const existingDevice = await dynamodb.getItem({
      TableName: process.env.DEVICE_TABLE_NAME || 'DeviceRegistry',
      Key: { device_id: { S: device_id } },
    });

    let apiKey;

    if (existingDevice?.Item?.api_key?.S && existingDevice?.Item?.key_id?.S) {
      apiKey = { id: existingDevice.Item.key_id.S, value: existingDevice.Item.api_key.S };
    } else {
      const createKeyResponse = await apigateway.createApiKey({
        name: `device-${device_id}`,
        enabled: true,
        generateDistinctId: true,
      });

      const usagePlanId = process.env.USAGE_PLAN_ID;
      if (usagePlanId) {
        await apigateway.createUsagePlanKey({
          usagePlanId,
          keyId: createKeyResponse.id,
          keyType: 'API_KEY',
        });
      }

      await dynamodb.putItem({
        TableName: process.env.DEVICE_TABLE_NAME || 'DeviceRegistry',
        Item: {
          device_id: { S: device_id },
          api_key: { S: createKeyResponse.value },
          key_id: { S: createKeyResponse.id },
          created_at: { S: new Date().toISOString() },
          status: { S: 'active' },
        },
      });

      apiKey = { id: createKeyResponse.id, value: createKeyResponse.value };
    }

    if (!apiKey?.value) {
      throw new Error('Failed to create or retrieve API key');
    }

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify({ api_key: apiKey.value }),
    };
  } catch (error) {
    console.error('deviceRegistration error:', error.message);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        error: 'Failed to register device',
        details: error.message,
      }),
    };
  }
};
