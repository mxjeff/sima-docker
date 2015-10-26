#!/bin/sh

DIR=$(dirname $(readlink -f $0))

ICE_PORT=${ICEPORT:-8001}
MPD_PORT=${MPDPORT:-6601}
LISTEN=${LISTEN:-127.0.0.1}

# make output verbose
#set -o xtrace -o nounset
_is_running () {
    IS_RUNNING=$(docker inspect --format='{{.State.Running}}' sima 2>&1)
    case $IS_RUNNING in
        true)
            return 0
            ;;
        false)
            return 1
            ;;
        *)
            #echo $IS_RUNNING
            return 2
            ;;
    esac
}

build () {
    # Build image with icecast
    docker build -t kaliko/sima ${DIR}/sima
}

log () {
    _is_running && docker logs -f sima
}

discover () {
    arg=${1:-false}
    _is_running || { echo "No running container detected!"; exit 1; }
    docker port sima | awk '$1 ~ /^8000\/tcp.*/ { printf "# HTTP running on: http://%s\n", $3 }'
    if [ $arg = "false" ];then
        docker port sima | awk -F: '$1 ~ /^6600\/tcp.*/ { printf "# MPD running on port: %s\n", $2 }'
    else
        docker port sima | awk -F: '$1 ~ /^6600\/tcp.*/ { printf "# MPD running on port: %s\nexport MPD_PORT=%s\n", $2, $2 }'
    fi
}

start () {
    # Start
    _is_running
    case $? in
        0)
            echo 'Already running container'
            ;;
        1)
            echo 'Running the current sima container'
            docker start sima
            ;;
        *)
            test -z "${MUSIC}" && { echo "# Need a music directory to mount, please set MUSIC var:";
                echo "MUSIC=~Music ./do start";
                exit 1; }
            echo 'launching a new sima container'
            local options="-p ${LISTEN}:${ICE_PORT}:8000"
            options="${options} -p ${LISTEN}:${MPD_PORT}:6600"
            options="${options} --volume ${MUSIC}:/music:ro"
            docker run ${options} --detach=true --name sima kaliko/sima
            ;;
    esac
    discover
}

stop () {
    _is_running && docker stop -t 3 sima
}

$@
