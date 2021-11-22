from pprint import pprint
from typing import Any

from loguru import logger

from dataservices.post_confirmation_trigger.controller import (
    PostConfirmationTriggerController,
)
from dataservices.post_confirmation_trigger.event import CognitoTriggerEvent
from dataservices.post_confirmation_trigger.mock_event import mock_event_data
from dataservices.post_confirmation_trigger.service import PostConfirmationService


def local_setup(service: PostConfirmationService):
    cognito_user = service.create_cognito_user()
    mock_event = mock_event_data(cognito_user)
    return mock_event


def local_teardown(service: PostConfirmationService):
    service.delete_cognito_user()


def handler(event: CognitoTriggerEvent, context: Any):
    """The central handler function called when the Lambda function is invoked.
    Arguments:
        event {dict} -- Dictionary containing contents of the event that
        invoked the function, primarily the payload of data to be processed.
        context {LambdaContext} -- An object containing metadata describing
        the event source and client details.
    Returns:
        [string|dict] -- An output object that does not impact the effect of
        the function but which is reflected in CloudWatch
    """
    logger.info("Starting Lambda Execution")
    pprint(event)

    if not isinstance(event, CognitoTriggerEvent):
        event = CognitoTriggerEvent(**event)

    logger.debug(event)

    # Method to be invoked goes here
    logger.info("Successfully invoked lambda")

    controller = PostConfirmationTriggerController(event)
    controller.add_user_to_groups()

    # This return will be reflected in the CloudWatch logs
    # but doesn't actually do anything
    return event.dict()


if __name__ == "__main__":
    service = PostConfirmationService()
    mock_event = local_setup(service)
    logger.debug("Successfully setup local event")
    handler(mock_event, {})
    local_teardown(service)
