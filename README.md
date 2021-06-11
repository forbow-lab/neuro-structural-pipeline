# Neuro Structural Pipeline

The FORBOW Brain Study Manual is broken down below into five major sections:

1. Background info: structure of the brain study.
2. Before the scan: outlines how to identify and schedule participants.
3. During the scan: steps to be executed at the time of scanning.
4. After the scan: practices and procedures to complete when scanning is done.
    * [1-4 covered at this hyperlink](https://github.com/forbow-lab/documentation-private) (request access if not visible).
5. __Preprocessing and PBIL__: the focus of this section.


---


### HCP Preprocessing Pipeline
(typically 4 hours per subject)

In this step we will run the Human Connectome Project Minimal Preprocessing pipelines, which are documented in detail [here](http://www.ncbi.nlm.nih.gov/pubmed/23668970), and [here](https://github.com/Washington-University/Pipelines) (and naturally on our computers). They have been modified to work with our scanner. In essence, these pipelines are a series of scripts that use programs such as FreeSurfer, FSL and other tools to clean, register, segment, and generally process the data in accordance to best methods currently available.

This step relies on completion of all previous steps in this document.

1. Open the terminal.
2. Navigate to the `_scripts` folder in /shared/uher/FORBOW_Brain/neuro_data/Biotic3T/
3. Drag the `1_run_hcp_all.sh` script into the terminal
  * alternatively, cd into the `_scripts` folder and type `run` and click **tab** to autocomplete then type `.` hit tab to autocomplete again.
4. In terminal, after the script path, type subject IDs that need to be preprocessed (space separated), for example `032_A 033_A 031_B`
5. Click **enter** to run script on specified subjects.

In order to run the participants in  parallel and staggered you can use a different command (see example below). 

```
./\_1\_scripts/parallel_stagger.sh -j 4 -d 600 -s /shared/uher/FORBOW/analysis/\_1\_scripts/1\_run\_hcp\_all.sh  ::: 031\_B\_NP 031\_B\_FLAIR 035\_A\_NP 035\_A\_FLAIR 016\__NP 016\_C\_FLAIR 011\_D\_NP 011\_D\_FLAIR
```

Where the _parallel_ command forces the scripts to run on different CPU cores and the _-j_ followed by a number specifies the number of jobs (should be proportional to CPU cores and RAM available - but not 100% this way as some of the scripts it runs in turn run their own parallel processing). 

---

#### Running individual scripts

There might be times when you might want to run the scripts separately rather than relying on the `run all hcp` script above. In order to do that:

1. cd into the `log` folder of the to-be-run participant's directory
    * this is so that the output of the scripts gets saved in the log directory for that participant
2. then drag the appropriate script into terminal e.g. `HCP_1_PreFreeSurferPipelineBatch.sh`
3. specify subjectID, better to do one per tab/terminal to keep track
    * involves adding `--Subjlist=` followed by the subject ID
4. keep track of the scripts run with the `track and QC spreadsheet`

A note about runtimes

HCP_1_PreFreeSurferPipelineBatch.sh | ~ 1 hour

---

### Error Checking

After the `1_run_hcp_all.sh` script completes, check the `log` folder for each individual for errors.

---

## Local Gyrification Index - LGI

Updated Oct 31, 2017

---

This requires a successful run of the minimal preprocessing pipeline on the participants of interest.

---
### Theoretical

Gyrification index is a metric that quantifies the amount of cortex buried within the sulcal folds as compared with the amount of cortex on the outer visible cortex. A cortex with extensive folding has a large gyrification index, whereas a cortex with limited folding has a small gyrification index. More information is available [here](https://surfer.nmr.mgh.harvard.edu/fswiki/LGI).

In essence after the HCP minimal preprocessing pipelines are done you `cd` into processed T1w directory. (Don't actually do this)
```
 export SUBJECTS_DIR=`pwd`
```
Then run the command below, which will work on the participant ID in the T1w folder.
```
recon-all -s participantID -localGI
```

 This takes just under 2 hours per participant and produces right and left `.pial_lgi` in the `surf` folder. To generate statistics on ROIs, run (and again for right hemisphere):

```
mri_segstats --annot 000_VD_A lh aparc --i $SUBJECTS_DIR/SSID_A/surf/lh.pial_lgi --sum lh.aparc.pial_lgi.stats
```

You get LGI values for 34 ROIs of the FreeSurfer Desikan atlas.

----

### Practical
To automate, we use scripts instead

1. `cd` into data folder `/shared/uher/FORBOW_Brain/neuro_data/Biotic3T` and run `/bin/ls -d 0??_A` to display baseline scans in a line. Copy the participants needed to run. Or just do this manually if only processing one or two.

2. In order to run multiple subject simultaneously, will use GNU parallel. First type: `parallel -j n` where `n` is the number of simultaneous jobs. Memory usage 5-6GB per subject puts us at 3-4 subjects max (can do 12 with new workstations).

3. Then, drag `LGI_0_run_freesurfer.sh` from the `_scritpts` folder to terminal and specify participants that need to be run (space separated). Example of full command: `parallel -j 3 /shared/uher/FORBOW_Brain/neuro_data/Biotic3T/_scripts/LGI_0_run_freesurfer.sh ::: 031_A_NP 032_A_NP 035_A 035_A_FLAIR 035_A_NP 036_A 036_A_NP 036_A_FLAIR`

4. Finally to get the stats for the ROIs run the `LGI_collate_results2csv.sh`script
  - *specify participants to run* (space separated -  usually a good idea to get stats on all)
  - if needed can edit script to specify structures of interest
  - check `_results` folder for CSV file
  - to run this on all participants, drag the script into the terminal window and follow with: '/bin/ls -d 0??_* 1??_*' 

---

## Data Quality and Reminders
- Create a  "readme" file that contains pertinent notes about that particular participant and scan (e.g. T1 BRAVO collected twice due to motion, kept 2nd ) as well as the exam number
- Create a file to rate the quality of the T1 BRAVO, T2 CUBE, and T2 PROMO on a four point scale (e.g. 109_A_qc_ratings). See any previous rawdata folder for an example
- Complete the remaining fields of the neurolog
-Send images to participants that requested a picture of their brain 

---

### Sending files

- Upload to [Sync](https://ln.sync.com/dl/c7eabce40/4gz5w45g-gmbn5dcp-zibum4gy-64k4eg6q)
- Enter password
        - also easier to remember link: http://bit.ly/VladData 
- Tabular data can now be uploaded here, by either clicking upload or dragging the files over. 
- Contents not visible, but if upload shows 100% then they've been added


---

### NIHPD Analysis Scripts (modified from HCP-PP)

1. For simplicity, one main script wraps subject-level work-flow scripts to completely process a new dataset:
`./_1_scripts/NIHPD_RUN_Analysis_Pipeline.sh <SSID_SESS>`

If all ran perfectly then following output is created: 

```
 ./SSID_SESS_FLAIR/
    DWI/
    logs/
    MNI-Nonlinear/
    Myelin/
    T1w/
        SID_SESS_FLAIR/
            label/
            mri/
            scripts/
            stats/
            surf/
        T2w/
        unprocessed/
```

2. And this dataset can then be included when calling the master group reporting script:
`./NIHDP_report_values2csv_HCP_WideFormat.sh  $(ls -d ???_?_FLAIR)`

