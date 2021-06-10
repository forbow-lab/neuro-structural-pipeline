#!/bin/bash

EDIR=/shared/uher/FORBOW/rawdata
echo "Experiment-Directory: $EDIR"

cd $EDIR/

for Subj in $(/bin/ls -d 0*) ; do
	S=$(basename $Subj)
	SDIR="$EDIR/$S"
	if [ ! -d "$SDIR" ]; then
		echo "*** ERROR: cannot locate subject-dir = $SDIR"
		continue
	fi
	if [ ! -d "$SDIR/DICOMS" ]; then
		echo "*** ERROR: cannot locate $SDIR/DICOMS"
		continue
	fi
	
	T1dirs=$(find $SDIR/DICOMS -maxdepth 1 -type d -name "*T1w_BRAVO_sag*" -print)
	if [ x"$T1dirs" == x ]; then
		echo "***ERROR: cannot find any T1w_BRAVO_sag folder for subject=$S"
		continue
	fi
	
	for d in $T1dirs ; do
		images=$(find $d -maxdepth 2 -type f -name "IM-00??-0001.dcm" -print)
		if [ x"$images" == x ]; then
			echo "*** ERROR: cannot find a dicom image in folder: $d"
			continue
		fi
		for f in $images ; do 
			echo "$f:: `dicom_hdr $f | grep 'ACQ Scan Options'`"
		done
	done
	echo
done

exit 0
