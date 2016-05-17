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
name_n_Voltage = 'V_pd'
name_n_Current = 'I_pd'
################ end inputs ######################

l_nodevoltageNames = []     # Save the name of the node voltage
l_nodecurrentNames = []     # Save the name of the nodes current name
f = open(PATH_netlist_spectre+nameNetlist,'r')
f_netlist = open(PATH_output_netlist+nameNetlistoutput+'.scs','w')
l_netlist = list(f.readlines())
l_netlist = [w.replace('\n','') for w in l_netlist] # Here is storaged the netlist as a list 
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
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


i = 0
f_netlist.seek(0,0)
while i<len_nodeVoltageName:
    nameVoltageName = l_nodevoltageNames[i]
    x = 0
    while x < len_netlist:
        string = l_netlist[x]
        find_nameVoltage = string.find(nameVoltageName)

        if (find_nameVoltage == -1):
            # There is no
            
            x = x + 1
        else:
            find_str_isource = string.find('isource') # Guarantee that the I is by a source current and not for
            # other instance e.g. DVS or ATIS, etc
            if find_str_isource == -1:
                #Does not corresponde to a current source
                                x = x + 1
            else:
                # Really correspond to a current source
                find_str_filepwl = string.find('type=pwl')
                lst_tmp = string.split(' ') # Convert the string into a list 
                lst_tmp[0] = l_nodecurrentNames[i] #replace the name of the source current by the intuitive name
                          
                string = ' '.join(lst_tmp) # convert one list to one string separated by one space
                
                l_netlist[x] = string # Is updated the new name of the current source (photo diode)
                
                
                ### From here is replaced the file PATH
                FILE_PATH = 'file='+'"'+ PATH_signal_input+name_signal_input+str(i)+ext_input+'"'
                if (find_str_filepwl == -1):
                    string  = l_netlist[x+1]  # get the file where is the 'file=pwl'
                    lst_tmp = string.split(' ') # convert the string in a list
                    index = lst_tmp.index('type=pwl') #obtain the index to replace the file=PATH
                    lst_tmp[index-1] = FILE_PATH
                    string = ' '.join(lst_tmp) # convert one list to one string separated by one space
                    l_netlist[x+1] = string
                else:
                    string  = l_netlist[x]    
                    lst_tmp = string.split(' ') # convert the string in a list
                    index = lst_tmp.index('type=pwl')
                    lst_tmp.insert(index,FILE_PATH)
                    string = ' '.join(lst_tmp) # convert one list to one string separated by one space
                    l_netlist[x]=string
                x = len_netlist
    i = i + 1

x = 0
# Here is written the new netlist
while x < len_netlist:
    f_netlist.write(l_netlist[x])
    f_netlist.write('\n')
    x = x + 1

f_netlist.close()
#end of code
