FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq && apt-get install -y nfs-kernel-server runit inotify-tools -qq
RUN mkdir -p /exports

RUN mkdir -p /etc/sv/nfs
ADD nfs.init /etc/sv/nfs/run
ADD nfs.stop /etc/sv/nfs/finish

ADD nfs_setup.sh /usr/local/bin/nfs_setup

VOLUME /exports

EXPOSE 111/udp 111/tcp 2049/tcp 2049/udp 32764/tcp 32764/udp 32765/tcp 32765/udp 32766/tcp 32766/udp 32767/tcp 32767/udp 32768/tcp 32768/udp 32769/tcp 32769/udp

ENTRYPOINT ["/usr/local/bin/nfs_setup"]
