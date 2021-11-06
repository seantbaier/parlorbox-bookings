from typing import Optional
import boto3
from loguru import logger


from dataservices.config import settings


def get_client(
    resource: str,
    port: Optional[int],
):
    try:

        if not settings.ENDPOINT_URL:
            return boto3.client(resource)

        return boto3.client(
            resource,
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            endpoint_url=f"{settings.ENDPOINT_URL}:{port}",
        )
    except Exception as e:
        logger.error(e)
        raise e


def get_resource(resource: str, endpoint_url: Optional[str] = None):
    if endpoint_url:
        return boto3.resource(resource, endpoint_url=endpoint_url)

    return boto3.resource(resource)
