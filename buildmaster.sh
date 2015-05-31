#!/bin/sh
set -eu
set -o pipefail
ansible-playbook ansible/all.yml -i ansible/inventory -e 'testing=yes' -l master

