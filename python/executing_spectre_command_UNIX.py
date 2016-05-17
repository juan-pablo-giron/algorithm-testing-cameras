import os
import sys
from read_output_spectre import _sort_output_cadence_

## Get the parameters to init the script from UNIX terminal
path_DIR = sys.argv[1]
name_file = sys.argv[2]
name_output_file = sys.argv[3]
#########################################################################

#### setting the directory path of the file to be simulated #####
#path_DIR = "/home/netware/users/jpgironruiz/Documents/Cadence_analysis/"
os.chdir(path_DIR)
#name_file = 'DVS_ONE_PIXEL' # without extension
folder_output_sim = name_file+'.raw'
nameFilesim = 'tran.tran' ## _ If the simulation was transient _ ##
command_spectre = 'spectre -format psfascii +mt'
line2simulation = command_spectre+' '+name_file+'.scs'
print "executing >>> %s" %line2simulation

#########################  open cadence ##########################


_status = 1
while(_status == 1):

    _status=os.system(line2simulation)
    
print 'Compiled see the result at the directory defined before'

##### CALLING TO THE FUNCTION TO TRANSFORM TO VALID FORMAT TO PLOT #####

path_DIR2 = path_DIR+folder_output_sim
os.chdir(path_DIR2)
File = open(nameFilesim,'r')
#name_output_file = input('Write the name of the output file with extension (.csv,.txt) \n')
_sort_output_cadence_(File,path_DIR,name_output_file) # called to the function





