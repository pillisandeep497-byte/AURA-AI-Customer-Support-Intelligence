# AURA — AI Customer Support Intelligence

**A Retrieval-Augmented Generation (RAG) system for intelligent, document-grounded customer support.**

AURA is an AI-powered customer support project designed to help users find relevant information from support policies and documentation. It combines semantic document retrieval, large language models, API integration, and workflow automation.

## 🎯 Problem Statement

Customer support teams often spend time searching through policy documents and answering repetitive questions. When information is scattered across multiple documents, responses can become slow, inconsistent, or unsupported by the available evidence.

## 💡 Solution

AURA provides a document-based question-answering system that retrieves relevant information and uses an AI model to generate a contextual response. A FastAPI backend exposes the system through REST endpoints, while n8n connects the backend to chat and automation workflows.

## ✨ Features

- **RAG pipeline:** Answers questions using retrieved document context.
- **Semantic search:** Finds relevant document chunks using embeddings.
- **AI-powered responses:** Uses OpenRouter to access a configurable language model.
- **FastAPI backend:** Provides endpoints for ingestion, question answering, and analytics.
- **Supabase integration:** Stores document chunks and supports vector retrieval.
- **n8n automation:** Connects the backend to chat-based workflows.
- **API-key protection:** Supports an optional API key for protected endpoints.

## 🏗️ Architecture

```text
User Question
     |
     v
n8n Chat Workflow
     |
     v
FastAPI Backend
     |
     v
Supabase Vector Search
     |
     v
Relevant Document Context
     |
     v
OpenRouter LLM
     |
     v
Contextual Support Answer
     |
     v
n8n Chat Response
```

## 🛠️ Tech Stack

- Python
- FastAPI
- LangChain ecosystem / document-processing components
- Supabase PostgreSQL and pgvector
- Sentence Transformers embeddings
- OpenRouter API
- n8n workflow automation

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/AURA-AI-Customer-Support-Intelligence.git
cd AURA-AI-Customer-Support-Intelligence
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Create a virtual environment

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

### 3. Install dependencies

```bash
pip install -r requirements.txt
```

### 4. Configure environment variables

Copy `.env.example` to `.env` and provide your own Supabase and OpenRouter credentials.

```dotenv
SUPABASE_URL=your_supabase_project_url
SUPABASE_KEY=your_server_side_key
OPENROUTER_API_KEY=your_openrouter_api_key
OPENROUTER_MODEL=openai/gpt-oss-20b
AURA_API_KEY=your_private_api_key
EMBEDDING_MODEL=BAAI/bge-small-en-v1.5
TOP_K=5
```

Never commit `.env` or publish API keys.

### 5. Set up the database

Run the SQL statements in `database/schema.sql` using the Supabase SQL Editor.

### 6. Start the API

```bash
uvicorn aura.main:app --reload --host 0.0.0.0 --port 8000
```

Open the interactive API documentation:

http://127.0.0.1:8000/docs

### 7. Connect n8n

Create a chat workflow with these nodes:

1. When Chat Message Received
2. HTTP Request — POST to `/ask`
3. Edit Fields — format the answer
4. Respond to Chat

Configure the request body according to the API schema and add the `X-API-Key` header if authentication is enabled.

## 🔌 API Endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Health check |
| POST | `/ingest` | Process and store a document |
| POST | `/ask` | Ask a question using RAG |
| POST | `/analytics` | Retrieve supported ticket analytics |

Refer to `/docs` for the exact request and response schemas.

## 🧪 Example Use Case

**Question:** What is the refund time window for Product A?

**Document evidence:** Customers may request a refund within 30 days of purchase if the item satisfies the return conditions.

**Expected behavior:** AURA retrieves the relevant policy and generates an answer based on the available evidence.

## 🔒 Security

- Keep API keys in environment variables.
- Never expose server-side Supabase credentials in frontend code.
- Configure database access policies and least-privilege permissions before production deployment.
- Validate model responses and retrieved sources before using them for important customer decisions.

## 🗺️ Future Improvements

- Automated support-ticket ingestion
- Stronger evidence verification and hallucination checks
- Human approval for sensitive support actions
- Customer complaint analytics and dashboards
- Feedback collection and evaluation metrics
- Production deployment, monitoring, and authentication

## 📌 Project Status

**Prototype / MVP.** The core API and n8n integration are intended for experimentation and learning. Production readiness, security hardening, comprehensive evaluation, and end-to-end testing remain necessary.

## 👨‍💻 Author

**Sandeep Pilli**

AI & ML Diploma Student | Aspiring AI Automation Engineer

Building practical AI applications using Python, RAG, APIs, and workflow automation.

