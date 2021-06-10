#!/bin/bash

Usage(){
	echo
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 001_A_NP 002_A_NP"
	echo
	exit 1
}


SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${ANALYSIS_DIR}" ]]; then
	source "$SCRIPTSDIR/NIHPD_SetupEnvironment.sh"
fi
echo "ANALYSIS_DIR: $ANALYSIS_DIR"
echo "SCRIPT: $SCRIPT"
echo "SCRIPTSDIR: $SCRIPTSDIR"


FORCE_OVERWRITE="no"
if [ "$1" == "-f" ] ; then
	FORCE_OVERWRITE="yes"
	shift ;
	echo " * enabling FORCE_OVERWRITE"
fi

[ "$#" -lt 1 ] && Usage


for Subject in $@ ; do

	S=$(basename ${Subject})
	SDIR="$ANALYSIS_DIR/$S"
	if [ ! -d "$SDIR/T1w" ]; then
		echo "ERROR: could not find subject directory: $SDIR/T1w/"
		continue
	fi
	cd $SDIR/T1w/
	export SUBJECTS_DIR="$SDIR/T1w"

	mkdir -p "$SDIR/logs"
	MainLog="$SDIR/logs/${S}_mainlog.txt"
	LOG="$SDIR/logs/${S}_LGI_processing.log"
	
	
	RH_lgi_file="$SDIR/T1w/$S/stats/rh.aparc.pial_lgi.stats"
	LH_lgi_file="$SDIR/T1w/$S/stats/lh.aparc.pial_lgi.stats"
	if [ "$FORCE_OVERWRITE" == "yes" ] ; then
		rm -f ${LH_lgi_file} ${RH_lgi_file} >/dev/null
	fi
	if [ -r "${LH_lgi_file}" -a -r "${RH_lgi_file}" ]; then
		echo " * LGI_recon-all already completed, remove following files to run again: "
		echo "   + ${RH_lgi_file}"
		echo "   + ${LH_lgi_file}"
		echo
		continue
	fi
	
	
	TS=${SECONDS}
	T="--------------------------------------------------------------------\n-- starting recon-all -localGI on subject=$S, `date`"
	echo -e $T; echo -e $T >>$LOG ; echo -e $T >>$MainLog
	if [ -r "$SDIR/T1w/$S/scripts/IsRunning.lh+rh" ]; then
		echo "-- removing file: $SDIR/T1w/$S/scripts/IsRunning.lh+rh" >>$LOG
		rm -f "$SDIR/T1w/$S/scripts/IsRunning.lh+rh" >/dev/null
	fi
	recon-all -s ${S} -localGI -openmp ${OMP_NUM_THREADS} >>$LOG
	
	T=" ++ running mri_segstats on lh.pial_lgi for ${S}, `date`" 
	echo $T; echo $T >>$LOG ; echo $T >>$MainLog
	mri_segstats --annot ${S} lh aparc --i ${SUBJECTS_DIR}/${S}/surf/lh.pial_lgi --sum ${SUBJECTS_DIR}/${S}/stats/lh.aparc.pial_lgi.stats >>$LOG
	
	T=" ++ running mri_segstats on rh.pial_lgi for ${S}, `date`" 
	echo $T; echo $T >>$LOG ; echo $T >>$MainLog
	mri_segstats --annot ${S} rh aparc --i ${SUBJECTS_DIR}/${S}/surf/rh.pial_lgi --sum ${SUBJECTS_DIR}/${S}/stats/rh.aparc.pial_lgi.stats >>$LOG
	
	ET=$(($SECONDS - $TS))
	
	T="-- finished LGI processing of subject=$S at `date` \n-- Elapsed time:  $(($ET/60)) min, $(($ET%60)) \n"
	echo -e $T ; echo -e $T >>$LOG ; echo -e $T >>$MainLog
	
done


exit 0

