#!/bin/bash

Usage() {
	echo
	echo "Usage: `basename $0` <ssid_sess>"
	echo
	echo "Example: `basename $0` 012_C 176_E"
	echo
	exit 1
}

SCRIPT=$(python -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${ANALYSIS_DIR}" ]]; then
	source "$SCRIPTSDIR/NIHPD_SetupEnvironment.sh"
fi

FORCE_OVERWRITE="no"
if [ "$#" -gt 2 -a "$1" == "-f" ]; then
	FORCE_OVERWRITE="yes"
	shift ;
	echo "* enabling FORCE_OVERWRITE mode..."
fi

[ "$#" -lt 1 ] && Usage


USE_DEFACED_AS_ORIG="yes"


SUBJECTS="$@"
for Subj in $SUBJECTS ; do 
	
	S=$(basename $Subj)
	SDIR="${ANALYSIS_DIR}/${S}_FLAIR"
	if [ "$FORCE_OVERWRITE" == "yes" ]; then
		echo "*** FORCE_OVERWRITE enabled: deleting $SDIR/unprocessed/"
		rm -rf ${SDIR}/unprocessed/ >/dev/null
	fi
	mkdir -p ${SDIR}/unprocessed/
	cd ${SDIR}/unprocessed/
	echo "------------ starting `basename $0` on `pwd`/, at `date`"
	
	subjRawDIR=$(find ${RAW_DATA_DIR} -maxdepth 1 -type d -name "${S}_20??????" -print)
	if [ ! -d "$subjRawDIR" ]; then
		echo "*** ERROR: cannot find rawdata directory for $S in ${RAW_DATA_DIR}/"
		continue
	fi
	subjRawNiiDIR="${subjRawDIR}/NIFTIS"
	if [ ! -d "$subjRawNiiDIR" ]; then
		echo "*** ERROR: could not locate subject directory = $subjRawNiiDIR/"
		continue
	fi
	
	T1wDIR="${SDIR}/unprocessed/T1w1"
	mkdir -p ${T1wDIR}/
	cd ${T1wDIR}/
	if [ ! -f "${S}_FLAIR_T1w1.nii.gz" ]; then
		prefix="${S}_t1w_bravo_orig"
		if [ "$USE_DEFACED_AS_ORIG" == "yes" ]; then
			if [ -f "$subjRawNiiDIR/${prefix}_defaced.nii.gz" ]; then
				cp -vp $subjRawNiiDIR/${prefix}_defaced.nii.gz ./${S}_FLAIR_T1w1.nii.gz
				cp -vp $subjRawNiiDIR/${prefix}.json ./${S}_FLAIR_T1w1.json
			else
				echo "*** ERROR: could not locate $subjRawNiiDIR/${prefix}_defaced.nii.gz"
				exit 2
			fi
		else
			if [ -f "$subjRawNiiDIR/${S}_t1.nii.gz" ]; then
				cp -vp $subjRawNiiDIR/${prefix}.nii.gz ./${S}_FLAIR_T1w1.nii.gz
				cp -vp $subjRawNiiDIR/${prefix}.json ./${S}_FLAIR_T1w1.json
			else
				echo "*** ERROR: could not locate $subjRawNiiDIR/${prefix}.nii.gz"
				exit 2
			fi
		fi
	fi
	
	T2wDIR="${SDIR}/unprocessed/T2w1"
	mkdir -p ${T2wDIR}/
	cd ${T2wDIR}/
	if [ ! -f "${S}_FLAIR_T2w1.nii.gz" ]; then
		prefix="${S}_t2prep_flair_promo_orig"
		if [ "$USE_DEFACED_AS_ORIG" == "yes" ]; then
			if [ -f "$subjRawNiiDIR/${prefix}_defaced.nii.gz" ]; then
				cp -vp $subjRawNiiDIR/${prefix}_defaced.nii.gz ./${S}_FLAIR_T2w1.nii.gz
				cp -vp $subjRawNiiDIR/${prefix}.json ./${S}_FLAIR_T2w1.json
			else
				echo "*** ERROR: could not locate $subjRawNiiDIR/${prefix}_defaced.nii.gz"
				exit 2
			fi
		else
			if [ -f "$subjRawNiiDIR/${prefix}.nii.gz" ]; then
				cp -vp $subjRawNiiDIR/${prefix}.nii.gz ./${S}_FLAIR_T2w1.nii.gz
				cp -vp $subjRawNiiDIR/${prefix}.json ./${S}_FLAIR_T2w1.json
			else
				echo "*** ERROR: could not locate $subjRawNiiDIR/${prefix}.nii.gz"
				exit 2
			fi
		fi
	fi
	
	DwiDIR="${SDIR}/unprocessed/Diffusion" 
	mkdir -p ${DwiDIR}/
	cd ${DwiDIR}/
	
	if [ ! -f "${S}_FLAIR_DWI_dir30_AP.nii.gz" -o ! -f "${S}_FLAIR_DWI_dir30_PA.nii.gz" ]; then		
		if [ -r "$subjRawNiiDIR/${S}_dwi_peAP.nii.gz" -a -r "$subjRawNiiDIR/${S}_dwi_pePA.nii.gz" ]; then
			nvolsAP=$(fslnvols $subjRawNiiDIR/${S}_dwi_peAP.nii.gz | bc)
			nvolsPA=$(fslnvols $subjRawNiiDIR/${S}_dwi_pePA.nii.gz | bc)
			if [ "$nvolsAP" -eq 33 -a "$nvolsPA" -eq 8 ]; then
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.nii.gz ./${S}_FLAIR_DWI_dir30_AP.nii.gz
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.json ./${S}_FLAIR_DWI_dir30_AP.json
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.bvec ./${S}_FLAIR_DWI_dir30_AP.bvec
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.bval ./${S}_FLAIR_DWI_dir30_AP.bval
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.nii.gz ./${S}_FLAIR_DWI_dir30_PA.nii.gz
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.json ./${S}_FLAIR_DWI_dir30_PA.json
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.bvec ./${S}_FLAIR_DWI_dir30_PA.bvec
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.bval ./${S}_FLAIR_DWI_dir30_PA.bval
			elif [ "$nvolsAP" -eq 8 -a "$nvolsPA" -eq 33 ]; then
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.nii.gz ./${S}_FLAIR_DWI_dir30_PA.nii.gz
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.json   ./${S}_FLAIR_DWI_dir30_PA.json
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.bvec   ./${S}_FLAIR_DWI_dir30_PA.bvec
				cp -vpf $subjRawNiiDIR/${S}_dwi_peAP.bval   ./${S}_FLAIR_DWI_dir30_PA.bval
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.nii.gz ./${S}_FLAIR_DWI_dir30_AP.nii.gz
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.json   ./${S}_FLAIR_DWI_dir30_AP.json
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.bvec   ./${S}_FLAIR_DWI_dir30_AP.bvec
				cp -vpf $subjRawNiiDIR/${S}_dwi_pePA.bval   ./${S}_FLAIR_DWI_dir30_AP.bval
			else
				echo "*** ERROR: could not locate $subjRawNiiDIR/${S}_dwi_${seq}.nii.gz"
				exit 2
			fi
		else
			echo "*** ERROR: could not locate $subjRawNiiDIR/${S}_dwi_AP.nii.gz or ${S}_dwi_PA.nii.gz"
			exit 2
		fi
	fi
	
	echo "------------ finished `basename $0` on `pwd`/, at `date`"
	echo
	
done

exit 0
