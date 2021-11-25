from pathlib import Path

from loguru import logger


def get_function(client, function_name: str):
    try:
        response = client.get_function(
            FunctionName=function_name,
        )

        if "Configuration" in response:
            logger.success(
                f"Found FunctionName={response['Configuration']['FunctionName']}"
            )
            return response["Configuration"]
    except client.exceptions.ResourceNotFoundException as e:
        logger.debug(e)
        return None
    except Exception as e:
        logger.error(e)


def create_function(client, function_name: str):
    zipfile = open(Path.cwd().joinpath("dist", "function.zip"), "rb").read()
    try:
        response = client.create_function(
            FunctionName=function_name,
            Runtime="python3.8",
            Handler="function/main.handler",
            MemorySize=128,
            Code={"ZipFile": zipfile},
            Role="arn:aws:iam::123456:role/irrelevant",
        )
        logger.success(f"Created {function_name}")
        return response
    except Exception as e:
        logger.error(e)


def invoke_function(client, function_name: str):
    payload = open(
        Path.cwd().joinpath(
            "function", "payload.json"
        ),
        "r",
    ).read()

    try:
        response = client.invoke(
            FunctionName=function_name,
            InvocationType="RequestResponse",
            LogType="Tail",
            ClientContext="string",
            Payload=payload,
        )
        logger.success(response)
        return response
    except Exception as e:
        logger.error(e)


def delete_function(client, function_name: str):
    try:
        response = client.delete_function(
            FunctionName=function_name,
        )

        print("\nFunctions\n", response)
    except Exception as e:
        logger.error(e)
