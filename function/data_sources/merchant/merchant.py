from function.data_sources.dynamodb import DynamoDBDataSource
from uuid import uuid4
from pydantic import EmailStr, UUID4
from boto3.dynamodb.conditions import Key, Attr
from dataclasses import asdict
from botocore.exceptions import ClientError


from function.schemas import Merchant, MerchantCreate
from .table_schema import table_key_schema

APP_NAME = "parlorbox"
ENV = "development"


def success(response: dict) -> bool:
    return response["ResponseMetadata"]["HTTPStatusCode"] == 200


class ItemNotFoundError(ClientError):
    def __init__(self, operation: str, message: str = "Item Not Found"):
        error_response = {"Error": {"Message": message, "Code": 404}}
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

    def _create_get_item_input(self, id: str) -> dict:
        return {"Key": {"PK": self._pk(id), "SK": self._sk(id)}}

    def _create_merchant_item_input(self, merchant: dict) -> dict:
        id = str(uuid4())

        obj = MerchantCreate(
            PK=self._pk(id),
            SK=self._sk(id),
            GSIPK=self._gsi_pk(merchant.get("email", None)),
            id=id,
            first_name=merchant.get("first_name", None),
            last_name=merchant.get("last_name", None),
            email=merchant.get("email"),
            waitlist=[],
            status="active",
        )
        return {"Item": asdict(obj)}

    def _create_delete_item_input(self, id: UUID4) -> dict:
        return {"PK": self._pk(id), "SK": self._sk(id)}

    def get_merchant(self, id: EmailStr) -> Merchant:
        input = self._create_get_item_input(id)
        response = self.get_item(input, self.ttl)

        if success(response):
            if "Item" not in response:
                raise ItemNotFoundError(
                    operation="GET_ITEM",
                    message=f"Item Not Found PK={input['Key']['PK']}",
                )
            return Merchant(**response["Item"])

    def create_merchant(self, merchant: dict) -> Merchant:
        item = self._create_merchant_item_input(merchant=merchant)
        response = self.put_item(item)
        if success(response):
            return Merchant(**item["Item"])

    def delete_merchant(self, id: UUID4) -> Merchant:
        item = self._create_delete_item_input(id)
        return self.delete_item(item)

    def get_merchant_by_email(self, id: UUID4, email: EmailStr) -> Merchant:
        input = {"KeyConditionExpression": Key("PK").eq(self._pk(id)), "FilterExpression": Attr("email").eq(email)}
        response = self.query(input)
        if success(response):
            return Merchant(**response["Items"][0])
