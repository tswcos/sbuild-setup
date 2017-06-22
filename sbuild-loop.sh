#!/bin/bash
#
# sbuild-loop.sh: Script for run sbuild and summary result
# Copyright (C) 2017 Toshiba Corporation
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
#
#######################################################################


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
	sbuild --jobs=16 ${profile_option} --host=armhf -d buster-amd64-sbuild $pkg_*.dsc

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
