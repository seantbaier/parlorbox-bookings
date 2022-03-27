from typing import List

from function.data_sources import KeySchema

# TODO break these out into config vars
table_name = "Merchant-parlorbox-development"
table_key_schema: List[KeySchema] = [
    {
        "AttributeName": "PK",
        "KeyType": "HASH",
    },
    {
        "AttributeName": "SK",
        "KeyType": "HASH",
    },
    {
        "AttributeName": "active",
        "KeyType": "BOOL",
    },
]
