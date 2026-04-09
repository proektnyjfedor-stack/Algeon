from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional


class Settings(BaseSettings):
    deepseek_api_key: Optional[str] = None
    anthropic_api_key: Optional[str] = None
    app_env: str = "development"
    app_debug: bool = True
    allowed_origins: str = "http://localhost:3000,http://localhost:8080"
    rate_limit_per_minute: int = 20
    max_message_length: int = 1000

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def origins_list(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",")]


settings = Settings()