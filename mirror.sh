#!/bin/sh

CMD="$1"

set -eu
set -o pipefail
set -x

BASE=$(pwd)
DOLPHIN_BASE_URL=https://github.com/dolphin-emu
MIRROR_DIR="${BASE}/mirror"
GIT_PID="${MIRROR_DIR}/git-daemon.pid"
HG_PID="${MIRROR_DIR}/hg-daemon.pid"
GIT_REPOSITORIES="\
    ${DOLPHIN_BASE_URL}/dolphin \
    ${DOLPHIN_BASE_URL}/ext-win-qt \
    ${DOLPHIN_BASE_URL}/fifoci \
    ${DOLPHIN_BASE_URL}/sadm \
    ${DOLPHIN_BASE_URL}/www
    "

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
    mkdir -p "${MIRROR_DIR}"
    cd "${MIRROR_DIR}"
    for gitrepo in ${GIT_REPOSITORIES}; do
        git clone --mirror "${gitrepo}" || true
    done
    hg clone http://hg.libsdl.org/SDL "${MIRROR_DIR}/SDL" || true
}

update_clones() {
    for gitrepo in ${GIT_REPOSITORIES}; do
        echo "Updating ${gitrepo}"
        cd "${MIRROR_DIR}/$(basename ${gitrepo}).git"
        git fetch -p origin
    done

    echo "Updating SDL"
    cd "${MIRROR_DIR}/SDL"
    hg pull && hg update

    cd "${BASE}"
}

usage() {
    echo "${0} [create|start|stop|restart|destroy|update]"
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
    update)
        update_clones
        ;;
    *)
        echo "Unknown command ${CMD}"
        usage
        ;;
esac

exit 0

