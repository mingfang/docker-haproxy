FROM ubuntu
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat tree htop unzip sudo

#Serf
RUN wget https://dl.bintray.com/mitchellh/serf/0.4.1_linux_amd64.zip && \
    unzip 0.4*.zip && \
    rm 0.4*.zip
RUN mv serf /usr/bin/

#HAProxy
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y haproxy
RUN ulimit unlimited

ADD . /docker-haproxy
RUN chmod +x /docker-haproxy/bin/*.sh
RUN ln -s /docker-haproxy/etc/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf
RUN ln -s /docker-haproxy/etc/supervisord-serf.conf /etc/supervisor/conf.d/supervisord-serf.conf
RUN ln -s /docker-haproxy/etc/supervisord-haproxy.conf /etc/supervisor/conf.d/supervisord-haproxy.conf

ENV BIND 0.0.0.0:7946
EXPOSE 22 7946
