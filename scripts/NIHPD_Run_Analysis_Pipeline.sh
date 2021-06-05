#!/bin/bash

Usage() {
	echo
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 012_C_FLAIR"
	echo
	exit 1
}

if [ "`uname -n`" != "jaylah" ]; then
    echo "*** ERROR: this program must be run from Jaylah...exiting"
    exit 1
fi


SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${ANALYSIS_DIR}" ]]; then
	source "$SCRIPTSDIR/NIHPD_SetupEnvironment.sh"
fi

run_full_pipeline() {
	echo "--------------------------------------------------------------------"
	echo "`date`: starting full-pipeline on subject=${S}" 
	${SCRIPTSDIR}/NIHPD_0_setup_unprocessed.sh ${S:0:5}
	if [ ! -f "${SDIR}/T1w/${S}/stats/aseg.stats" ]; then
		${SCRIPTSDIR}/NIHPD_1_PreFreeSurferPipelineBatch.sh --Subject=${S}
		${SCRIPTSDIR}/NIHPD_2_FreeSurferPipelineBatch.sh --Subject=${S}
		${SCRIPTSDIR}/NIHPD_3_PostFreeSurferPipelineBatch.sh --Subject=${S}
	fi
	${SCRIPTSDIR}/NIHPD_4_LGI_run_freesurfer.sh ${S}
	${SCRIPTSDIR}/NIHPD_5_dwi_preproc.sh ${S}
	${SCRIPTSDIR}/NIHPD_6_dwi_create_vector_ROIs.sh ${S}		##needs all other scripts run first
	${SCRIPTSDIR}/NIHPD_7_QC_report_freesurfer_CNR.sh ${S}
	${SCRIPTSDIR}/NIHPD_8_myelin_report_aparc_results.sh ${S}
	echo "`date`: finished full-pipeline on subject=${S}" 
	echo "--------------------------------------------------------------------"
}

[ "$#" -lt 1 ] && Usage
SUBJECTS="$@"
for Subj in ${SUBJECTS} ; do 
	S=$(basename ${Subj})
	if [ "${#S}" -eq 5 ]; then
		S="${S}_FLAIR"
	fi
	if [ "${#S}" -ne 11 -o "${S:5:6}" != "_FLAIR" ]; then
		echo "*** ERROR: cannot create specified subject=${S}"
		continue
	fi
	SDIR="${ANALYSIS_DIR}/${S}"
	echo " -- starting `basename $0` on $SDIR/, `date`"
	mkdir -p ${SDIR}/logs/
	cd ${SDIR}/logs/
	LOG="${SDIR}/logs/${S}_full_pipeline.txt"
	run_full_pipeline ${S} >>$LOG 2>&1
	echo " -- completed `basename $0` on $SDIR/, `date`"
done

exit 0
