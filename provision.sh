#!/bin/sh
ansible-playbook -i ansible/inventory ansible/all.yml $@

