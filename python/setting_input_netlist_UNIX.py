#============================================================================#
# It algorithm set-up the signals for each pixel, since modify the name of the 
# currents specified by Spectre, and put it with a intituive name I_pd# where
# # is the number of the pixel within the array of pixels.
# here is necessary that the user specify from the schematic made from Cadence
# the correct name of the node Voltage of the Photo-Diode, in this case the default
# is V_pd#. # indicates the before idea.
# Made by: Juan Pablo Giron Supported by CAPES 2016 COPPE/UFRJ/RJ/BRAZIL
#============================================================================#

import os
import sys
#============================  ALGORITHM ====================================#

##############   inputs   #########################
PATH_netlist_spectre = sys.argv[1]
PATH_output_netlist = sys.argv[2]
PATH_signal_input = sys.argv[3]
nameNetlist = sys.argv[4]  #spectre's netlist
nameNetlistoutput = sys.argv[5] # netlist modified
name_signal_input = sys.argv[6] # name of the data without extension and number_
ext_input = sys.argv[7]
quant_pixels = int(sys.argv[8])
period_signal = float(sys.argv[9])
txt_desired_signals = sys.argv[10]
name_n_Voltage = 'V_pd'
name_n_Current = 'I_pd'
name_instance = 'I'
name_subckts = 'subckts'

################ end inputs ######################



l_nodevoltageNames = []     # Save the name of the node voltage
l_nodecurrentNames = []     # Save the name of the nodes current name
f = open(PATH_netlist_spectre+nameNetlist,'r')
f_netlist = open(PATH_output_netlist+nameNetlistoutput+'.scs','w')
l_netlist = list(f.readlines())
l_netlist = [w.replace('\n','') for w in l_netlist] # Here is storaged the netlist as a list 
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
len_desired_signals = len(lst_desired_signals)
lst_desired_signals = txt_desired_signals.split(',')
f.close()
#### Create the lists with the names of the node voltage/current expected #####

x = 0
while x <quant_pixels:
    nodeVoltageName = name_n_Voltage+str(x)
    nodeCurrentName = name_n_Current+str(x)
    l_nodevoltageNames.append(nodeVoltageName)
    l_nodecurrentNames.append(nodeCurrentName)
    x = x + 1

len_nodeVoltageName = len(l_nodevoltageNames)

print l_nodevoltageNames
print l_nodecurrentNames

################################################################################

#### Search for the node voltage connected to the specific current source
#### and both change the name of the current source as the file data


################## Replacing the I source by intuitive names ########### 
i = 0
f_netlist.seek(0,0)
while i<len_nodeVoltageName:
    nameVoltageName = l_nodevoltageNames[i]
    x = 0
    while x < len_netlist:
        string = l_netlist[x]
        find_nameVoltage = string.find(nameVoltageName)

        if (find_nameVoltage == -1):
            # There is not
            
            x = x + 1
        else:
            find_str_isource = string.find('isource') # Guarantee that the I is by a source current and not for
            # other instance e.g. DVS or ATIS, etc
            if find_str_isource == -1:
                #Does not corresponde to a current source
                x = x + 1
            else:
                # Really correspond to a current source

                ### Find the next instance ###
                x_nextInstance = x+1
                string_next = l_netlist[x_nextInstance]
                lst_tmp = string_next.split(' ') #convert the string into a list
                instance = lst_tmp[0] #always take the first element of the row 'cause there is the name instance
                while not(name_instance in instance):
                    x_nextInstance = x_nextInstance+1
                    string_next = l_netlist[x_nextInstance]
                    lst_tmp = string_next.split(' ')
                    instance = lst_tmp[0] #always take the first element of the row 'cause there is the name instance
                ### End the next instance
                    
                del l_netlist[x:x_nextInstance]                
                FILE_PATH = 'file='+'"'+ PATH_signal_input+name_signal_input+str(i)+ext_input+'"'
                new_row = l_nodecurrentNames[i]+' '+'('+l_nodevoltageNames[i]+' '+'0)'+' '+'isource'+' '+ \
                          FILE_PATH+' '+'type=pwl'+' '+'scale=1'+' '+'stretch=1'+' '+'pwlperiod='+str(period_signal)

                l_netlist.insert(x,new_row)
                             
                x = len_netlist
                len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
    i = i + 1

######################## Specifying the desired outputs #########################

x = 0
i=0
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'

while x < len_netlist:
    string = l_netlist[x]
    if (name_subckts  in string):
        # Delete all the row and write new ones
        del l_netlist[x:len_netlist-1]
        while i<len_nodeVoltageName:
            index_n_signals = 0
            while (index_n_signals<len_desired_signals):
                string = lst_desired_signals[index_n_signals]
                new_line = 'save '+string+str(i)
                if lst_desired_signals[index_n_signals]== name_n_Current:
                    new_line = new_line+':sink'
                    l_netlist.append(new_line)
                else:
                    
                    l_netlist.append(new_line)
                index_n_signals = index_n_signals+1
            i = i+1
        x = len_netlist
    else:
        # continue finding 
        x = x + 1

l_netlist.append('saveOptions options save=selected')


#################### Here is written the new netlist #############################
x = 0
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
while x < len_netlist:
    f_netlist.write(l_netlist[x])
    f_netlist.write('\n')
    x = x + 1

f_netlist.close()
#end of code

