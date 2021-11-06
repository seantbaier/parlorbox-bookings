from dotenv import load_dotenv
from loguru import logger


from scripts.infrastructure.client import get_client
from scripts.infrastructure.function import get_function, delete_function

load_dotenv()

APP_NAME = "mangodeck"
REGION = "us-east-1"
ENV_NAME = "local"

LAMBDA_PORT = 4574
CLOUDWATCH_PORT = 4586


PREFIX = f"{ENV_NAME}-{APP_NAME}"
POST_CONFIRMATION_TRIGGER = f"{PREFIX}-post-confirmation-trigger"


def destroy():
    logger.info("Tearing down localstack environemnt")
    client = get_client(resource="lambda", port=LAMBDA_PORT)

    function = get_function(client, POST_CONFIRMATION_TRIGGER)
    if function:
        delete_function(client, POST_CONFIRMATION_TRIGGER)


if __name__ == "__main__":
    destroy()
