_NOTE: You can setup build system quickly with docker by running scripts in [./scripts](./scripts), or you can follow the below steps for manual setup on your machine._

# Setup sbuild
### Install sbuild
On Debian Jessie, sbuild needs be installed from jessie-backports
because current sbuild of jessie does not work with gnupg2 of Buster
(Bug [#827315](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=827315))
```sh
$ echo "deb http://ftp.debian.org/debian jessie-backports main" | sudo tee -a /etc/apt/sources.list
$ sudo apt-get update
$ sudo apt-get -t jessie-backports install sbuild
```

### Configure user
```sh
$ sudo mkdir /root/.gnupg # To work around #792100; not needed post-Jessie
$ sudo sbuild-update --keygen # Not needed since sbuild 0.67.0 (postJessie, see #801798)
$ sudo sbuild-adduser $LOGNAME
```
*logout* and *re-login* or use `newgrp sbuild` in your current shell

### Create sbuild chroot
```sh
$ sudo sbuild-createchroot --include=debhelper unstable ./chroot-sbuild http://ftp.debian.org/debian
```
You should change the URL to your Debian fastest mirror.

### Update build script
Check name of chroot which has just been created,
then you can use it to run cross-build:
```sh
$ schroot -l | grep sbuild
chroot:unstable-amd64-sbuild

## You can try running sbuild with command
$ sbuild --host=armhf -d unstable-amd64-sbuild <package>.dsc
```
Update command sbuild in [sbuild-loop.sh](./sbuild-loop.sh) with your chroot.
# Setup reprepro
"reprepro is a tool to manage a repository of Debian packages (.deb, .udeb, .dsc, ...)."
```sh
$ sudo apt-get install reprepro
```
Config for reprepro has been created in [repo/conf](./repo/conf).
You should change the URL in *./repo/conf/updates* to your Debian fastest mirror.
It will save time on fetching.

In [repo/conf/distributions](./repo/conf/distributions),
local repo is defined with codename *unstable-cross*.
You can update source for local repo with command:
```sh
$ reprepro -b ./repo update unstable-cross
```

Packages, which we want to fetch, are listed in [repo/conf/filters/pkglist](./repo/conf/filters/pkglist)

# Run
Set cron job to fetch source code and run sbuild weekly.
[sbuild-loop.sh](./sbuild-loop.sh) only builds newest packages (base on *repo/logs/logfile*)
```sh
$ crontab -e
0 0 * * 6 cd <this dir> && reprepro -b ./repo update unstable-cross && ./sbuild-loop.sh
```

# References
<https://wiki.debian.org/sbuild>

<https://wiki.debian.org/Schroot>

<https://wiki.debian.org/CrossCompiling>

<https://wiki.linaro.org/Platform/DevPlatform/CrossBuildd>
