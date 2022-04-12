from function.data_sources.dynamodb import DynamoDBDataSource
from uuid import uuid4
from pydantic import EmailStr, UUID4
from boto3.dynamodb.conditions import Key, Attr
from dataclasses import asdict
from botocore.exceptions import ClientError


from function.schemas import Merchant, MerchantCreate, Status
from .table_schema import table_key_schema

APP_NAME = "parlorbox"
ENV = "development"


def success(response: dict) -> bool:
    return response["ResponseMetadata"]["HTTPStatusCode"] == 200


class ItemNotFoundError(ClientError):
    def __init__(self, operation: str, message: str = "Item Not Found"):
        error_response = {"Error": {"Message": message, "Code": 404}}
        super().__init__(operation_name=operation, error_response=error_response)


class MerchantNotCreatedError(ClientError):
    def __init__(self, operation: str, message: str = "Failed to create Merchant"):
        # TODO temp making this 500
        error_response = {"Error": {"Message": message, "Code": 500}}
        super().__init__(operation_name=operation, error_response=error_response)


class MerchantDataSource(DynamoDBDataSource):
    ttl: int = 30 * 60
    resource: str = "merchant"

    def __init__(self, client):
        table_name = f"{self.resource.capitalize()}-{APP_NAME}-{ENV}"
        super().__init__(table_name=table_name, client=client, table_key_schema=table_key_schema)

    def _pk(self, id: UUID4) -> str:
        return f"{self.resource.upper()}#{id}"

    def _sk(self, id: UUID4) -> str:
        return f"{self.resource.upper()}#{id}"

    def _gsi_pk(self, email: EmailStr) -> str:
        return f"{self.resource.upper()}#{email}"

    def _create_get_item_input(self, id: UUID4) -> dict:
        return {"Key": {"PK": self._pk(id), "SK": self._sk(id)}}

    def _create_merchant_item_input(self, merchant: dict) -> dict:
        email = merchant["email"]

        obj = MerchantCreate(
            PK=self._pk(email),
            SK=self._sk(email),
            GSIPK=self._gsi_pk(email),
            id=uuid4(),
            first_name=merchant.get("first_name", None),
            last_name=merchant.get("last_name", None),
            email=EmailStr(merchant.get("email")),
            waitlist=[],
            status=Status("active"),
        )
        return {"Item": asdict(obj)}

    def _create_delete_item_input(self, id: UUID4) -> dict:
        return {"PK": self._pk(id), "SK": self._sk(id)}

    def get_merchant(self, id: UUID4) -> Merchant:
        input = self._create_get_item_input(id)
        response = self.get_item(input, self.ttl)

        if success(response) and "Item" not in response:
            raise ItemNotFoundError(
                operation="GET_ITEM",
                message=f"Item Not Found PK={input['Key']['PK']}",
            )
        return Merchant(**response["Item"])

    def create_merchant(self, merchant: dict) -> Merchant:
        item = self._create_merchant_item_input(merchant=merchant)
        response = self.put_item(item)
        if not success(response):
            raise MerchantNotCreatedError(operation="PUT_ITEM", message="Failed to create Merchant")
        return Merchant(**item["Item"])

    def delete_merchant(self, id: UUID4) -> Merchant:
        item = self._create_delete_item_input(id)
        return self.delete_item(item)

    def get_merchant_by_email(self, id: UUID4, email: EmailStr) -> Merchant:
        input = {"KeyConditionExpression": Key("PK").eq(self._pk(id)), "FilterExpression": Attr("email").eq(email)}
        response = self.query(input)

        if success(response) and "Item" not in response:
            raise ItemNotFoundError(
                operation="GET_ITEM",
                message=f"Item Not Found PK={input['Key']['PK']}",
            )
        return Merchant(**response["Items"][0])
