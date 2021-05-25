FROM ubuntu:latest

LABEL Christian Sargusingh "https://github.com/cSDes1gn"

ENV DEBIAN_FRONTEND=noninteractive

# Set the work directory and create the folder to copy source code into
WORKDIR /srv

# pull using deploy key and alias host setup
RUN git clone git@github.com-hr:Incuvers/handwriting-recognition.git

# Generate locale.
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8
RUN ls -la

# load in model and runner script
# COPY . srv/
# COPY run.sh srv/run.sh
# install required pip and apt dependancies
# RUN xargs -a ${INPUT_MODEL}/apt-pkgs.txt sudo apt install -y --no-install-recommends

# RUN python3 -m pip install -r ${INPUT MODEL}/requirements.txt

ENTRYPOINT [ "/run.sh" ]