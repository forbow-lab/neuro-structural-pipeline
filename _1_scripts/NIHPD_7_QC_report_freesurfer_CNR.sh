#!/bin/bash

#-------------------------------------------------------------
# RUN:
#  $ cd /shared/uher/FORBOW/analysis
#  $ ./_1_scripts/QC_report_freesurfer_CNR.sh 012_C_FLAIR
#-------------------------------------------------------------
Usage(){
	echo
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 001_A_FLAIR "
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


HDR="file,lh-GrayWhiteCNR,lh-GrayCsfCNR,lh-Wm,lh-Gm,lh-CSFm,lh-Wv,lh-Gv,lh-CSFv,rh-GrayWhiteCNR,rh-GrayCsfCNR,rh-Wm,rh-Gm,rh-CSFm,rh-Wv,rh-Gv,rh-CSFv"

DSTR=$(date +%Y%m%d)
RFILE="$ANALYSIS_DIR/_2_results/${DSTR}_QC_FreeSurfer_T1w_CNR.csv"
echo "$HDR" >$RFILE
echo $HDR


SUBJECTS="$@"
echo "input-args=$SUBJECTS"

cd $ANALYSIS_DIR/
for Subj in $SUBJECTS ; do 	##`/bin/ls -d $SUBJECTS`; do
	S=$(basename $Subj)
	SDIR="$ANALYSIS_DIR/$S"
	if [ ! -d "$SDIR/T1w" ]; then
		echo "*** ERROR: cannot find directory = $SDIR/T1w"
		continue
	fi
	cd $SDIR/
	
	echo "--------- running `basename $0` on `pwd`/T1w, starting `date`"
	cnrlog=$SDIR/logs/${S}_T1w_cnr.txt
	if [ "$FORCE_OVERWRITE" == "yes" ] ; then
		rm -f ${cnrlog} >/dev/null
	fi
	
	if [ ! -r "$cnrlog" ]; then
		outputCNR=$(mri_cnr -l $cnrlog $SDIR/T1w/${S}/surf $SDIR/T1w/${S}/mri/orig.mgz)
	fi
	if [ "x$(echo $outputCNR | grep 'No such file or directory')" != "x" ]; then
		echo "*** ERROR: could not find files: $SDIR/T1w/${S}/mri/orig.mgz"
		continue
	elif [ ! -r "$cnrlog" ]; then
		echo "*** ERROR: could not find CNRlog = $cnrlog"
		continue
	fi
	row=$($SCRIPTSDIR/qc_clean_cnr_results.py ${cnrlog})
	echo "$row" >>$RFILE
done

if [ "`uname -s`" != "Linux" ]; then
	echo  " ------ saving QC results into $RFILE"
	#open -a /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app $RFILE
else
	echo  " ------ saving QC results into $RFILE"
	#libreoffice $RFILE &
fi

exit 0


# -- https://mail.nmr.mgh.harvard.edu/pipermail/freesurfer/2012-August/025251.html  ------->
# Just a Gaussian noise model and the CNR is the average of
# the gray/white and gray/csf cnr:
#
# gray_white_cnr = SQR(gray_mean - white_mean) / (gray_var+white_var) ;
# gray_csf_cnr = SQR(gray_mean - csf_mean) / (gray_var+csf_var) ;
# <-------


#-- calculating CNR for subject = FMS3_CH_1a
# processing MRI volume FMS3_CH_1a/mri/orig.mgz...
# 	white = 88.0+-7.6, gray = 68.7+-13.6, csf = 52.8+-13.8
# 	gray/white CNR = 1.532, gray/csf CNR = 0.671
# lh CNR = 1.102
# 	white = 86.1+-6.9, gray = 67.5+-13.0, csf = 52.1+-13.6
# 	gray/white CNR = 1.607, gray/csf CNR = 0.669
# rh CNR = 1.138
# total CNR = 1.120
