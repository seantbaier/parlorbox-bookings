from function.data_sources.dynamodb import DynamoDB
from uuid import uuid4


from function.schemas import Merchant
from .table_schema import table_key_schema

APP_NAME = "parlorbox"
ENV = "development"


class MerchantProvider(DynamoDB):
    ttl: int = 30 * 60
    resource: str = "merchant"

    def __init__(self, client):
        table_name = f"{self.resource.capitalize()}-{APP_NAME}-{ENV}"
        super().__init__(table_name=table_name, client=client, table_key_schema=table_key_schema)

    @property
    def _pk(self):
        return self.resource.upper()

    @property
    def _sk(self):
        return self.resource.upper()

    def _create_get_item_input(self, id: str) -> dict:
        return {"Key": {"PK": f"{self._pk}#{id}", "SK": f"{self._sk}#{id}"}}

    def _create_put_item_input(self, merchant: dict) -> dict:
        id = uuid4()
        return {
            "Item": {
                "PK": f"{self._pk}#{id}",
                "SK": f"{self._sk}#{id}",
                "first_name": merchant["first_name"],
                "last_name": merchant["last_name"],
            },
        }

    def _create_delete_item_input(self, id: str) -> dict:
        return {"Key": {"PK": f"{self._pk}#{id}", "SK": f"{self._sk}#{id}"}}

    def get_merchant(self, id: str) -> Merchant:
        input = self._create_get_item_input(id)
        return self.get_item(input, self.ttl)

    def put_merchant(self, merchant: dict) -> Merchant:
        item = self._create_put_item_input(merchant)
        return self.put_item(item)

    def delete_merchant(self, id: str) -> Merchant:
        item = self._create_delete_item_input(id)
        return self.delete_item(item)
