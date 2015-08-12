# mm

## What?

A virtualised simulation of the [Dolphin Emulator](https://dolphin-emu.org)
project's [build infrastructure](https://dolphin-emu.org/blog/2015/01/25/making-developers-more-productive-dolphin-development-infrastructure/).

## Start

### Pre-requisites

* Vagrant and Virtualbox must already be installed.
* Vagrant boxes must already be created (refer to Vagrantfile).
  * Ubuntu 15.04
  * Debian 8.1
  * OS X 10.10
  * Windows 8.1
* The host has created ssh keys.
* Python 3 has been installed.

### setup-dependencies.sh

This will:
* Install vagrant-cachier plugin
* Install vagrant-hostsupdater plugin
* Update /etc/hosts for the virtual machines
* Update ~/.ssh/config for the virtual machines
* Create a repository mirror for all remote repositories
* Create an empty ansible/vars/secrets.yml

Manual steps required are to:
* Edit secrets.yml to override the default repository URLs and any other
  settings (e.g. apt mirror URLs).
* In ansible/dff, execute initdff.py with Python 3.

### boot.sh

This will execute vagrant up. This is a wrapper around vagrant up, so boot.sh
can be considered interchangeable with vagrant up. The benefit with boot.sh is
that it will maintain the sudo privilege while vagrant brings the servers up.
This is required for the vagrant-hostsupdater plugin to update /etc/hosts and
the time to bring all hosts up may exceed the sudo privilege time out.

#### Examples

To boot all servers:

    boot.sh

To boot only the master server:

    boot.sh master

To boot the master and www servers:

    boot.sh master,www

### provision.sh

This is a wrapper that executes ansible-playbook with the appropriate inventory
file and the appropriate playbook. Command line usage should be considered
interchangeable with ansible-playbook.

#### Examples

To run tasks for all servers:

    provision.sh

To run tasks for the master server:

    provision.sh -l master

To run tasks for the master and www servers that have the nginx tag:

    provision.sh -l master,www --tags=nginx

## How?

[Virtualbox](https://www.virtualbox.org/) runs the virtual machines.

[Packer](https://www.packer.io/) builds the virtual machines. Build files are
available from the [boxcutter github area](https://github.com/boxcutter).

[Vagrant](https://www.vagrantup.com/) manages the virtual machines. The plugins
[vagrant-cachier](http://fgrehm.viewdocs.io/vagrant-cachier) and
[vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
are recommended.

[Ansible](http://www.ansible.com) provisions the virtual machines.

The [dolphin-emu](https://github.com/dolphin-emu) repositories used are:
* [dolphin](https://github.com/dolphin-emu/dolphin)
* [sadm](https://github.com/dolphin-emu/sadm)
* [fifoci](https://github.com/dolphin-emu/fifoci)
* [ext-win-qt](https://github.com/dolphin-emu/ext-win-qt)
* [www](https://github.com/dolphin-emu/www)

The virtual machines created are:
* master - Buildbot master, central server, fifoci front end
* ububuild - Ubuntu buildbot slave
* debbuild - Debian buildbot slave
* osxbuild - OS X buildbot slave
* winbuild - Windows buildbot slave
* dffbuild - fifoci buildbot slave
* www - web server duplicate of dolphin-emu.org and IRC server

The build infrastructure simulated includes anything involved in the flow of the
build process.
* Changes are detected by polling the dolphin repository and submitted to the
  buildbot master (master).
* Builds are dispatched to the build slaves (master -> ububuild, debbuild,
  osxbuild, winbuild).
* Successful builds are packaged on the build slave and uploaded to the build
  master (slaves -> master).
* Successful builds update the web server with links to the builds (master ->
  www)
* Successful builds cause a fifoci test run (master -> dffbuild) with results
  uploaded to the build master and posted to the fifoci front end (dffbuild ->
  master).
* Build failure notifications and buildbot commands can be viewed on the irc
  server (master -> www).

All operations within the build infrastructure are localised to the private
Virtualbox network. There should be no traffic with any server in the
dolphin-emu.org domain range (or with the freenode irc server).

The central and buildmaster IRC bots will connect to the #dolphin-dev channel on
the IRC server (www).

At least 16 GB RAM is required for all servers to be up.

## Exclusions

* github hooks - these require a public server for github to call (major - PR
  and WiP builds are not possible)
* wiki update - this only updates the latest build number (minor - errors are
  ignored by dolphin-emu)
* Hardware slaves - these require servers with real GPU hardware (major - OpenGL
  capabilities come from the VM)
* Amazon cloud servers
* Android build slave

