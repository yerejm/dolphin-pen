#!/bin/sh
set -eu
set -o pipefail
ansible buildslaves -m ping -i ansible/inventory -u root
rc=$?
if [ "$rc" != "0" ]; then
    echo "Servers not ready..."
    exit $rc
fi
ansible-playbook ansible/buildslaves.yml -i ansible/inventory

