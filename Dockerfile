# 端口规划
# 9000 - nginx
# 9001 - websocketify
# 5911 - tigervnc

# based on ubuntu 22.04 LTS
FROM ubuntu:22.04

# 各种环境变量
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_ARG0=/sbin/entrypoint.sh \
    VNC_GEOMETRY=800x600 \
    VNC_PASSWD=MAX8char \
    USER_PASSWD='' \
    DEBIAN_FRONTEND=noninteractive

ARG S6_OVERLAY_VERSION=3.1.5.0
ARG TIGHT_VNC_SERVER_VERSION=1.13.1
ARG NOVNC_REF=v1.4.0
ARG WEBSOCKETIFY_REF=v0.11.0

# 首先加用户，防止 uid/gid 不稳定
RUN groupadd user && useradd -m -g user user && \
    # 安装依赖和代码
    apt-get update && apt-get upgrade -y && \
    apt-get install -y \
        git \
        ca-certificates wget xz-utils locales \
        nginx sudo \
        xorg openbox rxvt-unicode \
        python3-numpy && \
    wget -O - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | xz -d | tar -xv && \
    wget -O - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz | xz -d | tar -xv && \
    # workaround for https://github.com/just-containers/s6-overlay/issues/158
    ln -s /init /init.entrypoint && \
    # tigervnc
    wget -O /tmp/tigervnc.tar.gz https://sourceforge.net/projects/tigervnc/files/stable/${TIGHT_VNC_SERVER_VERSION}/tigervnc-${TIGHT_VNC_SERVER_VERSION}.x86_64.tar.gz/download && \
    tar xzf /tmp/tigervnc.tar.gz -C /tmp && \
    chown root:root -R /tmp/tigervnc-${TIGHT_VNC_SERVER_VERSION}.x86_64 && \
    tar c -C /tmp/tigervnc-${TIGHT_VNC_SERVER_VERSION}.x86_64 usr | tar x -C / && \
    locale-gen en_US.UTF-8 && \
    # novnc
    mkdir -p /app/src && \
    git clone --depth=1 --recursive --branch ${NOVNC_REF} https://github.com/novnc/noVNC.git /app/src/novnc && \
    git clone --depth=1 --recursive --branch ${WEBSOCKETIFY_REF} https://github.com/novnc/websockify.git /app/src/websockify && \
    apt-get purge -y git wget xz-utils && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -fr /tmp/* /app/src/novnc/.git /app/src/websockify/.git /var/lib/apt/lists

# copy files
COPY ./docker-root /

EXPOSE 9000/tcp 5911/tcp

ENTRYPOINT ["/init.entrypoint"]
CMD ["start"]
