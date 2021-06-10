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

### Converting the resting state (RS) images 

- If you plan to convert the RS shortly after the scan, you may need to see if they are ready by looking on the BIOTIC server. To do this: 
* `ssh biotic@lauterbur`
  * enter password
* Navigate to our data folder on their server `cd /biotic/data/Forbow/`
* `ls` to see the list of participants
* `ls` into specific participant folder
* If participant files appear with a timestamp they are good to go, if not, you'll have to wait for BIOTIC to convert them 
* `exit` to close connection


After the EPI images have been transferred to the server at BIOTIC (lauterbur):
* open terminal and `cd` into SUBJECT ID in `rawdata folder`
* run the following command *all one line* replacing IDs with the correct subject IDs and date:
* `nohup rsync -a -e "ssh" biotic@lauterbur:/biotic/3Tdata/Forbow/###_X/ /shared/uher/FORBOW_Brain/neuro_data/Biotic3T/rawdata/###_X_YYYYMMDD/RS/`
  * copies the resting state data from the lauterbur server to our server into the participants RS rawdata folder
  * make sure to supply correct subject ID and scan label for `###_X` and the correct date of scan for `YYYYMMDD`
  * enter password

Note: may take 10-15 minutes to copy across network (~17 GB)


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

