from typing import List


# TODO break these out into config vars
table_name = "Merchant-parlorbox-development"
table_key_schema: List[dict] = [
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
