from function.config import settings

SELLERS_USERGROUP = "seller"
VA_USERGROUP = "virtualAssistant"


# DynamoDB
SELLER_TABLE = f"Seller-{settings.PROJECT_NAME}-{settings.ENV_NAME}"
VA_TABLE = f"VirtualAssistant-{settings.PROJECT_NAME}-{settings.ENV_NAME}"
TEAM_TABLE = f"Team={settings.PROJECT_NAME}-{settings.ENV_NAME}"
