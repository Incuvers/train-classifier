#!/bin/bash

# cli
OKG="\033[92m"
WARN="\033[93m"
FAIL="\033[91m"
OKB="\033[94m"
UDL="\033[4m"
NC="\033[0m"

printf "%b" "${OKB}Starting training job${NC}\n"
cd "$MODEL" || exit 1
python3 train.py || exit 1
printf "%b" "${OKG} ✓ ${NC}Training completed successfully\n"

printf "%b" "${OKB}Compiling artefacts in ${OKG}${OUTPUT}${OKB} to ${OKG}/tmp/${NC}"
tar -cvzf /tmp/"$OUTPUT".gz "$OUTPUT"
printf "%b" "${OKG} ✓ ${NC}artefacts zipped\n"