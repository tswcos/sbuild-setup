#!/bin/bash

trap "exit" INT

build_profile="${PWD}/build-profile"
sbuild_status="${PWD}/sbuild-status"
repo_logfile="${PWD}/repo/logs/logfile"
repo_last_update_date=$(awk '{print $1}' $repo_logfile | tail -1)
last_update_pkgs=$(grep $repo_last_update_date $repo_logfile | awk '{print $8}')

touch $build_profile
touch $sbuild_status
for pkg in $last_update_pkgs; do
	dir=`find repo/pool/ -name $pkg`
	if [ "$dir" = "" ]; then continue; fi
	cd $dir

	ver=`cat $pkg_*.dsc | grep "^Version:"|head -1|cut -d' ' -f2 | sed -e "s/.*://"`
	profile=`grep "^$pkg " $build_profile | cut -d' ' -f2`
	profile_option=""
	if [ "$profile" != "" ]; then
		profile_option="--profiles=$profile"
	fi

	rm -rf *.build *.buildinfo *.udeb *.deb *.changes
	sbuild --jobs=16 ${profile_option} --host=armhf -d unstable-amd64-sbuild $pkg_*.dsc

	buildlog=${pkg}_${ver}_armhf.build
	output="$pkg $ver $(grep "^Status:" $buildlog | cut -d' ' -f2) $(grep "Finished at" $buildlog|tail -1|sed -e "s/Finished at //")"

	cd -
	if grep "^$pkg " $sbuild_status; then
		sed -i -e "s@^$pkg .*@$output@" $sbuild_status
	else
		echo $output >> $sbuild_status
	fi
done

sort $sbuild_status > ./tmpstatus
mv ./tmpstatus $sbuild_status
