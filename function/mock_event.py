from function.config import settings


def mock_cognito_user():
    return {
        "UserPoolId": settings.USER_POOL_ID,
        "Username": settings.TEST_USER,
        "UserAttributes": [
            {"Name": "email", "Value": settings.TEST_USER},
            {"Name": "custom:userGroup", "Value": "seller"},
        ],
        "ValidationData": [
            {"Name": "string", "Value": "string"},
        ],
        "TemporaryPassword": settings.TEST_PASS,
        "ForceAliasCreation": True,
        "MessageAction": "SUPPRESS",
    }


def mock_event_data(user):
    print("user", user)

    attrs = user["UserAttributes"]
    user_attributes = {}

    for k, v in attrs.items():
        user_attributes[k] = v

    return {
        "is_local": True,
        "version": "1",
        "region": "us-east-1",
        "userPoolId": settings.USER_POOL_ID,
        "userName": "90d4d57f-9103-41bf-b946-d08a7e904d87",
        "callerContext": {
            "awsSdkVersion": "aws-sdk-unknown-unknown",
            "clientId": "",
        },
        "triggerSource": "PostConfirmation_ConfirmSignUp",
        "request": {"userAttributes": user["UserAttributes"]},
        "response": {},
    }
