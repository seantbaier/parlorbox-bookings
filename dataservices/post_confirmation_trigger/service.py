from dataservices.post_confirmation_trigger.controller import (
    PostConfirmationTriggerController,
)
from dataservices.post_confirmation_trigger.event import CognitoTriggerEvent
from dataservices.post_confirmation_trigger.mock_event import mock_cognito_user

controller = PostConfirmationTriggerController()


class PostConfirmationService:
    def __init__(self, event: CognitoTriggerEvent = None):
        if event:
            self.event = event

    def setup_user_account(self):
        """
        1. Add Cognito user to UserGroup
        2. Create Seller | Virtual Assistant item in DynamoDB table
        3. Create Team item in DynamoDB table
        """
        return self.event

    def get_cognito_user(self, username: str, user_pool_id: str):
        user = controller.get_cognito_user(
            username=username, user_pool_id=user_pool_id
        )
        return user

    def create_cognito_user(self) -> CognitoTriggerEvent:
        user = mock_cognito_user()
        user = self.get_cognito_user(user["Username"], user["UserPoolId"])

        if not user:
            response = controller.create_cognito_user(user)
            user = self.get_cognito_user(
                response["userAttributes"]["Username"], response["UserPoolId"]
            )
        return user

    def delete_cognito_user(self) -> None:
        user = mock_cognito_user()
        user = self.get_cognito_user(user["Username"], user["UserPoolId"])

        if user:
            user = controller.delete_cognito_user(
                username=user["Username"], user_pool_id=user["UserPoolId"]
            )
        return None
