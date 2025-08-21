# docker build --no-cache -t code-tunnel https://github.com/itukikikuti/conf.git#main:vscode
# docker run -d --name code-tunnel --hostname vscode code-tunnel
# docker logs code-tunnel で出てくるURLにアクセスして認証する
FROM ubuntu:24.04

SHELL ["/bin/bash", "-c"]

# 公式ドキュメントのインストール方法を参考にした
# https://code.visualstudio.com/docs/setup/linux
# apt-transport-httpsはHTTPS経由でのパッケージ取得に必要
RUN apt-get update && \
    apt-get install -y sudo wget openssh-client gpg apt-transport-https

RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg && \
    rm -f microsoft.gpg

# RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
RUN cat <<EOF > /etc/apt/sources.list.d/vscode.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF

RUN apt-get update && \
    apt-get install -y code

RUN echo "ubuntu:password" | chpasswd && \
    usermod -aG sudo ubuntu
RUN mkdir -p /home/vscode/.vscode-user-data && \
    chown -R ubuntu:ubuntu /home/vscode/.vscode-user-data
USER ubuntu
WORKDIR /home/ubuntu

RUN /usr/bin/code tunnel --help

RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    source ~/.bashrc && \
    nvm install --lts && \
    npm install -g @google/gemini-cli

CMD ["/usr/bin/code", "tunnel", "--accept-server-license-terms"]
