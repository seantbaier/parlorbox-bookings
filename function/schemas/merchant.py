from pydantic import EmailStr, UUID4
from typing import List, Optional
from dataclasses import dataclass


from function.schemas.common import Status
from function.schemas.customer import Customer


@dataclass
class MerchantBase:
    PK: str
    SK: str
    GSIPK: str
    first_name: str
    last_name: str
    email: EmailStr
    waitlist: Optional[List[Customer]]
    status: Status


@dataclass
class MerchantCreate(MerchantBase):
    id: UUID4


@dataclass
class Merchant(MerchantBase):
    id: UUID4
