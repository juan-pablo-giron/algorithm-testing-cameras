
#============================================================================#
# It algorithm extract the information of the desired signals and convert those 
# in a columnar ASCII format that could be plotting by Matlab or in python.
# Code written by: Juan Pablo Giron Ruiz supported by CAPES 2016
#============================================================================#

#============================  ALGORITHM ====================================#

from getIndex_desiredSignals import getIndex_desiredSignals
import time
import os

## Getting the enviroment variables

PATH_sim_output_matlab = os.environ['PATH_sim_output_matlab'] 
PATH_folder_simulation = os.environ['PATH_folder_simulation']
name_simulation = os.environ['name_simulation']
name_folder_output_Spectre = os.environ['name_folder_output_Spectre']  
number_bits = int(os.environ['number_bits'])
name_tran = 'tran.tran'




start_time = time.time()

l_signals = ['time']                #by default if the simulation was transient
string_start = 'VALUE'              #default
string_stop = 'END'                 #default
string_index_file = 'index_data'    #DVS
string_index_file_A = 'index_data_A'  #ATIS
string_data = 'data_'+name_simulation

#DVS
lst_desired_signals = ['data','En_Read_Row','En_Read_pixel','Global_rst']
lst_bus_data = ['data']

#ATIS
lst_desired_signals_A = ['data_A','En_Read_Row_A','En_Read_pixel_A','Global_rst','Req_fr']
lst_bus_data_A = ['data_A']


File = open(PATH_folder_simulation+name_folder_output_Spectre+'/'+name_tran,'r')
file_data = open(PATH_sim_output_matlab+string_data+'.csv','w') # Create a file with the columnar ASCII format Only data
path_file_index = PATH_sim_output_matlab+string_index_file+'.csv' #DVS
path_file_index_A = PATH_sim_output_matlab+string_index_file_A+'.csv' #ATIS
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

getIndex_desiredSignals(l_signals,lst_desired_signals,lst_bus_data,number_bits,path_file_index) #DVS
getIndex_desiredSignals(l_signals,lst_desired_signals_A,lst_bus_data_A,number_bits,path_file_index_A) #ATIS

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


