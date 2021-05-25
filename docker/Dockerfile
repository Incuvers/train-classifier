FROM ubuntu:latest as stage

LABEL Christian Sargusingh "https://github.com/cSDes1gn"

ENV DEBIAN_FRONTEND=noninteractive

# Generate locale and install container build dependancies
RUN apt update && apt dist-upgrade --yes && apt install --yes sudo locales && locale-gen en_US.UTF-8
RUN apt install -y git

RUN mkdir /root/.ssh
# This expects host machine to have an hr deploy key and config for key alias
ADD ~/.ssh/hr_deploy_key /root/.ssh/
ADD ~/.ssh/config /root/.ssh/
# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
# pull using deploy key and alias host setup
RUN git clone git@github.com-hr:Incuvers/handwriting-recognition.git

# multistage build to squash private key and ssh config
FROM ubuntu:latest
COPY --from=stage /handwriting-recognition /srv/

WORKDIR /srv

COPY run.sh srv/run.sh
# install required pip and apt dependancies
RUN xargs -a ${INPUT_MODEL}/apt-pkgs.txt sudo apt install -y --no-install-recommends
RUN python3 -m pip install -r ${INPUT MODEL}/requirements.txt

ENTRYPOINT [ "/run.sh" ]