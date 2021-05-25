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
            --data "{\"text\":\"Model training (${0##*/}) failed with exit status: $1\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}

# docker volume create --driver local -o o=bind -o type=none -o device="/root/artefacts" artefacts 
# docker volume ls
# docker volume inspect artefacts

printf "%b" "${OKB}Starting docker container from image $MODEL:latest${NC}\n"
# run the training on model
docker run --name classifier -v "$PWD:/tmp" -e OUTPUT="$OUTPUT" "$MODEL"
printf "%b" "${OKG} ✓ ${NC}complete\n"

# Notify slack channel of build success
printf "%b" "${OKB}Notifying slack channel of ${0##*/} success.${NC}\n"
curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"Model training (${0##*/}) complete. Starting artefact upload.\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
printf "%b" "${OKG} ✓ ${NC}complete\n"
