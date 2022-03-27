from pydantic import BaseModel


class Merchant(BaseModel):
    id: str
    first_name: str
    last_name: str
