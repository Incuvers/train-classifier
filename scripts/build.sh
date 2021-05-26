#!/bin/bash

set -e

# cli
OKG="\033[92m"
WARN="\033[93m"
FAIL="\033[91m"
OKB="\033[94m"
UDL="\033[4m"
NC="\033[0m"

# handle all non-zero exit status codes with a slack notification
trap 'handler $?' EXIT

handler () {
    if [ "$1" != "0" ]; then
        printf "%b" "${OKB}Notifying slack channel of ${0##*/} failure.${NC}\n"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"${0##*/} failed with exit status: $1\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}

printf "%b" "${OKB}Copying source code to docker build context${NC}\n"
# path to checkout (custom for titan server builds)
cp -R /opt/actions-runner/work/handwriting-recognition/handwriting-recognition docker/.
printf "%b" "${OKG} ✓ ${NC}complete\n"

printf "%b" "${OKB}Building image for model: $MODEL${NC}\n"
# find checkout folder
docker build \
    -t "$MODEL":latest \
    -f docker/Dockerfile docker\
    --build-arg MODEL="$MODEL"
printf "%b" "${OKG} ✓ ${NC}$MODEL:latest built\n"