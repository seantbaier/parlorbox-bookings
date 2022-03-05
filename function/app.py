import sys
from loguru import logger
from pprint import pprint


def handler(event, context):
    pprint(event)
    logger.info(f"Hello from AWS Lambda using Python {sys.version}!")
