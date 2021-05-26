#!/bin/bash

# cli
OKG="\033[92m"
WARN="\033[93m"
FAIL="\033[91m"
OKB="\033[94m"
UDL="\033[4m"
NC="\033[0m"

# handle all non-zero exit status codes with a slack notification
# trap 'handler $?' EXIT

# handler () {
#     if [ "$1" != "0" ]; then
#         printf "%b" "${FAIL}${0##*/} failed during training.${NC}\n"
#         printf "%b" "${OKB}Stopping webserver monitoring${NC}\n"
#         kill -9 "$TB_PID"
#         kill -9 "$NG_PID"
#         printf "%b" "${OKG} ✓ ${NC}complete\n"
#         exit 1
#     fi
# }

printf "%b" "${OKB}Executing preconfiguration steps${NC}\n"
mkdir "$MODEL"/model_data
wget -P "$MODEL"/model_data https://pjreddie.com/media/files/yolov3-tiny.weights
python3 mnist/make_data.py || exit 1
printf "%b" "${OKG} ✓ ${NC}preconfiguration step complete\n"

printf "%b" "${OKB}Starting training job${NC}\n"
# tensorboard --logdir=log &
# TB_PID=$!
# ngrok http 6006 &
# NG_PID=$!
python3 -m "$MODEL" || exit 1
printf "%b" "${OKG} ✓ ${NC}Training completed successfully\n"
# printf "%b" "${OKB}Stopping webserver monitoring${NC}\n"
# kill -9 "$TB_PID"
# kill -9 "$NG_PID"
# printf "%b" "${OKG} ✓ ${NC}complete\n"

printf "%b" "${OKB}Compiling artefacts in ${OKG}artefacts${OKB} to ${OKG}/tmp/${NC}\n"
tar -cvzf /tmp/artefacts.tar.gz artefacts
printf "%b" "${OKG} ✓ ${NC}artefacts zipped\n"