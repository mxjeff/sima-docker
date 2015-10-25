#!/bin/sh

DIR=$(dirname $(readlink -f $0))

ICE_PORT=${ICEPORT:-8001}
MPD_PORT=${MPDPORT:-6601}
LISTEN=${LISTEN:-127.0.0.1}

# make output verbose
#set -o xtrace -o nounset

_conf () {
    # Get the latest icecast conf
    docker run --rm sima -v ${DIR}:/tmp/ debian:latest cp -f /icecast/icecast.xml /tmp/current.icecast.conf.xml
}

log_icecast () {
    # Monitor logs
    docker exec -ti sima /usr/bin/tail -F /var/log/icecast2/access.log /var/log/icecast2/error.log
}

build () {
    # Build image with icecast
    docker build -t kaliko/sima ${DIR}/sima
}

log () {
    if [ "$(docker inspect --format='{{.State.Running}}' sima)" = "true" ]; then
        docker logs -f sima
    fi
}

stop () {
    docker stop -t 3 sima
}

inspect () {
    docker port sima | awk '$1 ~ "6600/tcp" { printf "MPD running on: %s\n", $3 }'
    docker port sima | awk '$1 ~ "8000/tcp" { printf "HTTP running on: http://%s\n", $3 }'
}

run () {
    # Start
    IS_RUNNING=$(docker inspect --format='{{.State.Running}}' sima)
    case $IS_RUNNING in
        true)
            echo 'Already running container'
            ;;
        false)
            echo 'running the current sima container'
            docker start sima
            ;;
        else)
            test -z "${MUSIC}" && { echo "Need a music directory to mount please set MUSIC var"; exit 1; }
            echo 'launching a new sima container'
            local options="-p ${LISTEN}:${ICE_PORT}:8000"
            options="${options} -p ${LISTEN}:${MPD_PORT}:6600"
            options="${options} --volume ${MUSIC}:/var/lib/mpd/music:ro"
            docker run ${options} --detach=true --name sima kaliko/sima
            ;;
    esac
}

$@
