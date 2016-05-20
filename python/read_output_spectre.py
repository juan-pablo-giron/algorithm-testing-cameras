
#============================================================================#
# It algorithm extract the information of the desired signals and convert those 
# in a columnar ASCII format that could be plotting by Matlab or in python.
# Code written by: Juan Pablo Giron Ruiz supported by CAPES 2016
#============================================================================#

#============================  ALGORITHM ====================================#

def _sort_output_cadence_(File,Dir_output_matlab,name_output):
        
    
    l_signals = ['time']    #by default if the simulation was transient
    string_start = 'VALUE'  #default
    string_stop = 'END'     #default
    
    full_path_output = Dir_output_matlab+name_output
    full_path_output_header = Dir_output_matlab+'_signalsheader.csv'
    file_output = open(full_path_output,'w') # Create a file with the columnar ASCII format Only data
    file_output_header = open(full_path_output_header,'w')
    l_output = list(File.readlines())    # save the output as a list of strings
    l_output = [w.replace('\n','') for w in l_output] # remove the '\n' string 
    len_output = len(l_output)  # return the elements of the list l_output
    line_TRACE = l_output.index('TRACE')
    line_VALUE = l_output.index('VALUE')
    print "line_TRACE %d" %line_TRACE
    print "line_VALUE %d" %line_VALUE
    x = line_TRACE+1
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
                l_signals.append(string) # Get the names of the signals simulated
                x = x + 1
    
    print l_signals
    print "reading %d rows" %len_output   
    print 'We are working please wait a fews seconds'    
    
    len_signals = len(l_signals)# return the elements of the list l_signals
    i_start = line_VALUE + 1 # find the index where the for-loop need start.
    x = i_start
    file_output.seek(0,0) #the first line of the file
    string = ','.join(l_signals)
    header = string.replace('"','')
    file_output_header.write(header+'\n') # put the header of the file to get in matlab
    file_output_header.close()
    while x < len_output:
        if (l_output[x] == string_stop):
            file_output.close()
            break
        else:
            for i in range(0,len_signals):
                value = l_output[x+i].split()
                value = value[1]
                file_output.write(value)
                if ( i == len_signals-1):
                    file_output.write('\n')
                else:
                    file_output.write(',')
        x = x + len_signals
    print "signals>>"+str(l_signals)
    file_output.close()
    
