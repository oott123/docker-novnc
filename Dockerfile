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
RUN groupadd user && useradd -m -g user user

# download files out of container
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.5/s6-overlay-amd64.tar.gz /tmp/s6-overlay-amd64.tar.gz
ADD https://bintray.com/artifact/download/tigervnc/stable/ubuntu-16.04LTS/amd64/tigervncserver_1.7.1-1ubuntu1_amd64.deb /tmp/tigervnc.deb

# 安装依赖和代码
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        python git \
        ca-certificates wget curl locales \
        sudo nginx \
        xorg openbox && \
    tar -xvf /tmp/s6-overlay-amd64.tar.gz && \
    # workaround for https://github.com/just-containers/s6-overlay/issues/158
    ln -s /init /init.entrypoint && \
    # tigervnc
    (dpkg -i /tmp/tigervnc.deb || apt-get -f -y install) && \
    locale-gen en_US.UTF-8 && \
    # novnc
    mkdir -p /app/src && \
    git clone --depth=1 https://github.com/novnc/noVNC.git /app/src/novnc && \
    git clone --depth=1 https://github.com/novnc/websockify.git /app/src/websockify && \
    apt-get autoremove -y && \
    apt-get clean

# copy files
COPY ./docker-root /

EXPOSE 9000

ENTRYPOINT ["/init.entrypoint"]
CMD ["start"]
