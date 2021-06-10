#!/usr/bin/env python2

import os,sys


def usage():
	print ' Usage: %s </path/to/eddyqc_squad/group_db.json> </path/to/eddyqc_group_subjlist.txt>' %(os.path.basename(sys.argv[0]))
	sys.exit(1)


def json2csv(jsonInFile,ssidInFile,csvOutFile):
	import json
	D={}
	with open(jsonInFile,'r') as jFile:
		D = json.load(jFile)
	#print ' ----> json-data:',D
	SSIDs = open(ssidInFile,'rU').read().split()
	#print ' ----> SSIDS = %s' % (','.join(SSIDs))
	if len(SSIDs) != int(D['data_no_subjects']):
		print '*** ERROR: number of SSIDs=%d, JSON-data_no_subjects=%d ...' % (len(SSIDs),int(D['data_no_subjects']))
		sys.exit(2)
	hdr='SSID,numB0vols,numDIRvols,qcSNRavg,qcCNRavg,qcAvgAbsMot,qcAvgRelMot,qcOutliersTotPerc,qcOutliersB1000Perc,qcOutliersPerc_peAP,qcParam1,qcParam2,qcParam3,qcParam4,qcParam5,qcParam6,qcECxStd,qcECyStd,qcECzStd'
	R=[]
	R.append(hdr)
	for i in range(len(SSIDs)):
		S=SSIDs[i]
		nB0,nDIR = D['data_protocol'][i][0:2]
		qcSNR,qcCNR = D['qc_cnr'][i][0:2]
		qcAbsMot,qcRelMot = D['qc_motion'][i][0:2]
		qcOL1,qcOL2,qcOL3 = D['qc_outliers'][i][0:3]
		qcP1,qcP2,qcP3,qcP4,qcP5,qcP6,qcP7,qcP8,qcP9 = D['qc_parameters'][i][0:9]
		row='%s,%d,%d,%.3f,%.3f,%.2f,%.2f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f,%.5f' % (S,nB0,nDIR,qcSNR,qcCNR,qcAbsMot,qcRelMot,qcOL1,qcOL2,qcOL3,qcP1,qcP2,qcP3,qcP4,qcP5,qcP6,qcP7,qcP8,qcP9)
		R.append(row)
	F=open(csvOutFile,'w')
	for row in R:
		F.write('%s\n'%(row))
	F.close()
	print ' ++ reformatted data written to file = %s\n' % (csvOutFile)
	return

if __name__ == '__main__':
	if len(sys.argv) < 2:
		usage()
	#print "input-args: ",sys.argv
	jsonInFile = os.path.abspath(sys.argv[1])
	jsonPath,jsonExt = os.path.splitext(jsonInFile) 
	if not os.path.exists(jsonInFile) or not jsonExt=='.json':
		print '*** ERROR: could not read jsonQC file = %s' % (jsonInFile)
		sys.exit(1)
	ssidInFile = os.path.abspath(sys.argv[2])
	if not os.path.exists(ssidInFile):
		print '*** ERROR: could not read SSID file = %s' % (ssidInFile)
		sys.exit(1)
	csvOutFile = jsonPath+'.csv'
	print ' ++ reformatting (%s, %s) from .json --> .csv' % (jsonInFile, ssidInFile)
	json2csv(jsonInFile, ssidInFile, csvOutFile)
	sys.exit(0)
	
