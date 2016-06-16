## --------------------------------------------------- ##
## This algorithm does the plot in 3D of the transient
## response retuned by Spectre. It algorithm is designed
## to work concurrently with the transient simulation
## minimizing the time of processing and given the plot
## at the same time of the end of the simulation.
## Designed by Juan Pablo Giron jpgironruiz@gmail.com

## ------------------- IMPORT MODULES ---------------- ##

import time
import numpy as np
import matplotlib as plt
import sys
import os

PATH_sim_output_matlab = os.environ['PATH_sim_output_matlab']
name_matlab_output = os.environ['name_matlab_output']
PATH_folder_simulation = os.environ['PATH_folder_simulation']
name_simulation = os.environ['name_simulation']
numRows = os.environ['numRows']
numCols = os.environ['numCols']

quant_pixels = numRows*numCols
value_1 = 1.2;  #Define the minimum voltage to say that is '1' logical
value_0 = 0.02; #Define the minimum voltage to say that is '0' logical

name_signals = 'V_pd,I_pd,Vout_sf,Voff,Von,C_OFF_REQ,C_ON_REQ,C_OFF_ACK,C_ON_ACK,Vrst'
lst_name_signals = name_signals.split(',')

## Entry to simulation folder

os.chdir(PATH_folder_simulation)

max_time_creation_sim = 120; #seconds
start = time.time()


##### Step 1 #####
# Verify if netlist_namesimulation.raw directory exists.
exist_dir_sim = os.path.isdir('netlist_'+name_simulation+'.raw')
while not(exist_dir_sim):
    stop = time.time()
    if stop-time > max_time_creation_sim:
        sys.exit(0)
    else:
        exist_dir_sim = os.path.isdir('netlist_'+name_simulation+'.raw')

os.chdir('netlist_'+name_simulation+'.raw')

# Verify if the file called tran.tran exist
name_file = 'tran.tran'
start = time.time()
exist_file_sim = os.path.isfile(name_file)
while not(exist_file_sim):
    stop = time.time()
    if stop-time > max_time_creation_sim:
        sys.exit(0)
    else:
        exist_file_sim = os.path.isfile(name_file)


# Reading the tran.tran file
file_simulation = open('tran.tran','r')
l_signals = ['time']    #by default if the simulation was transient
string_start = 'VALUE'  #default
string_stop = 'END'     #default

#os.chdir(PATH_sim_output_matlab)


def all_indices(value, qlist):
    indices = []
    idx = -1
    while True:
        try:
            idx = qlist.index(value, idx+1)
            indices.append(idx)
        except ValueError:
            break
    return indices
        
    
    
    











    

    
