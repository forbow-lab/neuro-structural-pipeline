# Neuro Structural Pipeline

The FORBOW structural pipeline adopts and modifies the Human Connectome Project [Minimal Preprocessing Pipeline](https://github.com/Washington-University/HCPpipelines) described in [Glasser et al. 2013](https://pubmed.ncbi.nlm.nih.gov/23668970/).

=======


### NIHPD Analysis Scripts (modified from HCP-PP)

1. For simplicity, one main script wraps subject-level work-flow scripts to completely process a new dataset:
`./_1_scripts/NIHPD_RUN_Analysis_Pipeline.sh <SSID_SESS>`

If all ran perfectly then following output is created: 
&emsp;./SSID_SESS_FLAIR/
&emsp;&emsp;DWI/
&emsp;&emsp;logs/
&emsp;&emsp;MNI-Nonlinear/
&emsp;&emsp;Myelin/
&emsp;&emsp;T1w/
&emsp;&emsp;&emsp;SSID_SESS_FLAIR/
&emsp;&emsp;&emsp;&emsp;label/
&emsp;&emsp;&emsp;&emsp;mri/
&emsp;&emsp;&emsp;&emsp;scripts/
&emsp;&emsp;&emsp;&emsp;stats/
&emsp;&emsp;&emsp;&emsp;surf/
&emsp;&emsp;T2w/
&emsp;&emsp;unprocessed/

2. And this dataset can then be included when calling the master group reporting script:
`./NIHDP_report_values2csv_HCP_WideFormat.sh  $(ls -d ???_?_FLAIR)`

