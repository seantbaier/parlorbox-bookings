from pydantic import EmailStr
from typing import List, Optional
from dataclasses import dataclass


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
    status: str


@dataclass
class MerchantCreate(MerchantBase):
    id: str


@dataclass
class Merchant(MerchantBase):
    id: str
