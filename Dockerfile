# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Execute on windows as:
#  docker build --memory=8g --memory-swap=8g -t totallyezy-taskezy:test . -f Dockerfile
# docker images
#  docker run -it --memory=4g --memory-swap=4g --memory-swappiness=0 --entrypoint=/bin/bash  <imageid>

# based on https://confluence.atlassian.com/bitbucket/debug-your-pipelines-locally-with-docker-838273569.html

# To clear the unused images (if you are trying to debug a lot) run this in bash (git.bash on windows)
# - it will remove the images with the Repository of '<none>' which means it is not really useful to use anyway
#
# docker images |awk '/<none>/ { print $3 }' | xargs -I {} docker image rm {} --force
#
#

# Start from the latest node base image
FROM node:12-stretch as builder
RUN mkdir /build
# ADD . /build/
WORKDIR /build
# Add Maintainer Info
LABEL maintainer="Robert Leidl <robert.leidl@namadgi.com>"


# Copy everything from the current directory to the Working Directory inside the container
COPY . .

# Get the package dependancies
#RUN echo "deb http://deb.debian.org/debian jessie main\ndeb http://security.debian.org jessie/updates main" > /etc/apt/sources.list
#RUN apt-get update; apt-get install -y gettext-base;
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y default-jre-headless locales
RUN sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


# Just build so we know the code is ready for deploying
# RUN npm rebuild node-sass
# RUN npm install
# RUN npm run postinstall
# RUN npm run build
#
## Now build Chromium to run the tests
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN set -x && apt-get update && apt-get install -y xvfb google-chrome-stable
RUN wget -q -O /usr/bin/xvfb-chrome https://bitbucket.org/atlassian/docker-node-chrome-firefox/raw/ff180e2f16ea8639d4ca4a3abb0017ee23c2836c/scripts/xvfb-chrome
RUN ln -sf /usr/bin/xvfb-chrome /usr/bin/google-chrome
RUN chmod 755 /usr/bin/google-chrome
#
## Now the tests
# RUN ./node_modules/@angular/cli/bin/ng -v
# RUN ./node_modules/@angular/cli/bin/ng test --watch=false
# RUN ./node_modules/@angular/cli/bin/ng e2e --configuration=test --port=4802


