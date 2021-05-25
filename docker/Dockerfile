FROM ubuntu:latest as stage

LABEL Christian Sargusingh "https://github.com/cSDes1gn"

ENV DEBIAN_FRONTEND=noninteractive

# Generate locale and install container build dependancies
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8
RUN apt install -y git

RUN mkdir /root/.ssh
ARG INPUT_PRIVATE_DEPLOY_KEY
RUN echo "${INPUT_PRIVATE_DEPLOY_KEY}"
# restrict permissions of keyfile
RUN echo "${INPUT_PRIVATE_DEPLOY_KEY}" > /root/.ssh/id_rsa && chmod 0700 /root/.ssh/id_rsa
# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
# pull using deploy key and alias host setup
RUN git clone git@github.com:Incuvers/handwriting-recognition.git

# multistage build to squash private key and ssh config
FROM ubuntu:latest
COPY --from=stage /handwriting-recognition /srv/

WORKDIR /srv

COPY run.sh srv/run.sh
# install required pip and apt dependancies
RUN xargs -a ${INPUT_MODEL}/apt-pkgs.txt sudo apt install -y --no-install-recommends
RUN python3 -m pip install -r ${INPUT MODEL}/requirements.txt

ENTRYPOINT [ "/run.sh" ]