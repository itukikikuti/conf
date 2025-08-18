FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

EXPOSE 5901

RUN apt-get update && \
    apt-get install -y sudo wget nano tigervnc-standalone-server tigervnc-common xfce4 xfce4-goodies dbus-x11 fonts-vlgothic fonts-ipafont fonts-ipaexfont && \
    locales && \
    locale-gen ja_JP.UTF-8 && \
    update-locale LANG=ja_JP.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "ubuntu:password" | chpasswd && \
    usermod -aG sudo ubuntu

USER ubuntu
WORKDIR /home/ubuntu

RUN mkdir -p .vnc && \
    (echo "password"; echo "password") | vncpasswd -f > .vnc/passwd && \
    chmod 600 .vnc/passwd

RUN echo '#!/bin/sh' > .vnc/xstartup && \
    echo 'export LANG=ja_JP.UTF-8' >> .vnc/xstartup && \
    echo 'export LANGUAGE=ja_JP:ja' >> .vnc/xstartup && \
    echo 'export LC_ALL=ja_JP.UTF-8' >> .vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> .vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> .vnc/xstartup && \
    echo 'startxfce4' >> .vnc/xstartup && \
    chmod +x .vnc/xstartup

CMD ["/bin/sh", "-c", "vncserver :1 -localhost no -rfbport 5901 && tail -f /home/ubuntu/.vnc/*.log"]
