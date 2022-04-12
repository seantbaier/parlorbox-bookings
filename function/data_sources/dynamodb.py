from typing import Any, Union
from loguru import logger
from botocore.exceptions import ClientError
from pydantic import UUID4


ERROR_HELP_STRINGS = {
    # Common Errors
    "InternalServerError": "Internal Server Error, generally safe to retry with exponential back-off",
    "ProvisionedThroughputExceededException": "Request rate is too high. If you're using a custom retry strategy make sure to retry with exponential back-off."
    + "Otherwise consider reducing frequency of requests or increasing provisioned capacity for your table or secondary index",
    "ResourceNotFoundException": "One of the tables was not found, verify table exists before retrying",
    "ServiceUnavailable": "Had trouble reaching DynamoDB. generally safe to retry with exponential back-off",
    "ThrottlingException": "Request denied due to throttling, generally safe to retry with exponential back-off",
    "UnrecognizedClientException": "The request signature is incorrect most likely due to an invalid AWS access key ID or secret key, fix before retrying",
    "ValidationException": "The input fails to satisfy the constraints specified by DynamoDB, fix input before retrying",
    "RequestLimitExceeded": "Throughput exceeds the current throughput limit for your account, increase account level throughput before retrying",
}


class DynamoDBDataSource:
    def __init__(self, table_name: str, table_key_schema: dict, client):
        self.table_name = table_name
        self.table = client.Table(table_name)
        self.tablekey_schema = table_key_schema
        self.client = client

    def handle_error(self, error: Union[ClientError, BaseException]) -> None:
        if isinstance(error, BaseException):
            logger.error("Unknown Error")
            raise error

        error_code = "InternalServerError"
        if isinstance(error, ClientError):
            error_code = error.response["Error"]["Code"]
            error_message = error.response["Error"]["Message"]

        error_help_string = ERROR_HELP_STRINGS[error_code]

        logger.error(
            "[{error_code}] {help_string}. Error message: {error_message}".format(
                error_code=error_code, help_string=error_help_string, error_message=error_message
            )
        )

    def _create_get_item_input(self, id: UUID4) -> dict:
        raise NotImplementedError()

    def _create_put_item_input(self) -> dict:
        raise NotImplementedError()

    def _create_delete_item_input(self, id: UUID4) -> dict:
        raise NotImplementedError()

    def get_item(self, input: dict, ttl: int = None) -> Any:
        # Do nothing with ttl for now
        try:
            response = self.table.get_item(**input)
            return response
        except ClientError as error:
            self.handle_error(error)
        except BaseException as error:
            logger.error(error)

    def put_item(self, input: dict, ttl: int = None) -> Any:
        # Do nothing with ttl for now
        try:
            return self.table.put_item(**input)
        except ClientError as error:
            self.handle_error(error)
        except BaseException as error:
            logger.error(error)

    def delete_item(self, input: dict) -> Any:
        try:
            return self.table.delete_item(Key=input)
        except ClientError as error:
            self.handle_error(error)
            raise error
        except BaseException as error:
            logger.error(error)
            raise error

    def query(self, query) -> Any:
        try:
            response = self.table.query(**query)
            return response
        except ClientError as error:
            self.handle_error(error)
        except BaseException as error:
            logger.error(error)
