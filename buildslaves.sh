#!/bin/sh
set -eu
set -o pipefail
ansible-playbook ansible/ping.yml -i ansible/inventory
rc=$?
if [ "$rc" != "0" ]; then
    echo "Servers not ready..."
    exit $rc
fi
ansible-playbook ansible/buildslaves.yml -i ansible/inventory

