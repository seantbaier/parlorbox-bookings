from typing import Any, Dict, Optional

from pydantic import BaseModel


class CognitoUserAttributes(BaseModel):
    sub: str
    email_verified: bool
    email: str
    user_status: str
    email_alias: str
    user_group: str

    def __init__(self, **kwargs):
        normalized_kwargs = dict(**kwargs)

        if "cognito:user_status" in kwargs:
            normalized_kwargs["user_status"] = kwargs["cognito:user_status"]
            del normalized_kwargs["cognito:user_status"]

        if "cognito:email_alias" in kwargs:
            normalized_kwargs["email_alias"] = kwargs["cognito:email_alias"]
            del normalized_kwargs["cognito:email_alias"]

        if "custom:userGroup" in kwargs:
            normalized_kwargs["user_group"] = kwargs["custom:userGroup"]
            del normalized_kwargs["custom:userGroup"]

        super().__init__(**normalized_kwargs)


class CognitoEventRequest(BaseModel):
    userAttributes: CognitoUserAttributes


class CognitoTriggerEvent(BaseModel):
    is_local: Optional[bool] = False
    version: int
    region: str
    userPoolId: str
    userName: str
    callerContext: Dict[str, Any]
    triggerSource: str
    request: CognitoEventRequest
    response: Dict[str, Any]
