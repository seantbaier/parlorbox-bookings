from pprint import pprint
from typing import Any

from loguru import logger

from function.controller import (
    PostConfirmationTriggerController,
)
from function.event import CognitoTriggerEvent

from function.mock_event import mock_event_data
from function.service import (
    PostConfirmationService,
)


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

    controller = PostConfirmationTriggerController(event)
    controller.add_user_to_groups()

    return event.json()
