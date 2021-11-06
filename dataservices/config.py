from typing import Optional

from pydantic import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "mangodeck"
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
    TEST_USER: Optional[str] = None
    TEST_PASS: Optional[str] = None

    LAMBDA_PORT: Optional[int] = 4574
    S3_PORT: Optional[int] = 4572
    API_GATEWAY_PORT: Optional[int] = 4567
    DYNAMODB_PORT: Optional[int] = 4569
    CLOUDWATCH_PORT: Optional[int] = 4586

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
