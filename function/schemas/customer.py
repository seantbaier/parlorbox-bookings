from pydantic import BaseModel, EmailStr, UUID4
from typing import Optional

from function.schemas.common import Status


class CustomerBase(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    status: Status = Status("active")


class CustomerCreate(CustomerBase):
    id: UUID4


class Customer(CustomerBase):
    id: UUID4
