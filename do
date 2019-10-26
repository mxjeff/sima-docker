#!/bin/sh

# make output verbose
#set -o xtrace -o nounset

ROOT=$(dirname $(readlink -f $0))
SCRIPT=$(basename $0)

_inspect () {
    # Auto generate help string
    local help=$(awk '$1 ~ /^[a-z]+_?[a-z]+$/ && $2 == "()" { printf "%s|", $1 }' $0)
    echo ${help%|}
}
_test () {
    local cmds='docker awk'
    for cmd in $cmds;do
        type $cmd >/dev/null 2>&1 || { echo "Missing '$cmd' command, please install"; return 1; }
    done
}
_test || exit 1
###############################################################################

ICE_PORT=${ICEPORT:-8001}
MPD_PORT=${MPDPORT:-6601}
LISTEN=${LISTEN:-127.0.0.1}

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
            return 2
            ;;
    esac
}

build () {
    # Build image with icecast
    docker build -t kaliko/sima ${ROOT}/sima
}

log () {
    _is_running && docker logs -f sima
}

discover () {
    arg=${1:-false}
    _is_running || { echo "No running container detected!"; exit 1; }
    docker port sima | awk '$1 ~ /^8000\/tcp.*/ { printf "# HTTP running on: http://%s\n", $3 }'
    docker port sima | awk '$1 ~ /^6600\/tcp.*/ { printf "# MPD running : %s\n", $3 }'
}

run () { start; }
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
                echo "MUSIC=~/Music ./do start";
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

if [ $# -eq 0 ]
then
    echo "${ROOT}/${SCRIPT} $(_inspect)"
    exit
fi

$1
