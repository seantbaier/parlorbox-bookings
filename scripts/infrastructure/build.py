from dotenv import load_dotenv
from loguru import logger

from scripts.infrastructure.client import get_client
from scripts.infrastructure.function import (
    create_function,
    get_function,
    invoke_function,
)

load_dotenv()

APP_NAME = "mangodeck"
ENV_NAME = "local"

LAMBDA_PORT = 4574


PREFIX = f"{ENV_NAME}-{APP_NAME}"
POST_CONFIRMATION_TRIGGER = f"{PREFIX}-post-confirmation-trigger"


def build():
    logger.info("Building localstack environemnt")
    client = get_client(resource="lambda", port=LAMBDA_PORT)

    function = get_function(client, POST_CONFIRMATION_TRIGGER)
    if not function:
        create_function(client, POST_CONFIRMATION_TRIGGER)

    invoke_function(client, POST_CONFIRMATION_TRIGGER)


if __name__ == "__main__":
    build()
