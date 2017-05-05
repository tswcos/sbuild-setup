#!/bin/bash

trap "exit" INT
rm -f sbuild-status
for pkg in `cat pkglist | cut -d' ' -f1`; do
	dir=`find repo/pool/ -name $pkg`
	if [ "$dir" = "" ]; then continue; fi
	cd $dir

	ver=`cat $pkg_*.dsc | grep "^Version:"|head -1|cut -d' ' -f2 | sed -e "s/.*://"`

	rm -rf *.build *.buildinfo *.udeb *.deb *.changes
	sbuild -j 16 --host=armhf -d unstable-amd64-sbuild $pkg_*.dsc

	buildlog=${pkg}_${ver}_armhf.build
	output="$pkg $ver $(grep "^Status:" $buildlog | cut -d' ' -f2) $(grep "Finished at" $buildlog|tail -1|sed -e "s/Finished at //")"

	cd -
	echo $output >> sbuild-status
done
