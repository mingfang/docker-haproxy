FROM ubuntu:14.04
 
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update

#Runit
RUN apt-get install -y runit 
CMD /usr/sbin/runsvdir-start

#SSHD
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:root' |chpasswd
RUN sed -i "s/session.*required.*pam_loginuid.so/#session    required     pam_loginuid.so/" /etc/pam.d/sshd
RUN sed -i "s/PermitRootLogin without-password/#PermitRootLogin without-password/" /etc/ssh/sshd_config

#Utilities
RUN apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo software-properties-common

#HAProxy
RUN apt-get build-dep -y haproxy
RUN apt-get install -y libssl-dev
RUN curl http://www.haproxy.org/download/1.5/src/haproxy-1.5.2.tar.gz | tar xz
RUN mv haproxy-* haproxy
RUN cd haproxy && \
    make TARGET="linux26" USE_STATIC_PCRE=1 USE_OPENSSL=1 && \
    make install

#haproxy user
RUN adduser --system haproxy && \
    groupadd haproxy && \
    usermod -G haproxy haproxy 

#ssl
RUN mkdir -p /etc/ssl && \
    cd /etc/ssl && \
    export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo) && \
    openssl genrsa -des3 -out server.key -passout env:PASSPHRASE 2048 && \
    openssl req -new -batch -key server.key -out server.csr -subj "/C=/ST=/O=org/localityName=/commonName=org/organizationalUnitName=org/emailAddress=/" -passin env:PASSPHRASE && \
    openssl rsa -in server.key -out server.key -passin env:PASSPHRASE && \
    openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt && \
    cat server.crt server.key > server.pem

#Add runit services
ADD sv /etc/service 

