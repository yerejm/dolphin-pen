#!/usr/bin/sh
set -eu
set -o pipefail

echo "You will be asked for a password!"
vagrant destroy -f winbuild osxbuild debbuild ububuild dffbuild master
vagrant up master dffbuild ububuild debbuild osxbuild winbuild
sh playbooktest.sh

rc=1
while [ "$rc" != "0" ]; do
    set +e
    ansible-playbook ansible/ping.yml -i ansible/inventory
    rc=$?
    set -e
    if [ "$rc" != "0" ]; then
        echo "Servers not ready... waiting"
        sleep 2
    fi
done

sh buildmaster.sh
sh buildslaves.sh

