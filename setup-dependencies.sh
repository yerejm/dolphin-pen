#!/bin/sh
echo "Installing vagrant-cachier plugin"
vagrant plugin list | grep vagrant-cachier >/dev/null 2>&1
if [ "$?" != "0" ]; then
  vagrant plugin install vagrant-cachier
fi

echo "Installing vagrant-hostsupdater plugin"
vagrant plugin list | grep vagrant-hostsupdater >/dev/null 2>&1
if [ "$?" != "0" ]; then
  vagrant plugin install vagrant-hostsupdater
fi

echo "Updating /etc/hosts"
grep buildbot.dev /etc/hosts >/dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "
172.118.70.40  buildbot.dev fifoci.dev changes.dev central.dev dl.dev
172.118.70.46  www.dev
" | sudo tee -a /etc/hosts
fi

echo "Updating ~/.ssh/config"
grep '*build' "${HOME}/.ssh/config" >/dev/null 2>&1
if [ "$?" != "0" ]; then
  sudo echo "
# vagrant virtual machine range
Host 172.118.70.* master *build www
StrictHostKeyChecking no
UserKnownHostsFile=/dev/null
User root
LogLevel ERROR
IdentityFile ~/.ssh/id_rsa" >> "${HOME}/.ssh/config"
fi

echo "Creating repository mirrors"
sh mirror.sh create

if [ ! -f "ansible/vars/secrets.yml" ]; then
  echo "A secrets file should now be created."
fi

