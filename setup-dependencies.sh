#!/bin/sh
vagrant plugin list | grep vagrant-cachier >/dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "Installing vagrant-cachier plugin"
  vagrant plugin install vagrant-cachier
fi

vagrant plugin list | grep vagrant-hostsupdater >/dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "Installing vagrant-hostsupdater plugin"
  vagrant plugin install vagrant-hostsupdater
fi

grep buildbot.dev /etc/hosts >/dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "Updating /etc/hosts"
  echo "
172.30.70.40  buildbot.dev fifoci.dev changes.dev central.dev dl.dev
172.30.70.46  www.dev
" | sudo tee -a /etc/hosts
fi

grep '*build' "${HOME}/.ssh/config" >/dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "Updating ~/.ssh/config"
  echo "
# vagrant virtual machine range
Host 172.30.70.* master *build www
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
User root
LogLevel ERROR
IdentityFile ~/.ssh/id_rsa" >> "${HOME}/.ssh/config"
fi

if [ ! -d "mirror" ]; then
  echo "Creating repository mirrors"
  sh mirror.sh create
  sh mirror.sh start
fi

if [ ! -f "ansible/vars/secrets.yml" ]; then
  echo "Creating ansible/vars/secrets.yml is recommended."
fi

if [ ! -f "ansible/dff/dff.sql" ]; then
  echo "Priming the ansible/dff area is recommended."
fi

echo "Ready to go."

