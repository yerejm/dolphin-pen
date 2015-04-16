#!/usr/bin/sh
vagrant destroy -f master ububuild debbuild osxbuild
vagrant up master ububuild debbuild osxbuild
sh playbooktest.sh
sh buildmaster.sh
sh buildslaves.sh

