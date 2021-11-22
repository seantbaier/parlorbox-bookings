import boto3
from dotenv import load_dotenv
from loguru import logger

load_dotenv()

APP_NAME = "mangodeck"
REGION = "us-east-1"
ENV_NAME = "local"

LAMBDA_PORT = 4574
S3_PORT = 4572
API_GATEWAY_PORT = 4567
DYNAMODB_PORT = 4569
CLOUDWATCH_PORT = 4586


PREFIX = f"{ENV_NAME}-{APP_NAME}"
HTTP_HANDLER = f"{PREFIX}-httpHandler"
POST_CONFIRMATION_TRIGGER = f"{PREFIX}-post-confirmation-trigger"
REST_API_GATEWAY = f"{PREFIX}-rest-api"


def get_client(port: int, resource: str):
    try:
        client = boto3.client(
            resource,
            aws_access_key_id="",
            aws_secret_access_key="",
            endpoint_url=f"http://localhost:{port}",
        )
        return client
    except Exception as e:
        logger.error(e)
