import sys
from pprint import pprint


def handler(event, context):
    pprint("EVENT=", event)
    return "Hello from AWS Lambda using Python" + sys.version + "!"
