# WanderAI ✈️

**Your Intelligent Travel Companion** - An AI-powered serverless travel planning application built with AWS, OpenAI, React, and Terraform.

![Architecture](https://img.shields.io/badge/AWS-Lambda%20%7C%20API%20Gateway%20%7C%20DynamoDB-orange)
![Frontend](https://img.shields.io/badge/Frontend-React%20%7C%20TypeScript%20%7C%20Vite-blue)
![IaC](https://img.shields.io/badge/IaC-Terraform-purple)

## Overview

WanderAI uses a multi-agent architecture to help you plan trips:

- **Research Agent**: Gathers information about destinations
- **Planning Agent**: Creates detailed itineraries with cost estimates

## Tech Stack

### Backend (AWS Serverless)

- **Compute**: AWS Lambda (Python 3.9, ARM64)
- **API**: API Gateway REST API
- **Storage**: DynamoDB
- **AI**: OpenAI GPT-4o
- **IaC**: Terraform

### Frontend

- **Framework**: React 19 + TypeScript
- **Build Tool**: Vite 7
- **Styling**: TailwindCSS 3
- **Icons**: Lucide React

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Node.js](https://nodejs.org/) >= 18
- AWS CLI configured with credentials
- OpenAI API key

### 1. Clone and Setup

```bash
git clone https://github.com/devang1304/wander-ai.git
cd wander-ai

# Create environment file
cp .env.example .env
# Edit .env and add your OPENAI_API_KEY
```

### 2. One-Time Setup (Remote State)

Initialize the remote backend for Terraform:

```bash
./terraform/setup_state.sh
```

### 3. Deploy Backend Infrastructure

```bash
cd terraform
./deploy.sh
```

This will:

- ✅ Initialize Terraform with Remote State
- ✅ Deploy Lambda functions, API Gateway, and DynamoDB
- ✅ Auto-configure frontend with API endpoint

### 3. Run Frontend

```bash
cd ../frontend
npm install
npm run dev
```

Open http://localhost:5173 and start planning trips!

## Project Structure

```
wander-ai/
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # Lambda, DynamoDB, IAM
│   ├── api_gateway.tf     # API Gateway configuration
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Output values
│   └── deploy.sh          # Automated deployment
├── backend/
│   └── src/
│       ├── agents/
│       │   ├── research_agent.py
│       │   └── planning_agent.py
│       └── requirements.txt
└── frontend/
    ├── src/
    │   ├── App.tsx
    │   └── main.tsx
    └── package.json
```

## Commands

### Deployment

```bash
cd terraform
./deploy.sh              # Deploy infrastructure
./destroy.sh             # Tear down infrastructure
terraform output -raw api_endpoint  # Get API URL
```

### Development

```bash
cd frontend
npm run dev              # Start dev server
npm run build            # Production build
npm run preview          # Preview production build
```

### Testing

```bash
# Test Lambda functions locally
python test_local.py
```

## Infrastructure

The Terraform configuration creates:

| Resource                       | Description                     |
| ------------------------------ | ------------------------------- |
| `aws_lambda_function` × 2      | Research and Planning agents    |
| `aws_api_gateway_rest_api`     | REST API with CORS              |
| `aws_dynamodb_table`           | Travel itinerary storage        |
| `aws_iam_role`                 | Lambda execution role           |
| `aws_cloudwatch_log_group` × 2 | Function logs (7-day retention) |

**Cost Estimate**: ~$0.50/month for light usage (AWS Free Tier eligible)

## Environment Variables

### Backend (via Terraform)

- `OPENAI_API_KEY` - OpenAI API key (**required**)
- `TABLE_NAME` - DynamoDB table name

### Frontend

- `VITE_API_URL` - API Gateway endpoint (auto-configured)

## Features

- ✅ Serverless AWS architecture
- ✅ Multi-agent AI orchestration
- ✅ Real-time trip planning
- ✅ Cost estimation
- ✅ Clean, responsive UI
- ✅ Infrastructure as Code with Terraform
- ✅ Automated deployment

## Roadmap

- [ ] Add authentication (Cognito)
- [ ] Save itineraries to DynamoDB
- [ ] Export to PDF/Calendar
- [ ] Multi-destination trips
- [ ] Real-time flight/hotel search integration

## License

MIT

---

**Built with ❤️ using AWS Serverless, React, and Terraform**
