# Connect n8n to AURA

## Local n8n running directly on the same Windows host
HTTP Request node:
- Method: POST
- URL: http://127.0.0.1:8000/ask
- Send Body: JSON
- Body:
  {
    "question": "={{ $json.chatInput }}",
    "top_k": 5
  }

## n8n running inside Docker, FastAPI running on Windows
Use:
http://host.docker.internal:8000/ask

## n8n running on a different machine or hosted service
Use a reachable HTTPS URL for the FastAPI service. Do not expose port 8000 publicly without HTTPS and authentication.

## If AURA_API_KEY is configured
In the HTTP Request node add header:
- Name: X-API-Key
- Value: the same secret stored securely in n8n credentials.

## Basic node chain
Chat Trigger -> HTTP Request -> Respond to Chat

In the HTTP Request node configure:
- Method: POST
- URL: your reachable AURA /ask endpoint
- Body Content Type: JSON
- JSON body:
  {
    "question": "={{ $json.chatInput }}",
    "top_k": 5
  }

The exact input property can vary by trigger/version. Execute Chat Trigger once and inspect its output; replace `chatInput` with the actual user-message field. In the response node, return the HTTP Request result's `answer` field.

## Other endpoints
- GET /health
- POST /ingest
- POST /ask
- POST /analytics

Use /docs on the FastAPI server to test endpoints interactively.
