import pytest
import boto3

from function.data_sources import MerchantProvider


@pytest.fixture
def merchant():
    return {"id": 1, "first_name": "steve", "last_name": "rogers"}


@pytest.fixture
def client():
    return boto3.resource("dynamodb", region_name="us-east-2")


@pytest.fixture
def merchant_provider(client):
    return MerchantProvider(client)


def test_put_merchant(merchant_provider: MerchantProvider, merchant: dict) -> None:
    result = merchant_provider.put_merchant(merchant)
    assert result["ResponseMetadata"]["HTTPStatusCode"] == 200
    merchant_provider.delete_merchant(merchant["id"])


def test_get_merchant(merchant_provider: MerchantProvider, merchant: dict) -> None:
    merchant = merchant_provider.get_merchant(merchant["id"])

    item = merchant["Item"]
    assert item["PK"] == "MERCHANT#1"
    assert item["SK"] == "MERCHANT#1"
