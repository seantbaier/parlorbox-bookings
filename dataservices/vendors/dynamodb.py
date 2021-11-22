from loguru import logger

from dataservices.vendors.client import get_resource


class Dynamodb:
    def __init__(self, dynamodb=None):
        if dynamodb:
            self.dynamodb = dynamodb
        else:
            self.dynamodb = get_resource("dynamodb")

    def create_item(
        self,
        table_name: str,
        user_pool_id: str,
        username: str,
        user_attributes: dict,
        tempory_password: str,
    ):
        attributes = []
        for k, v in user_attributes.items():
            attributes.append({"Name": k, "Value": v})

        try:
            item = {
                "UserPoolId": user_pool_id,
                "Username": username,
                "UserAttributes": attributes,
                "TemporaryPassword": tempory_password,
                "ForceAliasCreation": True,
                "MessageAction": "SUPRESS",
            }

            table = self.dynamodb.Table(table_name)
            logger.info(f"Adding item={item}")
            response = table.put_item(Item=item)

            logger.success(response)
            return response
        except Exception as e:
            logger.error(e)
            raise e
