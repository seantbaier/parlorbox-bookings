import httpx
import json
import boto3
from botocore.config import Config
from loguru import logger


from function.config import settings
from function.queries import SELLER_QUERY


config = Config(
    region_name="us-east-1",
    signature_version="v4",
    retries={"max_attempts": 10, "mode": "standard"},
)

client = boto3.client("cognito-idp", config=config)


def add_user_to_group(user_pool_id: str, username: str, group_name: str):
    try:
        response = client.admin_add_user_to_group(
            UserPoolId=user_pool_id,
            Username=username,
            GroupName=group_name,
        )
        logger.success(f"username={username}, group={group_name}")
        return response
    except Exception as e:
        logger.error(
            f"username={username}, userpool={user_pool_id}, group={group_name}"
        )
        logger.error(e)


def create_user_item(username: str, email: str):
    query = {
        "query": SELLER_QUERY,
        "variables": {
            "createSellerId": username,
            "email": email,
        },
    }

    try:
        url = settings.HTTP_GRAPHQL_ENDPOINT
        logger.info(f"HTTP_GRAPHQL_ENDPOINT={url}")
        r = httpx.post(url=url, json=query)
        if r.status_code == 200:
            logger.success(
                f"Successfully created username={username}, email={email}"
            )
            print(json.dumps(r.json(), indent=2))
            return r.json()
    except Exception as e:
        logger.error(e)
        raise e


def handler(event: dict, context: dict):
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
    print(event)

    username = event["userName"]
    user_pool_id = event["userPoolId"]
    request = event["request"]

    user_attributes = request["userAttributes"]
    group_name = user_attributes["custom:userGroup"]
    email = user_attributes["email"]

    add_user_to_group(
        user_pool_id=user_pool_id, username=username, group_name=group_name
    )
    create_user_item(username=username, email=email)

    return event
