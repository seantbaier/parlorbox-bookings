from datetime import datetime
from typing import Any

from function.event import CognitoTriggerEvent
from vendors import CognitoIdp, Dynamodb

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

    def add_user_to_groups(self) -> Any:
        client.admin_add_user_to_group(
            user_pool_id=self.user_pool_id,
            group_name=self.user_group,
            username=self.username,
        )

        return self.event

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

    def create_user_item(self):
        timestamp = datetime.now()

        seller = {
            "PK": f"SELLER#{self.username}",
            "SK": f"SELLER#{self.username}",
            "id": self.user_attributes["sub"],
            "email": self.user_attributes["email"],
            "firstName": "",
            "lastName": "",
            "projects": [],
            "tasks": [],
            "createdAt": timestamp,
            "updatedAt": timestamp,
        }

        response = dynamodb.putItem({"Item": seller})
        return response
