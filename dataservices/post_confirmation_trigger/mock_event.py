from dataservices.config import settings


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

    # temp = {
    #     "sub": attrs["sub"],
    #     "cognito:email_alias": "sean.t.baier@gmail.com",
    #     "email_verified": "true",
    #     "cognito:user_status": "CONFIRMED",
    #     "email": "sean.t.baier@gmail.com",
    #     "custom:userGroup": "virtualAssistants",
    # }

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


# user = cognito_user()
# mock_event = CognitoTriggerEvent(**mock_event_data(user))


#  {
#      'Username': '567af19a-499b-45b5-a8dc-015146453eb1',
#      'UserAttributes': [
#          {'Name': 'sub', 'Value': '567af19a-499b-45b5-a8dc-015146453eb1'},
#          {'Name': 'email', 'Value': 'sean.t.baier+test@gmail.com'},
#          {'Name': 'custom:userGroup', 'Value': 'seller'}
#     ],
#     'UserCreateDate': datetime.datetime(2021, 11, 1, 8, 24, 18, 176000, tzinfo=tzlocal()),
#     'UserLastModifiedDate': datetime.datetime(2021, 11, 1, 8, 24, 18, 176000, tzinfo=tzlocal()),
#     'Enabled': True,
#     'UserStatus': 'FORCE_CHANGE_PASSWORD',
#     'ResponseMetadata': {
#         'RequestId': '87b4a17d-9c4c-4440-8b5b-21eb0cc4a20a',
#         'HTTPStatusCode': 200,
#         'HTTPHeaders': {
#             'date': 'Mon, 01 Nov 2021 14:30:59 GMT',
#             'content-type': 'application/x-amz-json-1.1',
#             'content-length': '358',
#             'connection': 'keep-alive',
#             'x-amzn-requestid': '87b4a17d-9c4c-4440-8b5b-21eb0cc4a20a'
#         }, 'RetryAttempts': 0
#     }
# }
