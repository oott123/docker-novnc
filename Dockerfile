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
    VNC_PASSWD=MAX8char \
    USER_PASSWD='' \
    DEBIAN_FRONTEND=noninteractive

# 首先加用户，防止 uid/gid 不稳定
RUN groupadd user && useradd -m -g user user && \
    # 安装依赖和代码
    apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        git \
        ca-certificates wget locales \
        nginx \
        xorg openbox && \
    wget -O - https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz | tar -xzv && \
    # workaround for https://github.com/just-containers/s6-overlay/issues/158
    ln -s /init /init.entrypoint && \
    # tigervnc
    wget -O /tmp/tigervnc.deb https://bintray.com/artifact/download/tigervnc/stable/ubuntu-16.04LTS/amd64/tigervncserver_1.9.0-1ubuntu1_amd64.deb && \
    (dpkg -i /tmp/tigervnc.deb || apt-get -f -y install) && \
    locale-gen en_US.UTF-8 && \
    # novnc
    mkdir -p /app/src && \
    git clone --depth=1 https://github.com/novnc/noVNC.git /app/src/novnc && \
    git clone --depth=1 https://github.com/novnc/websockify.git /app/src/websockify && \
    apt-get purge -y git wget && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -fr /tmp/* /app/src/novnc/.git /app/src/websockify/.git

# copy files
COPY ./docker-root /

EXPOSE 9000/tcp 9001/tcp 5901/tcp

ENTRYPOINT ["/init.entrypoint"]
CMD ["start"]
