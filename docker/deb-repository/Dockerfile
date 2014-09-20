FROM debian:wheezy
MAINTAINER OpenROV Inc - Dominik Fretz, dominik@openrov.com
ENV HOME /root
RUN apt-get update
RUN apt-get install -y ruby1.9.3 rubygems gnupg gnupg-agent dpkg-sig
RUN gem install deb-s3
