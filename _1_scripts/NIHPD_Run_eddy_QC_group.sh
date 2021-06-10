#!/bin/bash

## $ cd /shared/uher/FORBOW/NIHPD_analysis/
## $ ./_1_scripts/FSv6_run_eddy_QC_group.sh `/bin/ls -d ???_? ???_?_NP ???_?_FLAIR`

Usage() {
	echo
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 001_A_NP 001_C_FLAIR"
	echo
	echo "Example:  cd /shared/uher/FORBOW/NIHPD_analysis/" 
	echo "          ./_1_scripts/`basename $0` \`/bin/ls -d ???_?_FLAIR\`"
	echo
	exit 1
}


SCRIPT=$(python -c "import os; print os.path.abspath('$0')")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${ANALYSIS_DIR}" ]]; then						#/shared/uher/FORBOW/NIHPD_analysis
	source "$SCRIPTSDIR/NIHPD_SetupEnvironment.sh"
fi

[ "$#" -lt 1 ] && Usage


DSTR=$(date +%Y%m%d)
EQC_OUTDIR="${ANALYSIS_DIR}/_2_results/eddyqc_group"
EQC_DIR_LIST="${ANALYSIS_DIR}/_2_results/eddyqc_group_dirlist.txt"
EQC_SSID_LIST="${ANALYSIS_DIR}/_2_results/eddyqc_group_SSIDs.txt"
rm -f ${EQC_DIR_LIST} ${EQC_SSID_LIST} >/dev/null
VISUALIZE_RESULTS="no"


SUBJECTS="$@"
echo
echo "ANALYSIS_DIR:    $ANALYSIS_DIR"
echo "SUBJECTS:  $SUBJECTS "

## build list of subjects with data_ec.qc folders...
for Subj in $SUBJECTS ; do
	S=$(basename $Subj)
	SDIR="$ANALYSIS_DIR/$S"
	qcDIR="$SDIR/DWI/2_eddy/data_ec.qc"
	if [ ! -d "$qcDIR" ]; then
		echo " * NOTE: $S is missing $qcDIR"
	else
		echo "$S" >>${EQC_SSID_LIST}
		echo "$qcDIR" >>${EQC_DIR_LIST}
	fi
done

## run Group EddyQC
if [ -f "$EQC_DIR_LIST" ]; then
	rm -rf ${EQC_OUTDIR}/ >/dev/null
	eddy_squad ${EQC_DIR_LIST} -o ${EQC_OUTDIR}
	echo " ++ writing eddy_squad results to ${EQC_OUTDIR}/group_db.json"
	if [ "$VISUALIZE_RESULTS" == "yes" -a -f "${EQC_OUTDIR}/group_db.json" ]; then 
		if [ "`uname -s`" == "Linux" ]; then
			evince ${EQC_OUTDIR}/group_qc.pdf &
		else
			open -a /Applications/Preview.app ${EQC_OUTDIR}/group_qc.pdf
		fi
	fi
fi

## reformat Group EddyQC output jsonfile into csv file
if [ -f "${EQC_OUTDIR}/group_db.json" ]; then
	echo " ++ reformatting ${EQC_OUTDIR}/group_db.json --> ${EQC_OUTDIR}/group_db.csv"
	${SCRIPTSDIR}/NIHPD_reformat_eddyQC_json2csv.py ${EQC_OUTDIR}/group_db.json ${EQC_SSID_LIST}
fi

echo

exit 0
