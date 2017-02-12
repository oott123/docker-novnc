# 端口规划
# 9000 - nginx
# 9001 - websocketify
# 5901 - tigervnc

# based on ubuntu 16.04 LTS
FROM ubuntu:xenial
# 各种环境变量
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_ARG0=/sbin/entrypoint.sh \
    VNC_GEOMETRY=800x600 \
    VNC_PASSWD=MAX8chars \
    DEBIAN_FRONTEND=noninteractive

# 首先加用户，防止 uid/gid 不稳定
RUN groupadd -r user && useradd -r -m -g user user

# 使用 s6 init
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.5/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && \
# workaround for https://github.com/just-containers/s6-overlay/issues/158
    ln -s /init /init.entrypoint
ADD fix-attrs.d /etc/fix-attrs.d
ADD cont-init.d /etc/cont-init.d
ADD services.d /etc/services.d

# 安装依赖和代码
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        python \
        git \
        ca-certificates wget curl \
        sudo nginx\
        xorg openbox \
        build-essential && \
    wget https://bintray.com/artifact/download/tigervnc/stable/ubuntu-16.04LTS/amd64/tigervncserver_1.7.1-1ubuntu1_amd64.deb -O /tmp/tigervnc.deb && \
    dpkg -i /tmp/tigervnc.deb && \
    apt-get -f install && \
    rm -f /tmp/tigervnc.deb && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /app/src && \
    git clone --depth=1 https://github.com/novnc/noVNC.git /app/src/novnc && \
    git clone --depth=1 https://github.com/novnc/websockify.git /app/src/websockify && \
    cd /app/src/websockify && \
    make && \
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean

# copy files
COPY /etc/nginx.conf /etc/nginx/nginx.conf
COPY vncmain.sh /app/vncmain.sh
COPY entrypoint.sh /sbin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/init.entrypoint"]
CMD ["start"]
