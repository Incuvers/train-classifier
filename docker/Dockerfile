FROM tensorflow/tensorflow:latest-gpu

LABEL Christian Sargusingh "https://github.com/cSDes1gn"

ENV DEBIAN_FRONTEND=noninteractive

ARG MODEL
ENV MODEL=$MODEL

# Generate locale and install container build dependancies
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8
RUN apt install -y wget

WORKDIR /srv

COPY runner.sh /srv/runner.sh
ADD . /srv
# install required pip and apt dependancies for selected model
RUN xargs -a ${MODEL}/apt-pkgs.txt sudo apt install -y --no-install-recommends
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install -r ${MODEL}/requirements.txt --default-timeout=300

# tensorboard port
EXPOSE 6006

ENTRYPOINT [ "/srv/runner.sh" ]