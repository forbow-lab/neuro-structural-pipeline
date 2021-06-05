#!/bin/bash
Usage() {
	echo
	echo "Usage: `basename $0` <ssid>"
	echo
	echo "Example: `basename $0` 001_A_FLAIR 001_C_FLAIR ..."
	echo
	exit 1
}

SCRIPT=$(fslpython -c "from os.path import abspath; print(abspath('$0'))")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${ANALYSIS_DIR}" ]]; then
	source "$SCRIPTSDIR/NIHPD_SetupEnvironment.sh"
fi
FORCE_OVERWRITE="no"
if [ "$1" == "-f" ]; then
	FORCE_OVERWRITE="yes"
	shift ;
fi

declare -a APARC_ROIS
APARC_ROIS="SSID,L_bankssts,L_caudalanteriorcingulate,L_caudalmiddlefrontal,L_corpuscallosum,L_cuneus,L_entorhinal,L_fusiform,L_inferiorparietal,L_inferiortemporal,L_isthmuscingulate,L_lateraloccipital,L_lateralorbitofrontal,L_lingual,L_medialorbitofrontal,L_middletemporal,L_parahippocampal,L_paracentral,L_parsopercularis,L_parsorbitalis,L_parstriangularis,L_pericalcarine,L_postcentral,L_posteriorcingulate,L_precentral,L_precuneus,L_rostralanteriorcingulate,L_rostralmiddlefrontal,L_superiorfrontal,L_superiorparietal,L_superiortemporal,L_supramarginal,L_frontalpole,L_temporalpole,L_transversetemporal,L_insula,R_bankssts,R_caudalanteriorcingulate,R_caudalmiddlefrontal,R_corpuscallosum,R_cuneus,R_entorhinal,R_fusiform,R_inferiorparietal,R_inferiortemporal,R_isthmuscingulate,R_lateraloccipital,R_lateralorbitofrontal,R_lingual,R_medialorbitofrontal,R_middletemporal,R_parahippocampal,R_paracentral,R_parsopercularis,R_parsorbitalis,R_parstriangularis,R_pericalcarine,R_postcentral,R_posteriorcingulate,R_precentral,R_precuneus,R_rostralanteriorcingulate,R_rostralmiddlefrontal,R_superiorfrontal,R_superiorparietal,R_superiortemporal,R_supramarginal,R_frontalpole,R_temporalpole,R_transversetemporal,R_insula"

CreateGroupOutputFile="no"

if [ "$CreateGroupOutputFile" == "yes" ]; then
	DSTR=$(date +%Y%m%d-%H%M)
	GRP_RFILE="$ANALYSIS_DIR/_2_results/${DSTR}_myelin_native_aparc_results.csv"
	rm -f $GRP_RFILE
fi

[ "$#" -lt 1 ] && Usage

SUBJECTS="$@"
for Subj in $SUBJECTS ; do 
	
	S=$(basename $Subj)
	SDIR="$ANALYSIS_DIR/$S"
	if [ ! -d "$SDIR" ]; then
		echo "*** ERROR: cannot find subject directory = $SDIR"
		continue
	fi
	cd $SDIR/
	echo "---- calculating myelin results for $SDIR/, starting `date`"
	
	MDIR=$SDIR/Myelin
	mkdir -p $MDIR/
	
	myFile=$MDIR/${S}.MyelinMap.native.pscalar.txt
	if [ ! -r "$myFile" ]; then
		## CODE REFERENCE:
		## https://groups.google.com/a/humanconnectome.org/g/hcp-users/c/35C4s3Q-11I/m/RSoHv8EKAAAJ
		## Extract surface area per vertex for spatial weighting later
		for H in L R; do
			wb_command -surface-vertex-areas $SDIR/T1w/Native/${S}.${H}.midthickness.native.surf.gii $MDIR/${S}.${H}.midthickness.native.shape.gii
		done

		## Parcellate the cifti file
		wb_command \
			-cifti-parcellate \
			$SDIR/MNINonLinear/Native/${S}.MyelinMap.native.dscalar.nii \
			$SDIR/MNINonLinear/Native/${S}.aparc.native.dlabel.nii \
			COLUMN $MDIR/${S}.MyelinMap.native.pscalar.nii \
			-spatial-weights \
			-left-area-metric $MDIR/${S}.L.midthickness.native.shape.gii \
			-right-area-metric $MDIR/${S}.R.midthickness.native.shape.gii

		## Convert the parcellation to a text file
		wb_command -cifti-convert -to-text $MDIR/${S}.MyelinMap.native.pscalar.nii $myFile
	
		if [ ! -r "$myFile" ]; then
			echo "*** ERROR: failed to create output file = $myFile"
			continue
		fi
	fi
	D="$S"
	for d in $(cat $myFile); do
		D="$D,$d"
	done
	subj_rfile=$MDIR/${S}_MyelinMap_native_pscalar_1row.csv
	echo " ++ creating myelin values in output file = $subj_rfile"
	echo -e "$APARC_ROIS\n$D" >$subj_rfile
	
	if [ "$CreateGroupOutputFile" == "yes" ]; then
		if [ ! -r "$GRP_RFILE" ]; then
			echo -e "$APARC_ROIS\n$D" >$GRP_RFILE
		else
			echo "$D" >>$GRP_RFILE	
		fi
	fi
done


if [ -r "$GRP_RFILE" -a "$CreateGroupOutputFile" == "yes" ]; then
	echo
	echo " ++ group results saved into output file = $GRP_RFILE"
	echo
fi

exit 0
