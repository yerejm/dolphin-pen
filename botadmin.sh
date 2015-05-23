#!/bin/sh
set -e
set -o pipefail
BUILDBOT_TYPE=${1}
if [[ -z "$BUILDBOT_TYPE" ]]; then
    echo "Missing buildbot type: $0 master|slave|all start|stop|restart"
    exit 2
fi
BUILDBOT_STATE=${2}
if [[ -z "$BUILDBOT_STATE" ]]; then
    echo "Missing buildbot state: $0 master|slave|all start|stop|restart"
    exit 2
fi

LIMIT=""
case "$BUILDBOT_TYPE" in
    master) LIMIT="-l buildmaster" ;;
    slave) LIMIT="-l buildslaves" ;;
    all) ;;
    *) LIMIT="-l $BUILDBOT_TYPE" ;;
esac
case "$BUILDBOT_STATE" in
  start|stop|restart)
    ansible-playbook ansible/admin.yml \
      -i ansible/inventory \
      -e "buildbot_state=$BUILDBOT_STATE" \
      $LIMIT
    exit $?
    ;;
  *)
    echo "Invalid buildbot state $BUILDBOT_STATE, expecting start, stop, or restart."
    ;;
esac
exit 1
