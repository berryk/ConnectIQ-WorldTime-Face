FROM gitpod/workspace-full:latest

USER root

ENV SDK_VERSION=3.0.10

ENV SDK_URL=https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-3.0.10-2019-4-23-e0f78e3e.zip
ENV SDK_FILE=sdk.zip
ENV SDK_DIR=/opt/connectiq

RUN add-apt-repository "deb http://mirrors.kernel.org/ubuntu/ xenial main"

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq wget openjdk-8-jdk unzip build-essential xvfb libusb-1.0-0-dev xorg

RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq libwebkitgtk-1.0-0
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq libpng12-0 libwebkitgtk-1.0-0
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq libjpeg8 imagemagick
RUN wget -O "$SDK_FILE" "$SDK_URL"
RUN unzip "$SDK_FILE" -d "${SDK_DIR}"
RUN chmod 777 ${SDK_DIR}/bin/*
