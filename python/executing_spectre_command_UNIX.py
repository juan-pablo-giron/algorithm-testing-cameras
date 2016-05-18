import os
import sys
from read_output_spectre import _sort_output_cadence_

## Get the parameters to init the script from UNIX terminal
PATH_netlist = sys.argv[1]
name_Netlist = sys.argv[2]
PATH_sim_output_matlab = sys.argv[3]
name_output_file = sys.argv[4]
#########################################################################

#### setting the directory path of the file to be simulated #####
#path_DIR = "/home/netware/users/jpgironruiz/Documents/Cadence_analysis/"
#os.chdir(path_DIR)
#name_file = 'DVS_ONE_PIXEL' # without extension
folder_output_sim = name_Netlist+'.raw'
nameFilesim = 'tran.tran' ## _ If the simulation was transient _ ##
command_spectre = 'spectre -format psfascii +mt'
line2simulation = command_spectre+' '+PATH_netlist+name_Netlist+'.scs'
print "executing >>> %s" %line2simulation

#########################  open cadence ##########################


_status = 1
while(_status == 1):

    _status=os.system(line2simulation)
    
print 'Compiled see the result at the directory defined before'


##### CALLING TO THE FUNCTION TO TRANSFORM TO VALID FORMAT TO PLOT #####

full_PATH_sim_output_spectre = PATH_netlist+folder_output_sim+'/'+nameFilesim
print
File = open(full_PATH_sim_output_spectre,'r')

_sort_output_cadence_(File,PATH_sim_output_matlab,name_output_file) # called to the function





