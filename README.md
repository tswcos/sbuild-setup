## Setup sbuild
```sh
$ sudo apt-get install sbuild
$ sudo mkdir /root/.gnupg # To work around #792100; not needed post-Jessie
$ sudo sbuild-update --keygen # Not needed since sbuild 0.67.0 (postJessie, see #801798)
$ sudo sbuild-adduser $LOGNAME
```
*logout* and *re-login* or use `newgrp sbuild` in your current shell

Create sbuild chroot
```sh
$ sudo sbuild-createchroot unstable ./chroot-sbuild http://debian.xtdv.net/debian
```
You should change the URL to your Debian fastest mirror.

Check name of chroot which has just been created,
then you can use it to run cross-build:
```sh
$ schroot -l | grep sbuild
chroot:unstable-amd64-sbuild
$ sbuild --host=armhf -d unstable-amd64-sbuild <package>.dsc
```
Update command sbuild in [sbuild-loop.sh](./sbuild-loop.sh) with your chroot.
## Setup reprepro
"reprepro is a tool to manage a repository of Debian packages (.deb, .udeb, .dsc, ...)."
```sh
$ sudo apt-get install reprepro
```
Config for reprepro has been created in [repo/conf](./repo/conf).
You should change the URL in *./repo/conf/updates* to your Debian fastest mirror.
It will save time on fetching.

In [repo/conf/distributions](./repo/conf/distributions),
local repo is defined with codename *sid-cross*.
You can update source for local repo with command:
```sh
$ reprepro -b ./repo update sid-cross
```

Packages, which we want to fetch, are listed in [repo/conf/filters/pkglist](./repo/conf/filters/pkglist)

## Run
Set cron job to fetch source code and run sbuild weekly.
[sbuild-loop.sh](./sbuild-loop.sh) will cross compile all packages in *pkglist*
```sh
$ crontab -e
0 0 * * 6 cd <this dir> && reprepro -b ./repo update sid-cross
0 2 * * 6 cd <this dir> && ./sbuild-loop.sh
```

## References
<https://wiki.debian.org/sbuild>

<https://wiki.debian.org/Schroot>

<https://wiki.debian.org/CrossCompiling>

<https://wiki.linaro.org/Platform/DevPlatform/CrossBuildd>