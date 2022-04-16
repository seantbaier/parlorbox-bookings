#! /usr/bin/env sh
set -e

docker build -t parlorbox-booking-service -f ./Dockerfile .
docker run parlorbox-booking-service --name parlorbox-bookings-service