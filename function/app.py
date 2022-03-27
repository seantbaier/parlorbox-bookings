import io
import boto3
import json
from loguru import logger
from pathlib import Path
from pprint import pprint
from typing import Any, Optional
from collections import namedtuple


from function.services import bookings


client = boto3.resource("dynamodb")


BOOKINGS_EVENT = "BOOKINGS"


def print_break(text: str, data: Optional[Any] = None) -> None:
    print("-" * 88)
    logger.info(text)
    print("-" * 88)

    if data:
        print(data)


def decode_response(content: bytes) -> dict:
    logger.debug("DECODE_RESPONSE")
    for line in content.readlines():
        result = line.decode("utf-8")
        logger.debug(type(result))
        return result


def get_object(bucket: str, key: str):
    logger.info(f"bucket={bucket}, key={key}")

    try:
        client = boto3.client("s3")
        bytes_buffer = io.BytesIO()
        client.download_fileobj(Bucket=bucket, Key=key, Fileobj=bytes_buffer)
        byte_value = bytes_buffer.getvalue()
        booking = byte_value.decode()  # python3, default decoding is utf-8

        # object = s3.Object(bucket, key)
        # booking = object.get()["Body"].read().decode("utf-8")

        # response = client.get_object(Bucket=bucket, Key=key)
        print(booking)
        logger.debug(type(booking))
        print(json.loads(booking))
        if booking:
            # pprint(dir(response["Body"]))

            # content = decode_response(response["Body"])
            logger.debug("CONTENT")
            pprint(booking)

            return booking

    except Exception as e:
        logger.error(e)
        return e


def handle_booking_event(event: dict):
    logger.info(f"BOOKING S3 PUT EVENT:::{BOOKINGS_EVENT}")
    return bookings.process_event(client, event)


def handle_stream(event: dict):
    Stream = namedtuple("Stream", ["invocationId", "deliveryStreamArn", "region", "records"])
    stream = Stream(**event)
    print_break(f"BEGIN KINESIS FIREHOSE STREAM PROCESSING:::{stream.invocationId}")
    print(f"Kineses records: {len(stream.records)}")

    result = []
    record = event["records"][0]

    for record in event["records"]:
        # Process the list of records and transform them
        # Result must be Dropped, Ok, or ProcessingFailed"
        result.append(
            {
                "recordId": record["recordId"],
                "result": "Ok",
                "data": record["data"],
            }
        )

    logger.info(record)

    print_break(f"END KINESIS FIREHOSE STREAM PROCESSING:::{stream.invocationId}")
    return {"records": result}


def handler(event, context):
    try:
        print_break(text="EVENT", data=event)
        print_break(text="CONTEXT", data=context)

        if "deliveryStreamArn" in event:
            result = handle_stream(event)
            return result

        # TODO Might need some more checks here
        # like event["source"], and I think we can add whatever we want
        detail_type = event.get("detail-type", None)
        if detail_type == BOOKINGS_EVENT:
            return handle_booking_event(event)

        print_break(text="Unknown event triggered.")
    except Exception as e:
        logger.error(e)
    return event


def mock_event() -> dict:
    event_file = open(Path.cwd().joinpath("tests/mocks/event_bridge_booking.json"), "r")
    yield json.loads(event_file.read())
    event_file.close()


if __name__ == "__main__":
    event = mock_event()
    handler(event=next(event), context={})
