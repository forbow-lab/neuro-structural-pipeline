#!/bin/bash

SCRIPT=$(python -c "import os; print os.path.abspath('$0')")
SCRIPTSDIR=$(dirname $SCRIPT)
if [[ -z "${ANALYSIS_DIR}" ]]; then
	source "$SCRIPTSDIR/NIHPD_SetupEnvironment.sh"
fi

cd $ANALYSIS_DIR/
for S in $(/bin/ls -d ???_? ???_?_NP ???_?_FLAIR); do 
	f=$S/T1w/$S/stats/aseg.stats; 
	if [ ! -r "$f" ]; then 
		echo " $S missing $f"; 
	fi; 
done

exit 0
