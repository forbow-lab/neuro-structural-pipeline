#!/usr/bin/env python2

import os
import sys
import subprocess


HDR_ROW='file,lh-GrayWhiteCNR,lh-GrayCsfCNR,lh-Wm,lh-Gm,lh-CSFm,lh-Wv,lh-Gv,lh-CSFv,rh-GrayWhiteCNR,rh-GrayCsfCNR,rh-Wm,rh-Gm,rh-CSFm,rh-Wv,rh-Gv,rh-CSFv'


def clean(fn, printHDR=False):
	
	f=open(fn,'Ur')
	x=f.read().splitlines()
	f.close()
	
	if len(x) < 2:
		print '*** ERROR: found less than two lines in file=[%s]' % (fn)
		sys.exit(2)
		
	d=x[:2]
	m = d[0].split(' ') + d[1].split(' ')
	#print 'len(m):',len(m)
	if printHDR:
		print HDR_ROW
	print fn + ',' + ','.join(m)


def run_cnr(fsurfdir):
	if not os.path.exists(fsurfdir):
		print '*** ERROR: could not read or open specified Freesurfer output directory:', fsurfdir
	surfdir = os.path.join(fsurfdir,'surf')
	if not os.path.exists(surfdir):
		print '*** ERROR: cannot read or open specified Freesurfer output directory:', surfdir
	origfile = os.path.join(fsurfdir,'orig', 'orig.mgz')
	if not os.path.exists(origfile):
		print '*** ERROR: cannot read or open specified Freesurfer output file:', origfile
	logfile = os.path.join(fsurfdir,'stats', 'orig_cnr_raw.log')
	if not os.path.exists(logfile):
		print '* WARNING: removing existing cnr stats raw output file:', logfile
		os.path.remove(logfile)
	subprocess.check_output([os.path.join(os.environ['FREESURFER_HOME'],'bin','mri_cnr'),'-l',logfile,surfdir,origfile])
	
	

def Usage():
	print '\n\nUsage: %s <options> <mri_cnr-output.txt>\n' % (os.path.basename(sys.argv[0]))
	print '  Options:  -hdr     : prints header row before data'
	print '\n'
	sys.exit(1)


if __name__ == '__main__':
	if len(sys.argv) <= 1:
		Usage()
	else:
		printHDR=False
		args=sys.argv[1:]
		if args[0] == '-hdr':
			printHDR=True
			args = args[1:]
		for a in args:
			clean(os.path.abspath(a), printHDR)
	sys.exit(0)
