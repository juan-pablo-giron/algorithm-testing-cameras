
#============================================================================#
# It algorithm extract the information of the desired signals and convert those 
# in a columnar ASCII format that could be plotting by Matlab or in python.
# Code written by: Juan Pablo Giron Ruiz supported by CAPES 2016
#============================================================================#

#============================  ALGORITHM ====================================#

from getIndex_desiredSignals import getIndex_desiredSignals
import time
#def _sort_output_cadence_(File,Dir_output_matlab,name_output):

## Paths

PATH_sim_output_matlab = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/DVS2x2_X_Arbiter_TS_20res/output_matlab/'
PATH_folder_simulation = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/DVS2x2_X_Arbiter_TS_20res/'
name_simulation = 'DVS2x2_resol20'
name_folder_output_Spectre = 'DVS2x2_resol20.raw'
number_bits = 3;


start_time = time.time()

l_signals = ['time']    #by default if the simulation was transient
string_start = 'VALUE'  #default
string_stop = 'END'     #default
string_index_file = 'index_data'
string_data = 'data_'+name_simulation
lst_desired_signals = ['data','En_Read_Row','En_Read_pixel']
lst_bus_data = ['data']

File = open(PATH_folder_simulation+name_folder_output_Spectre+'/tran.tran','r')
file_data = open(PATH_sim_output_matlab+string_data+'.csv','w') # Create a file with the columnar ASCII format Only data
path_file_index = PATH_sim_output_matlab+string_index_file+'.csv'
file_header = open(PATH_sim_output_matlab+'header.txt','w')
l_output = list(File.readlines())    # save the output as a list of strings
l_output = [w.replace('\n','') for w in l_output] # remove the '\n' string 
len_output = len(l_output)  # return the elements of the list l_output
line_TRACE = l_output.index('TRACE')
line_VALUE = l_output.index('VALUE')
print "line_TRACE %d" %line_TRACE
print "line_VALUE %d" %line_VALUE
x = line_TRACE+1

## ---- obtain the names of the whole signals ----##

while x < line_VALUE:
    value = l_output[x].split()
    
    if ( len(value) == 1 ):
        # Correspond to ')' dont valid as signals
        x = x + 1
    else:
        string = value[1]
        
        if ( string == '"A"'):
            #correspond to the unit of the Current dont valid as signal
            x = x + 1
        else:
            string = value[0]
            string = string.replace('"','')
            l_signals.append(string) # Get the names of the signals simulated
            x = x + 1

## ------------------------------------------------##

##     CALLING THE FUNCTION TO CREATE THE INDEXs   ##

getIndex_desiredSignals(l_signals,lst_desired_signals,lst_bus_data,number_bits,path_file_index)


#####################################################

print l_signals
print "reading %d rows" %len_output   
print 'We are working please wait a fews seconds'    

len_signals = len(l_signals)# return the elements of the list l_signals
i_start = line_VALUE + 1 # find the index where the for-loop need start.
x = i_start
file_data.seek(0,0) #the first line of the file
string_header = ','.join(l_signals)
file_header.write(string_header) # write the header in the Header file.txt
file_header.close()
while x < len_output:
    if (l_output[x] == string_stop):
        file_data.close()
        break
    else:
        for i in range(0,len_signals):
            value = l_output[x+i].split()
            value = value[1]
            file_data.write(value)
            if ( i == len_signals-1):
                file_data.write('\n')
            else:
                file_data.write(',')
    x = x + len_signals
stop_time = time.time()
print "signals>>"+str(l_signals)
file_data.close()
print "We made it in %f seconds" %(stop_time-start_time)
