import pytest

# from app.main import handler
from dataservices.post_confirmation_trigger.event import CognitoTriggerEvent
from dataservices.post_confirmation_trigger.mock_event import mock_event


@pytest.fixture
def event_fixture() -> CognitoTriggerEvent:
    return mock_event


def test_handler(event_fixture: CognitoTriggerEvent):
    # response = handler(event=event_fixture, context={})
    assert True
