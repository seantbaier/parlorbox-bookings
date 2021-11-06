#! /usr/bin/env sh

find . -type d -name '__pycache__' -exec rm -r -v {} +
find . -type d -name '.pytest_cache' -exec rm -r -v {} +
find . -type d -name 'htmlcov' -exec rm -r -v {} +
find . -type f -name '*.pyc'  -delete
find . -type f -name '.coverage'  -delete
find . -type f -name 'coverage.xml'  -delete