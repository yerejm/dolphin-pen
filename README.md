# mm

## What?

A virtualised simulation of the [Dolphin Emulator](https://dolphin-emu.org) project's [build infrastructure](https://dolphin-emu.org/blog/2015/01/25/making-developers-more-productive-dolphin-development-infrastructure/).

## How?

[Virtualbox](https://www.virtualbox.org/) runs the virtual machines.

[Packer](https://www.packer.io/) builds the virtual machines. Build files are available from the [boxcutter github area](https://github.com/boxcutter).

[Vagrant](https://www.vagrantup.com/) manages the virtual machines. The Vagrant [cache plugin](http://fgrehm.viewdocs.io/vagrant-cachier) is recommended.

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
* www - web server duplicate of dolphin-emu.org

The build infrastructure simulated includes anything involved in the flow of the build process.
* Changes are detected by polling the dolphin repository and submitted to the buildbot master (master).
* Builds are dispatched to the build slaves (master -> ububuild, debbuild, osxbuild, winbuild).
* Successful builds are packaged on the build slave and uploaded to the build master (slaves -> master).
* Successful builds update the web server with links to the builds (master -> www)
* Successful builds cause a fifoci test run (master -> dffbuild) with results uploaded to the build master and posted to the fifoci front end (dffbuild -> master).
* Build failure notifications and buildbot commands can be viewed on the irc server (master -> www).

Exclusions are:
* github hooks - these require a public server for github to call (major - PR and WiP builds are not possible)
* wiki update - this only updates the latest build number (minor - errors are ignored by dolphin-emu)
* hardware slaves - these require servers with real GPU hardware (major - OpenGL capabilities come from the VM)

All operations within the build infrastructure are localised to the private Virtualbox network. There should be no traffic with any server in the dolphin-emu.org domain range (or with the freenode irc server).

At least 16 GB RAM is required for all servers to be up.

## Why?

* An exploration of the Dolphin build infrastructure (buildbot)
* An exploration of Ansible
* An exploration of Packer
* An exploration of Vagrant
* An exploration of provisioning automation for Linux, OS X, and Windows.
* An evaluation of what is required for cross platform development and continuous test/integration/delivery.
