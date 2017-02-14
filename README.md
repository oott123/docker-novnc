# docker-novnc

[![Docker Pulls](https://img.shields.io/docker/pulls/oott123/novnc.svg)](https://hub.docker.com/r/oott123/novnc/) [![Docker Automated build](https://img.shields.io/docker/automated/oott123/novnc.svg)](https://hub.docker.com/r/oott123/novnc/)

tigervnc, websokify, novnc and Nginx with s6-overlay in a docker image.

## Environment variables

* **`VNC_GEOMETRY`** - VNC geometry; default: `800x600`
* **`VNC_PASSWD`** - VNC password, no more than 8 chars; default: `MAX8chars`
* **`USER_PASSWD`** - user `user` password. If you specify it, it will change the password for user `user` and add it to sudoers. NOTE: This password can get by programs so it's not safe. default: _(blank)_

## Ports

* **5911** - tigervnc
* **9000** - Nginx
* **9001** - websockify

## Add your foreground process

`vncmain.sh` is a file which is a placeholder for foreground process running in VNC.

You can write a Dockerfile like this:

```Dockerfile
FROM oott123/novnc:latest
COPY vncmain.sh /app/vncmain.sh
```

And add foreground commands in your `vncmain.sh`:

```bash
#!/bin/bash
# Set them to empty is NOT SECURE but avoid them display in random logs.
export VNC_PASSWD=''
export USER_PASSWD=''

xterm
```

Then build and run your docker image. That's it!
