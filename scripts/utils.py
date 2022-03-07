import os


def deploy() -> None:
    os.system("./deploy.sh")


def invoke() -> None:
    os.system("poetry run python -m function.app")
