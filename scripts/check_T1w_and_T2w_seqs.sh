#!/bin/bash

cd /shared/uher/FORBOW/NIHPD_analysis/

for S in `/bin/ls -d ???_?_FLAIR` ; do 
	t2=$(cat $S/unprocessed/T2w1/${S}_T2w1.json | grep 'SeriesDescription'); 
	t1=$(cat $S/unprocessed/T1w1/${S}_T1w1.json | grep 'SeriesDescription'); 
	echo "$S, $t2, $t1"; 
done

exit 0

