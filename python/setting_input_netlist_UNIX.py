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

path_DIR = sys.argv[1]
path_DIR_input = sys.argv[2]
os.chdir(path_DIR)
nameNetlist = sys.argv[3]
namenetlistoutput = sys.argv[4]
nameinput = sys.argv[5] # name of the data without extension and number_
ext_input = sys.argv[6]
count_pixels = int(sys.argv[7])
name_n_Voltage = 'V_pd'
name_n_Current = 'I_pd'

'''
path_DIR = "/home/netware/users/jpgironruiz/Documents/Cadence_analysis/"
path_DIR_input = "/home/netware/users/jpgironruiz/Documents/Cadence_analysis/"
os.chdir(path_DIR)
name_n_Voltage = 'V_pd'
name_n_Current = 'I_pd'
nameNetlist = 'DVS_ONE_PIXEL2.scs'
namenetlistoutput = 'DVS_ONE_PIXEL.scs'
nameinput = 'input' # name of the data without extension and number
ext_input = '.csv'
'''



######
#count_pixels = 16            #quantity of pixels of the array
l_nodevoltageNames = []     # Save the name of the node voltage
l_nodecurrentNames = []     # Save the name of the nodes current name
f = open(nameNetlist,'r')
f_netlist = open(namenetlistoutput+'.scs','w')
l_netlist = list(f.readlines())
l_netlist = [w.replace('\n','') for w in l_netlist] # Here is storaged the netlist as a list 
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
f.close()
#### Create the lists with the names of the node voltage/current expected #####

x = 0
while x < count_pixels:
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
                FILE_PATH = 'file='+'"'+path_DIR_input+nameinput+str(i)+ext_input+'"'
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
