#!/bin/sh
set -eu
set -o pipefail
ansible-playbook ansible/buildslaves.yml -i ansible/inventory -e 'testing=yes'

