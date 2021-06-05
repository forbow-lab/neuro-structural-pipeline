#!/bin/bash


E=/shared/uher/FORBOW/analysis
cd $E/

DEBUGMODE=false

QC_SEQUENCES_PATH="$E/_1_scripts/qc_nifti_sequences"
DSTR=$(date +%Y%m%d)
PREFIX="${DSTR}_diffs"
SUFFIX="parameter_audit"
SEQUENCES="T1w1 T2w1 DWI_dir30_AP DWI_dir30_PA rfMRI rfMRI_SBRef GradientEcho_AP GradientEcho_PA"
HDR="SSID,file,Ni,Nj,Nk,Nv,ADi,ADj,ADk,TR,voxvol"

for seq in $SEQUENCES ;do 
	RFILE="$E/_2_results/${PREFIX}_${seq}_${SUFFIX}.csv"
	echo "$HDR" >$RFILE
done

if $DEBUGMODE ; then
	SUBJECTS="001_A 002_A 003_A"
else
	SUBJECTS=$(/bin/ls -d 0??_*)
fi

for seq in $SEQUENCES ; do 
	
	RFILE="$E/_2_results/${PREFIX}_${seq}_${SUFFIX}.csv"
	
	#load known good sequences and grab planned parameters at 2-decimal places
	qcSeqFile="$QC_SEQUENCES_PATH/qc_${seq}.nii.gz"
	if [ "`$FSLDIR/bin/imtest $qcSeqFile`" -eq 0 ]; then
		echo "*** ERROR: cannot find QC_nifti_seq=$qcSeqFile"
		continue
	fi
	qcSeqPrams=$($E/_1_scripts/report_nii_voxel_info.sh $qcSeqFile | tail -1)
	qcSeqVals=$(echo $qcSeqPrams | awk -F, '{$1=""; print $0}' | awk '{for(i=1;i<=NF;i++)printf"%.2f ",+$i}')
	echo "qcSeqFile=$qcSeqFile, qcSeqVals=$qcSeqVals"
	echo "_QC_,$seq,$(echo $qcSeqVals | sed -E 's|[[:space:]]+|,|g')" >>$RFILE
	echo "_QC_,$seq,$(echo $qcSeqVals | sed -E 's|[[:space:]]+|,|g')"
	
	result="$S,.,.,.,.,.,.,.,.,.,."
	for SSID in $SUBJECTS ; do
		S=`basename $SSID`	
		SDIR=$E/$S
		if [ ! -d "$SDIR" ]; then
			echo "*** ERROR: could not find subject folder: $SDIR"
			echo $result >>$RFILE
			continue
		fi
		if [ "$seq" == "T1w1" -o "$seq" == "T2w1" ]; then
			seqdir="$SDIR/unprocessed/$seq"
		elif [ "$seq" == "DWI_dir30_AP" -o "$seq" == "DWI_dir30_PA" ]; then
			seqdir="$SDIR/unprocessed/Diffusion"
		elif [ "$seq" == "rfMRI" -o "$seq" == "rfMRI_SBRef" -o "$seq" == "GradientEcho_AP" -o "$seq" == "GradientEcho_PA" ]; then
			seqdir="$SDIR/unprocessed/rfMRI"
		else
			echo "*** ERROR: cannot find path to sequence pattern=$seq"
			echo $result >>$RFILE
			continue
		fi
		seqfile="$seqdir/${S}_${seq}.nii.gz"
		if [ "`$FSLDIR/bin/imtest $seqfile`" -eq 0 ]; then
			echo "*** ERROR: cannot find sequence file = $seqfile"
			echo $result >>$RFILE
			continue
		fi
		meta="`$E/_1_scripts/report_nii_voxel_info.sh $seqfile | tail -1`"
		vals=$(echo $meta | awk -F, '{$1=""; print $0}' | awk '{for(i=1;i<=NF;i++)printf"%.2f ",+$i}')		
		if [ "$vals" != "$qcSeqVals" ]; then
			result="$S,$seq,$(echo $vals | sed -E 's|[[:space:]]+|,|g')"
			echo "$result" >>$RFILE
			echo "error = $result"
		fi
	done
done

python "$E/_1_scripts/merge_csvfiles_into_xls.py" "$PREFIX"
xlsFile="$E/_2_results/${PREFIX}_${SUFFIX}.xlsx"
if [ "$DEBUGMODE" != true -a -r "$xlsFile" ]; then
	/bin/rm -fv $E/_2_results/${PREFIX}_*_${SUFFIX}.csv
fi
if [ "`uname -s`" == "Linux" ]; then
	libreoffice "$xlsFile"  &
else
	open -a /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app "$xlsFile"
fi

exit 0
