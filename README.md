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

---

### Qoala-T report

Processed data needs to undergo automated QC with the Qoala-T tool: [GitHub Repo](https://github.com/Qoala-T/QC), [journal article](https://www.sciencedirect.com/science/article/pii/S1053811919300138?via%3Dihub)

* run Qoala-T script [to be linked here]
* upload `aseg_stats.txt` and left and right `aparc_area_[hemi].txt` and ` aparc_thickness_[hemi].txt` to [Qoala-T Shiny app](https://qoala-t.shinyapps.io/qoala-t_app/)
* click `Execute Qoala-T predictions` and save locally before uploading to sync or github

---

### Sending tabular data

- Upload to [Sync](https://ln.sync.com/dl/c7eabce40/4gz5w45g-gmbn5dcp-zibum4gy-64k4eg6q)
- Enter password
        - also easier to remember link: http://bit.ly/VladData 
- Tabular data can now be uploaded here, by either clicking upload or dragging the files over. 
- Contents not visible, but if upload shows 100% then they've been added

