from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    supabase_url: str
    supabase_key: str
    openrouter_api_key: str
    openrouter_model: str = "openai/gpt-oss-20b"
    aura_api_key: str = ""
    embedding_model: str = "BAAI/bge-small-en-v1.5"
    top_k: int = 5

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
