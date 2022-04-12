from uuid import uuid4
import pytest
import boto3
from typing import Generator

from function.data_sources import MerchantDataSource
from function.schemas import Merchant
from function.data_sources import ItemNotFoundError


@pytest.fixture
def client():
    return boto3.resource("dynamodb", region_name="us-east-2")


@pytest.fixture
def data_source(client):
    return MerchantDataSource(client)


@pytest.fixture
def merchant():
    return {"email": f"{uuid4()}@email.com", "first_name": "steve", "last_name": "rogers"}


@pytest.fixture
def create_merchant(data_source: MerchantDataSource, merchant: dict) -> Generator:
    item = data_source.create_merchant(merchant)
    yield item
    delete_input = {"PK": f"MERCHANT#{item.id}", "SK": f"MERCHANT#{item.id}"}
    data_source.delete_item(delete_input)


def test_create_merchant(data_source: MerchantDataSource, merchant: dict) -> None:
    item = data_source.create_merchant(merchant)
    assert item.email == merchant["email"]
    data_source.delete_merchant(item.id)


def test_get_merchant(data_source: MerchantDataSource, create_merchant: Merchant) -> None:
    merchant = data_source.get_merchant(create_merchant.id)
    assert merchant.PK == f"MERCHANT#{create_merchant.id}"
    assert merchant.SK == f"MERCHANT#{create_merchant.id}"


def test_get_merchant_by_email(data_source: MerchantDataSource, create_merchant: Merchant) -> None:
    merchant = data_source.get_merchant_by_email(id=create_merchant.id, email=create_merchant.email)
    assert merchant.email == create_merchant.email


def test_delete_merchant(data_source: MerchantDataSource, merchant: dict) -> None:
    item = data_source.create_merchant(merchant)
    data_source.delete_merchant(item.id)

    with pytest.raises(ItemNotFoundError) as excinfo:
        merchant = data_source.get_merchant(item.id)
        assert excinfo.type == ItemNotFoundError
