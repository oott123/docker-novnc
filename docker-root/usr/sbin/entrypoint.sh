#!/command/with-contenv /bin/bash
set -eo pipefail

[[ $DEBUG == true ]] && set -x

export VNC_PASSWORD=''
export DISPLAY=:11

case ${1} in
  help)
    echo "No help!"
    ;;
  start)
    echo "Starting TigerVNC..."
    s6-svc -T 5000 -u /var/run/s6-rc/servicedirs/tigervnc
    sleep 2
    echo "Starting Websocketify..."
    s6-svc -T 5000 -u /var/run/s6-rc/servicedirs/websocketify
    sleep 2
    echo "Starting Nginx..."
    s6-svc -T 5000 -u /var/run/s6-rc/servicedirs/nginx
    sleep 2
    sudo --preserve-env -Hu user /app/vncmain.sh "$@"
    ;;
  *)
    exec "$@"
    ;;
esac

exit 0
