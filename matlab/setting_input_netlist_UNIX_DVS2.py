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

PATH_nameNetlist_spectre = os.environ['PATH_nameNetlist_spectre']
PATH_folder_simulation = os.environ['PATH_folder_simulation']
nameNetlist_spectre_Orig = os.environ['nameNetlist_spectre_Orig']
nameNetlist_spectre = os.environ['nameNetlist_spectre'] # netlist final
PATH_folder_input = os.environ['PATH_folder_input']
name_Signalsinput = os.environ['name_Signalsinput']
ext_input = '.csv'

N = int(os.environ['N'])
M = int(os.environ['M'])
quant_pixels = N*M

os.chdir(PATH_folder_simulation)
name_n_VoltageDVS = 'V_pdD'
name_n_VoltageATIS = 'V_pdA'
name_n_CurrentDVS = 'I_pdD'
name_n_CurrentATIS = 'I_pdA'
name_instance = 'I'
#name_subckts = 'subckts'
#name_tran = 'tran'

################ end inputs ######################


l_nodevoltageNames = []     # Save the name of the node voltage
l_nodecurrentNames = []     # Save the name of the nodes current name
f = open(nameNetlist_spectre_Orig,'r')
f_netlist = open(nameNetlist_spectre,'w')
l_netlist = list(f.readlines())
l_netlist = [w.replace('\n','') for w in l_netlist] # Here is stored the netlist as a list 
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
f.close()
#### Create the lists with the names of the node voltage/current expected #####

x = 0
while x <quant_pixels:
    nodeVoltageName = name_n_VoltageDVS+str(x)
    nodeCurrentName = name_n_CurrentDVS+str(x)
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
#while i<len_nodeVoltageName:
#    nameVoltageName = l_nodevoltageNames[i]
#    x = 0
while x < len_netlist:
	string = l_netlist[x]
   find_nameVoltage = string.find('isource')
	print x
	'''
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
                print "x =%d",x
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
                print "x next instance =%d",x_nextInstance    
                del l_netlist[x:x_nextInstance]
                FILE_PATH = 'file='+'"'+ PATH_folder_input+name_Signalsinput+'_'+str(i)+ext_input+'"'
               
                new_row = l_nodecurrentNames[i]+' '+'('+l_nodevoltageNames[i]+' '+'0)'+' '+'isource'+' '+ \
                          FILE_PATH+' '+'type=pwl'+' '+'delay=T_Rst'+' '+'edgetype=halfsine'+' '+ \
                          'scale=1'+' '+'stretch=1'+' '+'pwlperiod=T'

                l_netlist.insert(x,new_row)
                               
                len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
                x = len_netlist
    '''
    x = x + 1


#################### Here is written the new netlist #############################
x = 0
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
while x < len_netlist:
    f_netlist.write(l_netlist[x])
    f_netlist.write('\n')
    x = x + 1

f_netlist.close()
#end of code

