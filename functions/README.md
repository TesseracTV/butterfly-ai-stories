# Butterfly AI Stories — Lambda functions

Node.js 18+ (ES modules). Deploy to AWS Lambda and attach to API Gateway.

## Environment variables

| Function | Variable | Description |
|----------|----------|-------------|
| **deviceRegistration** | `USAGE_PLAN_ID` | API Gateway usage plan ID (optional; if set, new keys are associated). |
| **deviceRegistration** | `DEVICE_TABLE_NAME` | DynamoDB table name (default: `DeviceRegistry`). |
| **generateStory** | `OPENAI_SECRET_ARN` | Full ARN of the secret containing `openai-api-key` (optional; has default). |
| **generateStory** | `OPENAI_MODEL` | Model name (default: `gpt-4o-mini`). |
| **generateStory** | `OPENAI_MAX_TOKENS` | Max tokens (default: `500`). |

## IAM

- **deviceRegistration**: `dynamodb:GetItem`, `dynamodb:PutItem`, `apigateway:CreateApiKey`, `apigateway:CreateUsagePlanKey`.
- **generateStory**: `dynamodb:GetItem`, `secretsmanager:GetSecretValue`.
- **getApiKey**: `secretsmanager:GetSecretValue` (avoid exposing OpenAI key to clients; see deprecation note in code).

## CORS

All handlers return `Access-Control-Allow-Origin: *` and appropriate headers for browser clients. For production, restrict the origin to your app’s domain if needed.

## getApiKey

**Deprecated** for returning the OpenAI API key to the client. The iOS app uses **deviceRegistration** for a per-device key and **generateStory** uses the OpenAI key only server-side. Remove or repurpose **getApiKey** (e.g. for a non-sensitive config value) and never expose the OpenAI key to the client.
