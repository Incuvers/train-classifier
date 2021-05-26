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
        printf "%b" "${FAIL}${0##*/} failure.${NC}\n"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"Model training (${0##*/}) failed with exit status: $1\n```\n\n```\n \"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}

# docker volume create --driver local -o o=bind -o type=none -o device="/root/artefacts" artefacts 
# docker volume ls
# docker volume inspect artefacts

printf "%b" "${OKB}Starting docker container from image $MODEL:latest${NC}\n"
# run the training on model
docker rm -f classifier
docker run --gpus all --name classifier -v "$PWD:/tmp" "$MODEL"
# check exit status on container image
if [[ $(docker inspect classifier --format='{{.State.ExitCode}}') != 0 ]]; then
    exit 1;
fi
printf "%b" "${OKG} ✓ ${NC}complete\n"

# move generated artefacts to github workspace
cp artefacts.tar.gz "$GITHUB_WORKSPACE"/.