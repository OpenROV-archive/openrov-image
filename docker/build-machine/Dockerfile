FROM ubuntu:14.04
MAINTAINER Dominik Fretz, dominik@openrov.com

# installing packages needed for cross compiling and image creation
RUN apt-get update
RUN apt-get install -y git

WORKDIR /tmp
RUN git clone https://github.com/codewithpassion/openrov-image.git image
WORKDIR /tmp/image
RUN git checkout debian-image

RUN ./setup-system.sh
