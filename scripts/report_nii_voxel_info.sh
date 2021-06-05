#!/bin/bash
# TO RUN: 
#  for S in `/bin/ls -d 0??_*`; do ./_1_scripts/report_nii_voxel_info.sh $S/unprocessed >$S/unprocessed/metadata.csv; done
#

Usage(){
	echo "Usage:`basename $0` </path/to/NIFTI-files>"
	exit 1
}


[ "$#" -lt 1 ] && Usage

isFirst=true
for arg in $@ ; do
	D=$(python -c "import os; print os.path.abspath('$arg')")
	#if [ ! -d "$D" ]; then
	#	echo "Warning: cannot find specified path = $D"
	#	continue
	#fi
	#echo "-- searching for nifti (.nii or .nii.gz) files in path = $D"
	for f in $(find $D -type f -name "*.nii*"); do
		if $isFirst ; then
			echo "file,$(3dinfo -hdr -n4 -ad3 -tr -voxvol $f | head -1 | sed -E 's|[[:space:]]+|,|g')"
			isFirst=false 
		fi
		echo "`basename $f`,$(3dinfo -n4 -ad3 -tr -voxvol $f | sed -E 's|[[:space:]]+|,|g')"
	done

done

exit 0
