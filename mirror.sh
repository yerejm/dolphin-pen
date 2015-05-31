#!/bin/sh

CMD="$1"

set -eu
set -o pipefail

BASE=$(pwd)
MIRROR_DIR="${BASE}/mirror"
GIT_PID="${MIRROR_DIR}/git-daemon.pid"
HG_PID="${MIRROR_DIR}/hg-daemon.pid"

check_mirror_dir() {
    if [ -d "${MIRROR_DIR}" ]; then
        echo "Mirror: ${MIRROR_DIR}"
    else
        echo "No mirror at ${MIRROR_DIR}..."
        exit 1
    fi
}

stop_daemons() {
    for pid in "$GIT_PID" "$HG_PID"; do
        if [ -e "$pid" ]; then
            kill "$(cat "$pid")"
            rm -f "$pid"
        fi
    done
}

start_daemons() {
    echo "GIT: "
    git daemon --base-path="${MIRROR_DIR}" \
        --detach \
        --pid-file="${GIT_PID}" \
        --export-all
    echo "listening on $(hostname):9418"

    echo "HG: "
    hg serve --cwd "${MIRROR_DIR}/SDL" \
        --daemon \
        --pid-file="${HG_PID}" \
        --quiet
}

mirror() {
    if [ -d "${MIRROR_DIR}" ]; then
        echo "Mirror already exists. To recreate, destroy first."
        exit 1
    fi
    mkdir -p "${MIRROR_DIR}"
    git clone --mirror "${GITHUB_HOME}/dolphin.git" "${MIRROR_DIR}/dolphin.git"
    git clone --mirror "${GITHUB_HOME}/ext-win-qt" "${MIRROR_DIR}/ext-win-qt.git"
    git clone --mirror "${GITHUB_HOME}/fifoci.git" "${MIRROR_DIR}/fifoci.git"
    git clone --mirror "${GITHUB_HOME}/sadm.git" "${MIRROR_DIR}/sadm.git"
    hg clone http://hg.libsdl.org/SDL "${MIRROR_DIR}/SDL"
}

usage() {
    echo "${0} [create|start|stop|restart|destroy]"
    exit 2
}

case "$CMD" in
    create)
        mirror
        start_daemons
        ;;
    start)
        check_mirror_dir
        start_daemons
        ;;
    stop)
        check_mirror_dir
        stop_daemons
        ;;
    restart)
        check_mirror_dir
        stop_daemons
        start_daemons
        ;;
    destroy)
        if [ -d "${MIRROR_DIR}" ]; then
            echo "Destroying ${MIRROR_DIR} in 5 seconds..."
            sleep 5
            rm -rf "${MIRROR_DIR}"
        else
            echo "No existing mirror at ${MIRROR_DIR}..."
        fi
        ;;
    *)
        echo "Unknown command ${CMD}"
        usage
        ;;
esac

exit 0

