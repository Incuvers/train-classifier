#!/bin/bash

set -e

source colors.env

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

# run the training on model
docker run -it --name classifier -v "$(pwd):/tmp" -e OUTPUT="$OUTPUT" classifier

# Notify slack channel of build success
printf "%b" "${OKB}Notifying slack channel of ${0##*/} success.${NC}\n"
curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"Model training (${0##*/}) complete. Starting artefact upload.\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
printf "%b" "${OKG} ✓ ${NC}complete\n"
