from typing import Any
import httpx
import json

from function.event import CognitoTriggerEvent
from vendors import CognitoIdp, Dynamodb
from function.config import settings

client = CognitoIdp()
dynamodb = Dynamodb()


class PostConfirmationTriggerController:
    def __init__(self, event: CognitoTriggerEvent = None):
        if event:
            self.user_attributes: Any = event.request.userAttributes
            self.user_group: str = event.request.userAttributes.user_group
            self.user_pool_id: str = event.userPoolId
            self.username: str = event.userName
            self.event: CognitoTriggerEvent = event

    def create_cognito_user(self, user: dict) -> Any:
        response = client.admin_create_user(user)
        return response



    def get_cognito_user(self, username: str, user_pool_id: str):
        response = client.admin_get_user(
            username=username, user_pool_id=user_pool_id
        )
        return response

    def delete_cognito_user(self, username: str, user_pool_id: str):
        response = client.admin_delete_user(
            username=username, user_pool_id=user_pool_id
        )
        return response
