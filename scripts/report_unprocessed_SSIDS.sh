#!/bin/bash


DSTR=$(date +%Y%m%d)


cd /shared/uher/FORBOW/rawdata/
RAW_SSIDS="$(pwd)/${DSTR}_all_raw_SSIDs.txt"
rm -f ${RAW_SSIDS}
for D in `/bin/ls -d ???_?_20*`; do
	echo "${D:0:5}" >>${RAW_SSIDS}
done
echo " ++ total raw SSIDs: $(wc -l ${RAW_SSIDS})"


cd /shared/uher/FORBOW/NIHPD_analysis/

PROC_DATASETS="$(pwd)/${DSTR}_all_processed_datasets.txt"
rm -f ${PROC_DATASETS}
for D in `/bin/ls -d ???_? ???_?_NP ???_?_FLAIR`; do
	echo "${D}" >>${PROC_DATASETS}
done
echo " ++ total processed datasets: $(wc -l ${PROC_DATASETS})"


PROC_SSIDS_NONUNIQ="$(pwd)/${DSTR}_all_processed_SSIDS_nonuniq.txt"
rm -f ${PROC_SSIDS_NONUNIQ}
for D in `cat ${PROC_DATASETS}`; do
	echo "${D:0:5}" >>${PROC_SSIDS_NONUNIQ}
done
PROC_SSIDS="$(pwd)/${DSTR}_all_processed_SSIDS.txt"
rm -f ${PROC_SSIDS}
cat ${PROC_SSIDS_NONUNIQ} | uniq | sort >${PROC_SSIDS}
echo " ++ total processed 'unique' SSIDs: $(wc -l ${RAW_SSIDS})"


NEED_PROC_SSIDS="$(pwd)/${DSTR}_SSIDS_to_process.txt"
rm -f ${NEED_PROC_SSIDS}
diff -u ${PROC_SSIDS} ${RAW_SSIDS} | grep -E "^\+" | sed 's/+//g' >${NEED_PROC_SSIDS}
echo " ++ total processed 'unique' SSIDs: $(wc -l ${NEED_PROC_SSIDS})"
cat -v ${NEED_PROC_SSIDS}

exit 0

