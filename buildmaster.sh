#!/bin/sh
set -eu
set -o pipefail
ansible buildmaster -m ping -i ansible/inventory -u root
rc=$?
if [ "$rc" != "0" ]; then
    echo "Servers not ready..."
    exit $rc
fi
ansible-playbook ansible/buildmaster.yml -i ansible/inventory -l buildmaster

