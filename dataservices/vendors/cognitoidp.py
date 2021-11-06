import boto3
from botocore.config import Config
from loguru import logger
from pprint import pprint

config = Config(
    region_name="us-east-1",
    signature_version="v4",
    retries={"max_attempts": 10, "mode": "standard"},
)


class CognitoIdp:
    def __init__(self):
        self.client = boto3.client("cognito-idp", config=config)

    def admin_add_user_to_group(self, user_pool_id, username, group_name):
        try:
            response = self.client.admin_add_user_to_group(
                UserPoolId=user_pool_id, Username=username, GroupName=group_name
            )
            logger.success(f"username={username}, group={group_name}")
            return response
        except Exception as e:
            logger.error(
                f"username={username}, userpool={user_pool_id}, group={group_name}"
            )
            logger.error(e)

    def admin_create_user(self, user):
        try:
            return self.client.admin_create_user(**user)
        except Exception as e:
            logger.error(e)
            raise e

    def admin_delete_user(self, username: str, user_pool_id: str):
        try:
            response = self.client.admin_delete_user(
                Username=username, UserPoolId=user_pool_id
            )
            return response
        except Exception as e:
            logger.error(e)
            raise e

    def admin_get_user(self, username: str, user_pool_id: str):
        try:
            response = self.client.admin_get_user(
                Username=username, UserPoolId=user_pool_id
            )
            print("USER\n", response)
            return response
        except Exception as e:
            logger.error(e)
            raise e
