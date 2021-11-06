import os


def clean():
    """
    Delete all pycache and pytest_cache files.
    """
    os.system(
        """
        find . -type d -name '__pycache__' -exec rm -r -v {} +
        find . -type d -name '.pytest_cache' -exec rm -r -v {} +
        find . -type d -name 'htmlcov' -exec rm -r -v {} +
        find . -type f -name '*.pyc'  -delete
        find . -type f -name '.coverage'  -delete
        find . -type f -name 'coverage.xml'  -delete
        """
    )


def build():
    os.system(
        """
        cd env/lib/python3.9/site-packages
        zip -r9 ../../../../function.zip .
        cd ../../../../
        zip -g ./function.zip -r app .env
        """
    )
