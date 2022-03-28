import boto3
from pydantic import UUID4, EmailStr

from function.data_sources import MerchantDataSource


def get_merchant_by_email(id: UUID4, email: EmailStr) -> None:
    client = boto3.resource("dynamodb", region_name="us-east-2")
    data_source = MerchantDataSource(client)
    return data_source.get_merchant_by_email(id=id, email=email)
