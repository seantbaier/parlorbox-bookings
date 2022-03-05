import sys


def handler(event, context):
    return "Changed, Hello from AWS Lambda using Python" + sys.version + "!"
