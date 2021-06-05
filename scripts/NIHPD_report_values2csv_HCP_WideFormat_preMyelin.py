#!/usr/bin/env python2
"""
Usage:   report_values2csv.py <ssid1> <ssid2> ...

Eg: report_values2csv.py 001_A 001_B 002_A 002_B

"""
## New Example Usage 2019/04/23: 
## USE FROM Jaylah.
## $ cd /shared/uher/FORBOW/NIHPD_analysis/
## $ ./_1_scripts/NIHPD_report_values2csv_HCP_WideFormat.py `/bin/ls -d ???_? ???_?_NP ???_?_FLAIR`


import os
import sys
import glob
import time
import getopt
import errno

try:
    FileNotFoundError
except NameError:
    FileNotFoundError = IOError
 
VERBOSE=True
REPORT_QC_AVERAGE=False
REPORT_DTI_VALUES=True

def run_shell_cmd(cmd,cwd=[]):
	""" run a command in the shell using Popen
	"""
	print 'cwd=%s' % (cwd)
	import subprocess
	if cwd:
		process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,cwd=cwd)
	else:
		process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
	for line in process.stdout:
		 print line.strip()
	process.wait()
	return


def usage():
	""" print the docstring and exit"""
	sys.stdout.write(__doc__)
	sys.exit(2)


def deface(infile):	
	if os.environ.has_key('FSLDIR'):
		FSLDIR=os.environ['FSLDIR']
	else:
		print '*** ERROR: FSLDIR environment variable is not defined'
		sys.exit(2)
	template=os.path.join(FSLDIR,'data/standard/MNI152_T1_1mm.nii.gz')
	facemask=os.path.join(FSLDIR,'data/standard/MNI152_T1_1mm_facemask.nii.gz')

	cmd='flirt -in %s -ref %s -omat tmp_mask.mat -nosearch'%(template,infile)
	print 'Running: '+cmd
	run_shell_cmd(cmd)
	cmd='flirt -in %s -ref %s -init tmp_mask.mat -applyxfm -out facemask_tmp'%(facemask,infile)
	print 'Running: '+cmd
	run_shell_cmd(cmd)
	cmd='fslmaths facemask_tmp -binv -mul %s %s'%(infile,infile.replace('.nii.gz','_defaced.nii.gz'))
	print 'Running: '+cmd
	run_shell_cmd(cmd)
	cmd='imrm facemask_tmp.nii.gz'
	run_shell_cmd(cmd)
	#os.remove('facemask_tmp.nii.gz')
	os.remove('tmp_mask.mat')
	return


ASEG_ROI_NAMES=['FS_L_LatVent','FS_L_InfLatVent','FS_L_Cerebellum_WM','FS_L_Cerebellum_Cort', \
'FS_L_ThalamusProper','FS_L_Caudate','FS_L_Putamen','FS_L_Pallidum','FS_3rdVent','FS_4thVent','FS_BrainStem', \
'FS_L_Hippo','FS_L_Amygdala','FS_CSF','FS_L_AccumbensArea','FS_L_VentDC','FS_L_Vessel','FS_L_ChoroidPlexus', \
'FS_R_LatVent','FS_R_InfLatVent','FS_R_Cerebellum_WM','FS_R_Cerebellum_Cort','FS_R_ThalamusProper', \
'FS_R_Caudate','FS_R_Putamen','FS_R_Pallidum','FS_R_Hippo','FS_R_Amygdala','FS_R_AccumbensArea','FS_R_VentDC', \
'FS_R_Vessel','FS_R_ChoroidPlexus','FS_5thVent','FS_WM_Hypointens','FS_L_WM_Hypointens','FS_R_WM_Hypointens', \
'FS_Non-WM_Hypointens','FS_L_Non-WM_Hypointens','FS_R_Non-WM_Hypointens','FS_OpticChiasm','FS_CC_Posterior', \
'FS_CC_MidPosterior','FS_CC_Central','FS_CC_MidAnterior','FS_CC_Anterior']

ASEG_ROIS=['Left-Lateral-Ventricle','Left-Inf-Lat-Vent','Left-Cerebellum-White-Matter','Left-Cerebellum-Cortex', \
'Left-Thalamus-Proper','Left-Caudate','Left-Putamen','Left-Pallidum','3rd-Ventricle', '4th-Ventricle','Brain-Stem', \
'Left-Hippocampus','Left-Amygdala','CSF','Left-Accumbens-area','Left-VentralDC','Left-vessel','Left-choroid-plexus', \
'Right-Lateral-Ventricle','Right-Inf-Lat-Vent','Right-Cerebellum-White-Matter', \
'Right-Cerebellum-Cortex','Right-Thalamus-Proper','Right-Caudate','Right-Putamen','Right-Pallidum', \
'Right-Hippocampus','Right-Amygdala','Right-Accumbens-area','Right-VentralDC','Right-vessel','Right-choroid-plexus', \
'5th-Ventricle','WM-hypointensities','Left-WM-hypointensities','Right-WM-hypointensities', \
'non-WM-hypointensities','Left-non-WM-hypointensities','Right-non-WM-hypointensities', \
'Optic-Chiasm','CC_Posterior','CC_Mid_Posterior','CC_Central','CC_Mid_Anterior','CC_Anterior']

ASEG_STATS_HDR=['FS_InterCranial_Vol','FS_BrainSeg_Vol','FS_BrainSeg_Vol_No_Vent','FS_BrainSeg_Vol_No_Vent_Surf', \
'FS_LCort_GM_Vol','FS_RCort_GM_Vol','FS_TotCort_GM_Vol','FS_SubCort_GM_Vol','FS_Total_GM_Vol','FS_SupraTentorial_Vol', \
'FS_SupraTentorial_Vol_No_Vent','FS_SupraTentorial_No_Vent_Voxel_Count','FS_L_WM_Vol','FS_R_WM_Vol','FS_Tot_WM_Vol', \
'FS_Mask_Vol','FS_BrainSegVol_eTIV_Ratio','FS_MaskVol_eTIV_Ratio','FS_LH_Defect_Holes','FS_RH_Defect_Holes','FS_Total_Defect_Holes']

ASEG_STATS_DICT={
	'etiv':'# Measure EstimatedTotalIntraCranialVol',
	'bseg':'# Measure BrainSeg',
	'bsegNV':'# Measure BrainSegNotVent',
	'bsegNVS':'# Measure BrainSegNotVentSurf',
	'lGM':'# Measure lhCortex',
	'rGM':'# Measure rhCortex',
	'totCortGM':'# Measure Cortex',
	'subCortGM':'# Measure SubCortGray',
	'totGM':'# Measure TotalGray',
	'supTent':'# Measure SupraTentorial',
	'supTentNV':'# Measure SupraTentorialNotVent',
	'supTentNVv':'# Measure SupraTentorialNotVentVox',
	'lWM':'# Measure lhCorticalWhiteMatter',
	'rWM':'# Measure rhCorticalWhiteMatter',
	'totCortWM':'# Measure CorticalWhiteMatter',
	'maskVol':'# Measure Mask',
	'etivRatio':'# Measure BrainSegVol-to-eTIV',
	'maskRatio':'# Measure MaskVol-to-eTIV',
	'lHoles':'# Measure lhSurfaceHoles',
	'rHoles':'# Measure rhSurfaceHoles',
	'totHoles':'# Measure SurfaceHoles',
}
class AsegVolStats:
	def __init__(self,n,v,m,s,r,min,max):
		self.nvox	= n
		self.vol	= v
		self.mean	= m
		self.std	= s
		self.range	= r
		self.min	= min
		self.max 	= max
	def __str__(self):
		return '%.1f,%d,%.4f,%.4f,%.1f,%.1f,%.1f'%(self.vol,self.nvox,self.mean,self.std,self.range,self.min,self.max)

class ProcessAsegStats:
	def __init__(self, data, verbose=False):
		self.data=data
		self.verbose=verbose
		self.values=dict()
		self.table=dict()
		self.process()
	def __str__(self):
		r='{etiv},{bseg},{bsegNV},{bsegNVS},{lGM},{rGM},{totCortGM},{subCortGM},{totGM}'.format(**self.values)
		r+=',{supTent},{supTentNV},{supTentNVv},{lWM},{rWM},{totCortWM}'.format(**self.values)
		r+=',{maskVol},{etivRatio},{maskRatio},{lHoles},{rHoles},{totHoles}'.format(**self.values)
		v=[str('%s'%(self.table[k])) for k in self.table]
		return r+','+','.join(v)
	def process(self):
		for key,item in ASEG_STATS_DICT.iteritems():
			self.values[key] = self.find_measure_pattern(item)
		for i,p in enumerate(ASEG_ROIS):
			index,vs = self.find_row_values(p)
			self.table[index] = vs
	def find_measure_pattern(self, pattern):
		row=None
		for i,line in enumerate(self.data):
			if line.lstrip().find(pattern) >= 0: 
				if self.verbose: 
					print '%s found on line-%04d: %s' % (pattern, i,line)
				row=line
				break
		e = -1
		if row: toks=row.split(', ')
		if row and len(toks) >= 4:
			try: e = float(toks[3])
			except ValueError: pass
		return e
	def find_row_values(self,pattern):
		row=None
		for i,line in enumerate(self.data):
			if line.lstrip().find(pattern) >= 0: 
				if self.verbose: 
					print '%s found on line-%04d: %s' % (pattern, i,line)
				row=line
				break
		index,nv,vol,m,s,min,max,r = -1,-1,-1,-1,-1,-1,-1,-1
		if row: toks=row.split()
		if row and len(toks) == 10:
			try:
				index = int(toks[0])
				nv = int(toks[2])
				vol = float(toks[3])
				m = float(toks[5])
				s = float(toks[6])
				min = float(toks[7])
				max = float(toks[8])
				r = float(toks[9])
			except ValueError: 
				pass
		vs = AsegVolStats(nv,vol,m,s,min,max,r)
		if self.verbose: print 'found VolStats("%s"): %s' % (pattern,vs)
		return index,vs

APARC_ROIS=['Bankssts','Caudalanteriorcingulate','Caudalmiddlefrontal','Cuneus','Entorhinal', \
'Fusiform','Inferiorparietal','Inferiortemporal','Isthmuscingulate','Lateraloccipital', \
'Lateralorbitofrontal','Lingual','Medialorbitofrontal','Middletemporal','Parahippocampal', \
'Paracentral','Parsopercularis','Parsorbitalis','Parstriangularis','Pericalcarine','Postcentral', \
'Posteriorcingulate','Precentral','Precuneus','Rostralanteriorcingulate','Rostralmiddlefrontal', \
'Superiorfrontal','Superiorparietal','Superiortemporal','Supramarginal','Frontalpole', \
'Temporalpole','Transversetemporal','Insula']

class AparcStats:
	def __init__(self,nv,sa,gv,ta,ts,mc,gc,fi,ci):
		self.nv	= nv
		self.sa	= sa
		self.gv	= gv
		self.ta	= ta
		self.ts	= ts
		self.mc	= mc
		self.gc	= gc
		self.fi	= fi
		self.ci	= ci
	def __str__(self):
		return '%d,%d,%d,%.3f,%.3f,%.3f,%.3f,%d,%.1f'%(self.nv,self.sa,self.gv,self.ta,self.ts,self.mc,self.gc,self.fi,self.ci)

class ProcessAparcStats:
	def __init__(self, data, verbose=False):
		self.data=data
		self.verbose=verbose
		self.table=dict()
		self.process()
	def __str__(self):	
		v=[str('%s'%(self.table[k])) for k in self.table]
		return ','.join(v)
	def process(self):
		for i,r in enumerate(APARC_ROIS):
			self.table[i] = self.find_row_values(r.lower())
	def find_row_values(self,pattern):
		row=None
		for i,line in enumerate(self.data):
			if line.lstrip().find(pattern) >= 0: 
				if self.verbose: 
					print '%s found on line-%04d: %s' % (pattern, i,line)
				row=line
				break
		nv,sa,gv,ta,ts,mc,gc,fi,ci = -1,-1,-1,-1,-1,-1,-1,-1,-1
		if row: toks=row.split()
		if row and len(toks) == 10:
			try:
				nv = int(toks[1])
				sa = int(toks[2])
				gv = float(toks[3])
				ta = float(toks[4])
				ts = float(toks[5])
				mc = float(toks[6])
				gc = float(toks[7])
				fi = float(toks[8])
				ci = float(toks[9])
			except ValueError: 
				pass
		s = AparcStats(nv,sa,gv,ta,ts,mc,gc,fi,ci)
		if self.verbose: print 'found AparcStats("%s"): %s' % (pattern,s)
		return s


class LGIStatsObject:
	def __init__(self,nv,a,m,s,min,max,r):
		self.nv = nv
		self.a = a
		self.m = m
		self.s = s
		self.min = min
		self.max = max
		self.r = r
	def __str__(self):
		return '%d,%.1f,%.4f,%.4f,%.4f,%.4f,%.4f'%(self.nv,self.a,self.m,self.s,self.min,self.max,self.r)
class ProcessLGI:
	def __init__(self, data, verbose=False):
		self.data=data
		self.verbose=verbose
		self.table=dict()
		self.process()
	def __str__(self):
		v=[str('%s'%(self.table[k])) for k in self.table]
		return ','.join(v)
	def process(self):
		for i,r in enumerate(APARC_ROIS):
			self.table[i] = self.find_row_values(r.lower())
	def find_row_values(self,pattern):
		row=None
		for i,line in enumerate(self.data):
			if line.lstrip().find(pattern) >= 0: 
				if self.verbose: 
					print '%s found on line-%04d: %s' % (pattern, i,line)
				row=line
				break
		nv,a,m,s,rmin,rmax,r = -1,-1,-1,-1,-1,-1,-1
		if row: toks=row.split()
		if row and len(toks) == 10:
			try:
				nv = int(toks[2])
				a = float(toks[3])
				m = float(toks[5])
				s = float(toks[6])
				rmin = float(toks[7])
				rmax = float(toks[8])
				r = float(toks[9])
			except ValueError: 
				pass
		s = LGIStatsObject(nv,a,m,s,rmin,rmax,r)
		if self.verbose: 
			print 'found LGIStatsObject("%s"): %s' % (pattern,s)
		return s

def process_aseg_statsfile(f):
	if not os.path.exists(f):
		print '*** ERROR: could not find aseg.stats file = %s' % (f)
		#raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), f)
		d = ''
	else:
		d = open(f,'rU').readlines()
	p = ProcessAsegStats(d)
	return p.__str__()

def process_aparc_statsfile(f):
	if not os.path.exists(f):
		print '*** ERROR: could not find aparc.stats file = %s' % (f)
		#raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), f)
		d = ''
	else:
		d = open(f,'rU').readlines()
	p = ProcessAparcStats(d)
	return p.__str__()

def process_lgi_statsfile(f):
	if not os.path.exists(f):
		print '*** ERROR: could not find lgi.stats file = %s' % (f)
		#raise FileNotFoundError(errno.ENOENT, os.strerror(errno.ENOENT), f)
		d = ''
	else:
		d = open(f,'rU').readlines()
	p = ProcessLGI(d)
	return p.__str__()

def calc_avgQC(qcrow):
	#print '++++++++++ processing qcrow=[%s]' % (qcrow)
	qctoks=qcrow.split(',')
	qcavg = -1
	if len(qctoks) < 4:
		print '*** ERROR: unable to parse 4 columns from qcrow=[%s]' % (qcrow)
		return qcavg
	qcvals=[]
	for t in qctoks[1:3]:
		try:
			r=float(t)
			qcvals.append(r)
		except ValueError:
			pass
	if len(qcvals) > 0:
		qcavg = sum(qcvals)/len(qcvals)
	return qcavg
		
def get_avg_QC(ssid, rawdir='/shared/uher/FORBOW/rawdata'):
	t1avg,t2avg = -1,-1
	t1Pattern='T1w'
	t2Pattern='T2w'
	if ssid[:-5] == 'FLAIR':
		t2Pattern='T2wPrep'
	d=glob.glob(os.path.join(rawdir,'%s*'%ssid[:5]))
	if len(d) != 1:
		print '*** ERROR: could not locate rawdata directory for SSID=%s' % (ssid)
		return t1avg,t2avg 
	qcfile=os.path.join(d[0],'%s_qc_ratings.csv'%ssid[:5])
	if not os.path.exists(qcfile):
		print '*** ERROR: could not locate QC-ratings file=%s' % (qcfile)
		return t1avg,t2avg
	qcfilerows=open(qcfile,'rU').read().split()
	for row in qcfilerows[1:]:
		if len(row) >= len(t1Pattern) and row[:(len(t1Pattern))] == t1Pattern:
			t1avg=calc_avgQC(row)
		elif len(row) >= len(t2Pattern) and row[:(len(t2Pattern))] == t2Pattern:
			t2avg=calc_avgQC(row)
	return t1avg,t2avg

		
def parse_QC_row(qcrow):
	qctoks = qcrow.split(',')
	#print '++++++++++ parsing qcrow=[%s]' % (qcrow)
	qcvals = ['.','.','.']
	if len(qctoks) != 4:
		print '*** ERROR: unable to parse 4 columns from qcrow=[%s]' % (qcrow)
	else:
		for i,t in enumerate(qctoks[1:4]):
			try:
				f = float(t)
				qcvals[i] = '%.2f' % f
			except ValueError:
				qcvals[i] = '.'
	return qcvals

def get_all_QC(ssid, rawdir='/shared/uher/FORBOW/rawdata'):
	import csv
	t1v,t2v = ['.','.','.'],['.','.','.']
	qcstr = ','.join(t1v+t2v)
	t1Pattern='T1w'
	t2Pattern='T2w'		#assumes T2w is SSID_NP (NonPure)
	if ssid[-5:] == 'FLAIR':
		t2Pattern='T2Prep'
	d=glob.glob(os.path.join(rawdir,'%s_*'%ssid[:5]))
	if len(d) != 1:
		print '*** ERROR: could not locate rawdata directory for SSID=%s' % (ssid)
		return qcstr 
	qcfile=os.path.join(d[0],'%s_qc_ratings.csv'%ssid[:5])
	if not os.path.exists(qcfile):
		print '*** ERROR: could not locate QC-ratings file=%s' % (qcfile)
		return qcstr
	## OLD METHOD:
	#qcfilerows=open(qcfile,'rU').read().split()
	#for row in qcfilerows[1:]:
	#print 'opening qcfile=%s with csvreader...' % (qcfile)
	with open(qcfile,'rb') as csvfile:
		cRdr = csv.reader(csvfile, delimiter=',', quotechar='"')
		for row in cRdr:
			qcrow=','.join(row)
			#print 'qcrow=%s' % (qcrow)
			if len(qcrow) >= len(t1Pattern) and qcrow[:(len(t1Pattern))] == t1Pattern:
				t1v=parse_QC_row(qcrow)
			elif len(qcrow) >= len(t2Pattern) and qcrow[:(len(t2Pattern))] == t2Pattern:
				t2v=parse_QC_row(qcrow)
	qcstr = ','.join(t1v+t2v)
	if VERBOSE:
		print '+++ qcstr:',qcstr
	return qcstr

def process_cnr_file(cnrfile):
	cnrvals = ','.join('.'*16)
	if not os.path.exists(cnrfile):
		print '*** ERROR: could not locate file=%s' % (cnrfile)
		return cnrvals
	d=open(cnrfile,'rU').read().split()
	if len(d) == 16:
		try: 
			f = map(float,d)
			cnrvals = ','.join(d)
		except ValueError:
			pass
	return cnrvals
	
def process_wm_stats(wmfile, numROI):
	if not os.path.exists(wmfile):
		return ','.join(['.']*numROI*9)
	r = open(wmfile,'rU').read().splitlines()[1].split(',')
	return ','.join(r[1:])
	
def process_dwi_QC(dwiQCcsv):
	if not os.path.exists(dwiQCcsv):
		return '.,.'
	r = open(dwiQCcsv,'rU').read().splitlines()[1].split(',')
	return ','.join(r[1:3])
	
def report_wide_format(EDIR,ssid, isFORBOW=True):
	""" generate one long csv-string with all the HCP-like wide-formatted values"""
	SubjDir=os.path.join(EDIR,ssid)
	if not os.path.exists(SubjDir):
		print '* Warning: could not find specified StudyFolder/SubjectFolder=[%s]' % (SubjDir)
		return None
	if VERBOSE:
		print '-- Processing SubjectFolder: %s' % (SubjDir)
		cwd=os.getcwd()
		cmd='ls -l %s/T1w/%s/stats/*' % (SubjDir, ssid)
		run_shell_cmd(cmd,cwd)
	if REPORT_DTI_VALUES:
		dwiQCcsv=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_DWI_QC_motion_report.csv'%(ssid))
		if not os.path.exists(dwiQCcsv):
			print '* WARNING: cannot locate subjfile = %s' % (dwiQCcsv)
		wm20file=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FSL_WM20_vector_stats.csv'%(ssid))
		if not os.path.exists(wm20file):
			print '* WARNING: cannot locate subjfile = %s' % (wm20file)
		wm48file=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FSL_WM48_vector_stats.csv'%(ssid))
		if not os.path.exists(wm48file):
			print '* WARNING: cannot locate subjfile = %s' % (wm48file)
		wmparcFile=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FS_wmparc_vector_stats.csv'%(ssid))
		if not os.path.exists(wmparcFile):
			print '* WARNING: cannot locate subjfile = %s' % (wmparcFile)
		wmHemiFile=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FS_WM_Hemisphere_stats.csv'%(ssid))
		if not os.path.exists(wmHemiFile):
			print '* WARNING: cannot locate subjfile = %s' % (wmHemiFile)	
	qcstr,aseg,lh_aparc,rh_aparc,lh_lgi,rh_lgi = '','','','','',''
	if isFORBOW:
		qcstr = '.,.,.,.,.,.'
		if REPORT_QC_AVERAGE: 
			qcstr = '.,.'
	try:
		aseg = process_aseg_statsfile('%s/T1w/%s/stats/aseg.stats' % (SubjDir, ssid))
		lh_aparc = process_aparc_statsfile('%s/T1w/%s/stats/lh.aparc.stats' % (SubjDir, ssid))
		rh_aparc = process_aparc_statsfile('%s/T1w/%s/stats/rh.aparc.stats' % (SubjDir, ssid))
		lh_lgi = process_lgi_statsfile('%s/T1w/%s/stats/lh.aparc.pial_lgi.stats' % (SubjDir, ssid))
		rh_lgi = process_lgi_statsfile('%s/T1w/%s/stats/rh.aparc.pial_lgi.stats' % (SubjDir, ssid))
		cnrvals = process_cnr_file('%s/logs/%s_T1w_cnr.txt'%(SubjDir,ssid))
		if REPORT_DTI_VALUES:
			wm20vals = process_wm_stats(wm20file, 20)
			wm48vals = process_wm_stats(wm48file, 48)
			wmparcVals = process_wm_stats(wmparcFile, 70)
			wmHemiVals = process_wm_stats(wmHemiFile, 2)
			dwiQCvals = process_dwi_QC(dwiQCcsv)
		if isFORBOW:		
			if REPORT_QC_AVERAGE: 
				t1qc,t2qc = get_avg_QC(ssid)
				#print '++++ %s: t1avg=%f, t2avg=%f' % (ssid,t1qcavg,t2qcavg)
				qcstr='%f,%f' % (t1qc,t2qc)
			else:
				qcstr = get_all_QC(ssid)
				#print '++++ qcV:',qcV
				#qcstr = ','.join(qcV)
	except FileNotFoundError:
		print 'cannot find file for SSID=%s, exiting...' %(ssid)
		sys.exit(1)
	if REPORT_DTI_VALUES:
		return ','.join([qcstr,cnrvals,aseg,lh_aparc,rh_aparc,lh_lgi,rh_lgi,wm20vals,wm48vals,wmparcVals,wmHemiVals,dwiQCvals])
	else:
		return ','.join([qcstr,cnrvals,aseg,lh_aparc,rh_aparc,lh_lgi,rh_lgi])

def generate_csvfile_header(EDIR, iSubj):
	qcStr='SSID'
	#if isFORBOW:
	if REPORT_QC_AVERAGE:
		qcStr='SSID,T1wQC_avg,T2wQC_avg'
	else:
		qcStr='SSID,T1wQC_VD,T1wQC_HV,T1wQC_CH,T2wQC_VD,T2wQC_HV,T2wQC_CH'
	hdrStr=qcStr+',T1_FS_L_GrayWhite_CNR,T1_FS_L_GrayCSF_CNR,T1_FS_L_WMm,T1_FS_L_GMm,T1_FS_L_CSFm,T1_FS_L_WMstd,T1_FS_L_GMstd,T1_FS_L_CSFstd'
	hdrStr+=',T1_FS_R_GrayWhite_CNR,T1_FS_R_GrayCSF_CNR,T1_FS_R_WMm,T1_FS_R_GMm,T1_FS_R_CSFm,T1_FS_R_WMstd,T1_FS_R_GMstd,T1_FS_R_CSFstd'
	hdrStr+=',%s'%(','.join(ASEG_STATS_HDR))
	for h in ASEG_ROI_NAMES:
		hdrStr+=',%s_Vol,%s_Vox,%s_Mean,%s_Std,%s_Min,%s_Max,%s_Range' % (h,h,h,h,h,h,h)
	for h in APARC_ROIS:
		hdrStr+=',FS_L_%s_NumVert,FS_L_%s_Area,FS_L_%s_GrayVol,FS_L_%s_Thck,FS_L_%s_ThckStd,FS_L_%s_MeanCurv,FS_L_%s_GausCurv,FS_L_%s_FoldInd,FS_L_%s_CurveInd'%(h,h,h,h,h,h,h,h,h)
	for h in APARC_ROIS:
		hdrStr+=',FS_R_%s_NumVert,FS_R_%s_Area,FS_R_%s_GrayVol,FS_R_%s_Thck,FS_R_%s_ThckStd,FS_R_%s_MeanCurv,FS_R_%s_GausCurv,FS_R_%s_FoldInd,FS_R_%s_CurveInd'%(h,h,h,h,h,h,h,h,h)
	for h in APARC_ROIS:
		hdrStr+=',LGI_L_%s_NumVert,LGI_L_%s_Area,LGI_L_%s_Mean,LGI_L_%s_Std,LGI_L_%s_Min,LGI_L_%s_Max,LGI_L_%s_Range'%(h,h,h,h,h,h,h)
	for h in APARC_ROIS:
		hdrStr+=',LGI_R_%s_NumVert,LGI_R_%s_Area,LGI_R_%s_Mean,LGI_R_%s_Std,LGI_R_%s_Min,LGI_R_%s_Max,LGI_R_%s_Range'%(h,h,h,h,h,h,h)
	SubjDir=os.path.join(EDIR, iSubj)
	if REPORT_DTI_VALUES:
		## open file, grab first row, confirm more than 10 columns, remove first column and add to hdrStr
		wm20file=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FSL_WM20_vector_stats.csv'%(iSubj))
		if not os.path.exists(wm20file):
			print '*** ERROR: cannot locate example file = %s' % (wm20file)
			return hdrStr
		r1 = open(wm20file,'rU').read().splitlines()[0].split(',')
		if len(r1) < 181:
			print '* WARNING: wm20file=[%s] has only %d columns, should have 181' % (wm20file, len(r1))
		else:
			hdrStr+=','+','.join(r1[1:])
		wm48file=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FSL_WM48_vector_stats.csv'%(iSubj))
		if not os.path.exists(wm48file):
			print '*** ERROR: cannot locate example file = %s' % (wm48file)
			return hdrStr
		r1 = open(wm48file,'rU').read().splitlines()[0].split(',')
		if len(r1) < 433:
			print '* WARNING: wm48file=[%s] has only %d columns, should have 433' % (wm48file,len(r1))
		else:
			hdrStr+=','+','.join(r1[1:])
		wmparcfile=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FS_wmparc_vector_stats.csv'%(iSubj))
		if not os.path.exists(wmparcfile):
			print '*** ERROR: cannot locate example file = %s' % (wmparcfile)
			return hdrStr
		r1 = open(wmparcfile,'rU').read().splitlines()[0].split(',')
		if len(r1) < 631:
			print '* WARNING: wmparcfile=[%s] has only %d columns, should have 631' % (wmparcfile,len(r1))
		else:
			hdrStr+=','+','.join(r1[1:])
		wmHemiFile=os.path.join(SubjDir,'DWI/6_AtlasROIs/%s_FS_WM_Hemisphere_stats.csv'%(iSubj))
		if not os.path.exists(wmHemiFile):
			print '*** ERROR: cannot locate example file = %s' % (wmHemiFile)
			return hdrStr
		r1 = open(wmHemiFile,'rU').read().splitlines()[0].split(',')
		if len(r1) < 19:
			print '* WARNING: wmHemiFile=[%s] has only %d columns, should have 19' % (wmHemiFile,len(r1))
		else:
			hdrStr+=','+','.join(r1[1:])
		hdrStr+=',DWI_QC_motion_abs_rms_mean,DWI_QC_motion_rel_rms_mean'
	return hdrStr	


def process(EDIR,outfile,SubjList):
	if not os.path.exists(EDIR):
		print '*** ERROR: could not locate given StudyPath=[%s]\n' % (EDIR)
		usage()
	isForbow=False
	if EDIR == '/shared/uher/FORBOW/NIHPD_analysis':
		isForbow=True
	hdr = generate_csvfile_header(EDIR,SubjList[0])
	ofp = open(outfile,'w')
	ofp.write('%s\n'%hdr)
	for ssid in SubjList:
		one_wide_row = report_wide_format(EDIR,ssid)
		ofp.write('%s,%s\n' % (ssid,one_wide_row))
	ofp.close()
	print ' --- results written to output file = %s' % outfile
	return

if __name__=='__main__':
	#print '+++++ nargs=%d, args=%s' % (len(sys.argv),','.join(sys.argv))
	if len(sys.argv) < 2:
		usage()
	timestr = time.strftime('%Y%m%d',time.localtime())
	SCRIPT = os.path.abspath(sys.argv[0])
	SCRIPTDIR = os.path.dirname(SCRIPT)
	EDIR = os.path.dirname(SCRIPTDIR)
	outfile = EDIR+'/_2_results/%s_master_results.csv' % (timestr)
	try:
		opts,args = getopt.getopt(sys.argv[1:],'he:o:',['help','experiment-directory=','outfile='])
	except getopt.GetoptError:
		usage()
	for o,a in opts:
		if o in ('-e','--experiment-directory'):
			EDIR = a
			if not os.path.isdir(EDIR):
				print '*** ERROR: could not find specified experiment directory = %s' % (EDIR)
				sys.exit(1)
		elif o in ('-o','--outfile'):
			outfile = a
			if os.path.isfile(outfile):
				print '* Warning: output file \'%s\' exists. Specify another name or remove existing file...' % (outfile)
				sys.exit(1)
		elif o in ('-h','--help'):
			print '-h/--help: printing usage'
			usage()
	print '++ EDIR:',EDIR
	print '++ outfile:',outfile
	print '++ ssid-list:',args
	process(EDIR,outfile,args)
	sys.exit(0)

