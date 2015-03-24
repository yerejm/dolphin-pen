#!/usr/bin/env bash
set -o errexit
set -o nounset
# set -o xtrace
set -o pipefail

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"

echo "################################"
echo "Build Information"
echo "Directory: ${__DIR__}"
echo "Filename: ${__FILE__}"
echo "Version Information:"
echo "Ansible Version: $(ansible --version)"
echo "Ansible Playbook Version: $(ansible-playbook --version)"
echo "Operating System: $(uname -s)"
echo "Kernel: $(uname -v)"
echo "################################"

echo "### Starting tests"

find ./ansible -maxdepth 1 -name '*.yml'| xargs -n1 ansible-playbook --syntax-check --list-tasks -i ansible/inventory -l local
