import sys
from loguru import logger


def handler(event, context):
    logger.info("testing")
    print("EVENT=", event)
    return "Hello from AWS Lambda using Python" + sys.version + "!"
