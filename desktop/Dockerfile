FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

EXPOSE 3389

RUN apt-get update && \
    apt-get install -y \
    sudo \
    wget \
    nano \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \
    locales \
    fonts-vlgothic \
    fonts-ipafont \
    fonts-ipaexfont \
    xrdp \
    xorgxrdp && \
    locale-gen ja_JP.UTF-8 && \
    update-locale LANG=ja_JP.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "ubuntu:password" | chpasswd && \
    usermod -aG sudo ubuntu

RUN echo "startxfce4" > /home/ubuntu/.xsession && \
    chown ubuntu:ubuntu /home/ubuntu/.xsession
    
USER ubuntu
WORKDIR /home/ubuntu

CMD ["/bin/sh", "-lc", "/usr/sbin/xrdp-sesman && exec /usr/sbin/xrdp -n"]
