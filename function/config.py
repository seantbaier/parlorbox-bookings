from typing import Optional

from pydantic import BaseSettings


class Settings(BaseSettings):
    LOG_LEVEL: str = "info"
    HTTP_GRAPHQL_ENDPOINT: str = "http://localhost:4000"

    # AWS
    AWS_DEFAULT_REGION: str
    USER_POOL_ID: str

    # Localstack
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    ENDPOINT_URL: Optional[str] = None
    LOCALSTACK_API_KEY: Optional[str] = None
    ENV_NAME: str = "development"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
