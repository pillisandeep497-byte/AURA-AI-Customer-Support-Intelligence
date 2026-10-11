from pydantic import BaseModel, Field
from typing import Any


class IngestRequest(BaseModel):
    source_id: str = Field(min_length=1, max_length=200)
    title: str = Field(min_length=1, max_length=500)
    content: str = Field(min_length=1)
    source_type: str = "policy"
    version: str = "1"
    product: str | None = None
    metadata: dict[str, Any] = Field(default_factory=dict)


class AskRequest(BaseModel):
    question: str = Field(min_length=1, max_length=8000)
    product_filter: str | None = None
    top_k: int | None = Field(default=None, ge=1, le=10)


class AnalyticsRequest(BaseModel):
    start_date: str  # ISO date, e.g. 2026-09-01
    end_date: str    # ISO date, exclusive boundary
    product_filter: str | None = None
