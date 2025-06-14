##  $ dispel4py multi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -n 4 -s
#
# or
#
#  $ mpiexec -n 4 dispel4py mpi int_ext_graph.py -d '{"read" : [ {"input" : "coordinates.txt"} ]}' -s
#
#
#
#
#
# Note that there might be a problem when running without "-s". You will see the following error:
#
# GetVOTable1 (rank 1): reading VOTable RA=16.48295, DEC=4.0905
# Process Process-3:
# Traceback (most recent call last):
#   File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/multiprocessing/process.py", line 258, in _bootstrap
#     self.run()
#   File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/multiprocessing/process.py", line 114, in run
#     self._target(*self._args, **self._kwargs)
#   File "/Users/akrause/development/envs/test.astro/lib/python2.7/site-packages/dispel4py/new/multi_process.py", line 56, in _processWorker
#     wrapper.process()
#   File "/Users/akrause/development/envs/test.astro/lib/python2.7/site-packages/dispel4py/new/processor.py", line 124, in process
#     inputs, status = self._read()
#   File "/Users/akrause/development/envs/test.astro/lib/python2.7/site-packages/dispel4py/new/multi_process.py", line 154, in _read
#     data, status = self.input_queue.get()
#   File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/multiprocessing/queues.py", line 117, in get
#     res = self._recv()
# ValueError: ('itemsize cannot be zero', <built-in function scalar>, (dtype('S'), ''))
#
# This is a numpy bug. See: http://stackoverflow.com/questions/21863162/pickle-valueerror-itemsize-cannot-be-zero
import numpy

from dispel4py.core import GenericPE
from dispel4py.base import IterativePE
from dispel4py.workflow_graph import WorkflowGraph

import requests
from astropy.io.votable import parse_single_table
import io
import sys
import math

type_dict={"E":-5, "E-S0":-3, "S0":-2, "S0a":0, "Sa":1, "Sab":2, "Sb":3, "Sbc":4, "Sc":6, "Scd":7, "Sd":8, "Sm":9, "SBa":1, "SBab":2, "SBb":3, "SBbc":4, "SBc":6, "SBcd":7, "SBd":8, "SBm":9}

C=0.04

def internal_extinction(mtype, logr25):
    if mtype in type_dict:
        type=float(type_dict[mtype])
    else:
        type=-10.

    k=0.754*10**(-0.2*(type))
    if k>1.:
        k=1.
        
    #Calculating K2

    if type<0:
        K2 = 0.12-0.007*(type)
    else:
        K2=0.094
    #Calculating R
    R = 10.**logr25
            
    #Finally it calculates ai
    #ai=-2.5*log(k+(1.0-k)*R*((2.0*C*(1+0.2/K2)-1)))
    tmp=2*C*(1+0.2/K2)-1
            
    ai=-2.5*math.log10(k+(1-k)*R**tmp)
                
    return type,ai

class ReadRaDec(GenericPE):
    def __init__(self):
        GenericPE.__init__(self)
        self._add_output('output')
    def _process(self, inputs):
        file = inputs['input']
        #print('Reading file %s' % file)
        with open(file) as f:
            count = 0
            for line in f:
                count+= 1
                ra, dec = line.strip().split(',')
                self.write('output', [count, ra, dec, 0.001])

class GetVOTable(IterativePE):
    def __init__(self):
        IterativePE.__init__(self)
    def _process(self, data):
        count, ra, dec, sr = data
        print('reading VOTable RA=%s, DEC=%s' % (ra,dec))
        url = 'http://vizier.u-strasbg.fr/viz-bin/votable/-A?-source=VII/237&RA=%s&DEC=%s&SR=%s' % (ra, dec, sr)
        response = requests.get(url)
        #print("response %s" % response.text)
        return [count, ra, dec, response.text]

class FilterColumns(IterativePE):
    def __init__(self):
        IterativePE.__init__(self)
    def _process(self, data):
        count, ra, dec, votable_xml = data
        table = parse_single_table(io.BytesIO(votable_xml.encode('utf-8')))
        results = [count, ra, dec]
        
        for c in self.columns:
            try:
                value = table.array[c].data[0] # we assume that there's only one row in the table
                if isinstance(value, numpy.float32): # convert to python float to allow json serialize
                    value = float(value)
            except:
                value = None
            results.append(value)
            #print('extracted column: %s = %s' % (c, value))
        return results

class InternalExtinction(IterativePE):
    def __init__(self):
        IterativePE.__init__(self)
    def _process(self, data):
        count, ra, dec = data[0:3]
        mtype = data[3]
        logr25 = data[4]
        #print("!! DATA mytype:%s, logr25:%s" %(mtype,logr25))
        try:
            t, ai = internal_extinction(mtype, logr25)
            result = [count, ra, dec, mtype, logr25, t, ai]
            print('internal extinction: %s' % result)
            return result
        except:
            # print('KIG%s: failed to calculate internal extinction' % count)
            pass

graph = WorkflowGraph()
read = ReadRaDec()
read.name = 'read'
votab = GetVOTable()
filt = FilterColumns()
filt.columns = ['MType', 'logR25']
intext = InternalExtinction()
graph.connect(read, 'output', votab, 'input')
graph.connect(votab, 'output', filt, 'input')
graph.connect(filt, 'output', intext, 'input')
