import re
import httpx
from sentence_transformers import SentenceTransformer
from supabase import create_client, Client

from .config import settings

# Same model and vector dimension must be used for ingest and search.
embedding_model = SentenceTransformer(settings.embedding_model)
supabase: Client = create_client(settings.supabase_url, settings.supabase_key)


def embed_text(text: str) -> list[float]:
    vector = embedding_model.encode(text, normalize_embeddings=True)
    return vector.tolist()


def split_text(text: str, chunk_size: int = 900, overlap: int = 120) -> list[str]:
    # Character-based chunking is intentionally simple for the MVP.
    text = re.sub(r"\s+", " ", text).strip()
    if not text:
        return []
    chunks = []
    start = 0
    while start < len(text):
        end = min(start + chunk_size, len(text))
        chunks.append(text[start:end])
        if end == len(text):
            break
        start = max(end - overlap, start + 1)
    return chunks


async def ask_openrouter(system_prompt: str, user_prompt: str) -> str:
    url = "https://openrouter.ai/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {settings.openrouter_api_key}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": settings.openrouter_model,
        "temperature": 0.1,
        "max_tokens": 1600,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
    }
    async with httpx.AsyncClient(timeout=90) as client:
        response = await client.post(url, headers=headers, json=payload)
        response.raise_for_status()
        data = response.json()
    return data["choices"][0]["message"]["content"]
