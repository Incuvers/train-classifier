#!/bin/bash

set -e

# cli
OKG="\033[92m"
FAIL="\033[91m"
OKB="\033[94m"
NC="\033[0m"

# handle all non-zero exit status codes with a slack notification
trap 'handler $?' EXIT

handler () {
    if [ "$1" != "0" ]; then
        printf "%b" "${FAIL}${0##*/} failure.${NC}\n"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"Model training (${0##*/}) failed with exit status: $1\"}" https://hooks.slack.com/services/"$SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}

printf "%b" "${OKB}Starting docker container from image $MODEL:latest${NC}\n"
# run the training on model
docker rm -f classifier
# docker run --gpus all --name classifier -v "$PWD:/tmp" "$MODEL"
# check exit status on container image
CONTAINER_STATUS=$(docker inspect classifier --format='{{.State.ExitCode}}')
printf "%b" "${OKB}Container exited with status ${OKG}$CONTAINER_STATUS${NC}\n"
if [[ "$CONTAINER_STATUS" != 0 ]]; then
    exit 1;
fi
printf "%b" "${OKG} ✓ ${NC}complete\n"

# move generated artefacts to github workspace
cp artefacts.tar.gz "$GITHUB_WORKSPACE"/.