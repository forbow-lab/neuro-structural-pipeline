# Neuro Structural Pipeline

The FORBOW Brain Study Manual is broken down below into five major sections:

1. Background info: structure of the brain study
2. Before the scan: outlines how to identify and schedule participants
3. During the scan: steps to be executed at the time of scanning
4. After the scan: practices and procedures to complete when scanning is done.
    * [1-4 covered here](https://github.com/forbow-lab/documentation-private) (request access if not visible)
6. Preprocessing and PBIL 

This section focuses on the 5. the data processing steps.

---

### Data Transfer

- After the files have been transferred to FORBOW-PBIL node from the scanner:
    - Organize to have `rawdata` folder to contain the SUBJECT ID followed by the date as parent directory (e.g. 101_C_20190225)
    - Open Horos
    - Select "Query" on main interface
        - You can then search "Forbow", can select "last 24hrs", or other to funnel. I prefer to search the last 7 days.
        - Select query again
        - Download new images by hitting the green download button beside each FORBOW participant
        - Before closing the query box, ensure that no files are in the process of being transferred by looking along the left side of the Horos window under "Activity" 
        - Once files have transferred, drag four images into participant folder, this includes the T1, T2, and two DTI files. Organize into one child directory titled "DICOMS" (see any of the existing folders).
        - Note, if there are multiple T1w BRAVO and/or T2w CUBES only copy over the highest quality scan

---

The FORBOW structural pipeline adopts and modifies the Human Connectome Project [Minimal Preprocessing Pipeline](https://github.com/Washington-University/HCPpipelines) described in [Glasser et al. 2013](https://pubmed.ncbi.nlm.nih.gov/23668970/).

---


### NIHPD Analysis Scripts (modified from HCP-PP)

1. For simplicity, one main script wraps subject-level work-flow scripts to completely process a new dataset:
`./_1_scripts/NIHPD_RUN_Analysis_Pipeline.sh <SSID_SESS>`

If all ran perfectly then following output is created: 
- `./SSID_SESS_FLAIR/
-    DWI/
-    logs/
-    MNI-Nonlinear/
-    Myelin/
-    T1w/
-        SID_SESS_FLAIR/
-            label/
-            mri/
-            scripts/
-            stats/
-            surf/
-        T2w/
-        unprocessed/`

2. And this dataset can then be included when calling the master group reporting script:
`./NIHDP_report_values2csv_HCP_WideFormat.sh  $(ls -d ???_?_FLAIR)`

