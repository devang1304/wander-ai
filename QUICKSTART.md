# QUICKSTART GUIDE

## 1. Prerequisites

Ensure you have the following files:

- `.env` in the project root with:
  ```
  OPENAI_API_KEY=sk-...
  ```

## 2. One-Time Setup

Initialize the remote state infrastructure (S3 + DynamoDB):

```bash
./terraform/setup_state.sh
```

## 3. Deploy Backend

Run the automated deployment script. This will use your key and deploy the serverless stack.

```bash
cd terraform
./deploy.sh
```

**After success, look for the "Key: TravelApi, Value: https://..." output.**
Copy that URL.

## 3. Configure Frontend

Create a file `frontend/.env`:

```bash
cd frontend
touch .env
```

Add the URL you copied:

```
VITE_API_URL=https://your-api-id.execute-api.us-east-1.amazonaws.com/Prod
```

## 4. Run Application

Start the frontend interface:

```bash
npm run dev
```

Open `http://localhost:5173` and start planning your trips!
