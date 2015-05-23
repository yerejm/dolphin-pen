#!/usr/bin/sh
vagrant destroy -f
vagrant up
sh playbooktest.sh
sh buildmaster.sh
sh buildslaves.sh

