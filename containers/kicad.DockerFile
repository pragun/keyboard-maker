FROM ubuntu:jammy

# These things are needed:
#    sudo: So we have /etc/sudoers.d.
#    keyboard-configuration: Installation stalls without this.
#    software-properties-common: So add-apt-repository exists.
RUN apt-get update && \
    apt-get install -y sudo keyboard-configuration software-properties-common

# Install KiCad 8.0.0.
# (Got the version from https://launchpad.net/~kicad/+archive/ubuntu/kicad-8.0-releases.)
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime && \
    add-apt-repository --yes ppa:kicad/kicad-8.0-releases && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata  && \
    apt-get install -y kicad  && \
    apt-get install -y python3-pip python3-venv && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN add-apt-repository ppa:rmescandon/yq && \
    apt-get update && \
    apt-get install yq -y --no-install-recommends && \
    apt-get install jq -y --no-install-recommends && \
    apt-get install git -y --no-install-recommends

# Non-root user variables
ARG DEV_USER="pragun"
ARG DEV_USER_UID=1000
ARG DEV_USER_GID=$DEV_USER_UID
ARG DEV_USER_FULLNAME=$DEV_USER
ARG DEV_USER_HOME="/home/$DEV_USER"
ARG DEV_USER_SHELL="/bin/bash"

# Persist these variables for other container layers
ENV DEV_USER=$DEV_USER
ENV DEV_USER_UID=$DEV_USER_UID
ENV DEV_USER_GID=$DEV_USER_GID
ENV DEV_USER_FULLNAME=$DEV_USER_FULLNAME
ENV DEV_USER_HOME=$DEV_USER_HOME
ENV DEV_USER_SHELL=$DEV_USER_SHELL

# Create a user account that mirrors the one on your local host so you can share the X11 socket for the KiCad GUI.
# (See http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/)

# Create non-root user
RUN groupadd --gid $DEV_USER_GID $DEV_USER \
    && useradd \
        --uid $DEV_USER_UID \
        --gid $DEV_USER_GID \
        --comment "$DEV_USER_FULLNAME,,," \
        --home-dir $DEV_USER_HOME \
        --shell $DEV_USER_SHELL \
        --create-home \
        $DEV_USER \
    && usermod --append --groups sudo $DEV_USER

USER ${USER_NAME}

RUN python3 -m venv /kicad-venv
COPY kicad/requirements.txt /kicad-venv/requirements.txt
RUN . /kicad-venv/bin/activate && pip install -r /kicad-venv/requirements.txt

RUN mkdir /kicad-libraries
COPY kicad/libutils/* /kicad-libraries/
RUN 	. /kicad-venv/bin/activate && \
	cd /kicad-libraries && \
	./get_git_kicad_lib.sh daprice-keyswitches.yaml /kicad-libraries/daprice-keyswitches && \
	./get_git_kicad_lib.sh ncardini-rppico.yaml /kicad-libraries/ncardini-rppico 

ENTRYPOINT ["bash", "-l", "-c"]
