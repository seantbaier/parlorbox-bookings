#! /usr/bin/env sh

rm ./dist/function.zip
cd .venv/lib/python3.8/site-packages
zip -r9 ../../../../dist/function.zip .
cd ../../../../
zip -g ./dist/function.zip -r dataservices .env
