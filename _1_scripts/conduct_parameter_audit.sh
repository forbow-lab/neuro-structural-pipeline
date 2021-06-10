#!/bin/bash


E=/shared/uher/FORBOW/analysis
cd $E/

DSTR=$(date +%Y%m%d)
SEQUENCES="T1w1 T2w1 DWI_dir30_AP DWI_dir30_PA rfMRI rfMRI_SBRef GradientEcho_AP GradientEcho_PA"
HDR="SSID,file,Ni,Nj,Nk,Nv,ADi,ADj,ADk,TR,voxvol"

for seq in $SEQUENCES ;do 
	RFILE="$E/_2_results/${DSTR}_${seq}.csv"
	echo "$HDR" >$RFILE
done


SUBJECTS=$(/bin/ls -d 0??_*)

for seq in $SEQUENCES ;do 
	RFILE="$E/_2_results/${DSTR}_${seq}_parameter_audit.csv"
	result="$S,.,.,.,.,.,.,.,.,.,."
	for SSID in $SUBJECTS ; do
		S=`basename $SSID`	
		SDIR=$E/$S
		if [ ! -d "$SDIR" ]; then
			echo "*** ERROR: could not find subject folder: $SDIR"
			echo $result >>$RFILE
			continue
		fi
		mfile=$SDIR/unprocessed/metadata.csv
		if [ ! -r "$mfile" ]; then
			echo "*** ERROR: could not find metadata file: $mfile"
			echo $result >>$RFILE
			continue
		fi
	 	result="$S,`cat $mfile | grep "${seq}.nii.gz"`"
	 	echo $result >>$RFILE

	done
done

if [ "`uname -s`" == "Linux" ]; then
	python _1_scripts/merge_csvfiles_into_xls.py $DSTR
	/bin/rm -f $E/_2_results/${DSTR}_*_parameter_audit.csv
	libreoffice "$E/_2_results/${DSTR}_parameter_audit.xls"  &
else
	python $E/_1_scripts/merge_csvfiles_into_xls.py $DSTR
	/bin/rm -f $E/_2_results/${DSTR}_*_parameter_audit.csv
	open -a /Applications/Microsoft\ Office\ 2011/Microsoft\ Excel.app "$E/_2_results/${DSTR}_parameter_audit.xlsx"
fi


exit 0
