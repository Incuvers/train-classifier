#!/bin/bash

OKG="\033[92m"
OKB="\033[94m"
NC="\033[0m"

set -e

# handle all non-zero exit status codes with a slack notification
trap 'handler $?' EXIT

handler () {
    if [ "$1" != "0" ]; then
        printf "%b" "${OKB}Notifying slack channel of snap build failure.${NC}\n"
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"Model training failed with exit status: $1\"}" https://hooks.slack.com/services/"$INPUT_SLACK_IDENTIFIER"
        printf "%b" "${OKG} ✓ ${NC}complete\n"
    fi
}

printf "%b" "${OKB}Starting training job${NC}\n"
# run the training
python3 -m "$INPUT_MODEL"
printf "%b" "${OKG} ✓ ${NC}Training completed successfully"

# Notify slack channel of build success
printf "%b" "${OKB}Notifying slack channel of training completion success.${NC}"
curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\":\"Model training complete. Download the artefacts here: \"}" https://hooks.slack.com/services/"$INPUT_SLACK_IDENTIFIER"
printf "%b" "${OKG} ✓ ${NC}complete"
