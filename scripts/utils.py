import os


def deploy_bookings() -> None:
    os.system("./bin/deploy.sh")


def run_bookings() -> None:
    os.system("./bin/run.sh")


def invoke() -> None:
    os.system("poetry run python -m function.app")


def clean_terragrunt() -> None:
    os.system("find . -type d -name '.terragrunt-cache' -prune -exec rm -rf {} \;")  # noqa
