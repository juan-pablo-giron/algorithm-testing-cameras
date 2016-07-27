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
import random
import re
#============================  ALGORITHM ====================================#

##############   inputs   #########################

PATH_nameNetlist_spectre = os.environ['PATH_nameNetlist_spectre']
PATH_folder_simulation = os.environ['PATH_folder_simulation']
nameNetlist_spectre_Orig = os.environ['nameNetlist_spectre_Orig']
nameNetlist_spectre = os.environ['nameNetlist_spectre'] # netlist final
PATH_folder_input = os.environ['PATH_folder_input']
name_Signalsinput = os.environ['name_Signalsinput']
Vdoff = float(os.environ['Vdoff'])
Vdon = float(os.environ['Vdon'])


ext_input = '.csv'
name_noise_file = 'noise_'
N = int(os.environ['N'])
M = int(os.environ['M'])
quant_pixels = N*M

T_Rst=200e-6;

os.chdir(PATH_folder_simulation)

name_n_VoltageDVS = 'V_pdD'
name_n_CurrentDVS = 'I_pdD'


################ end inputs ######################


l_nodevoltageNames = []     # Save the name of the node voltage
l_nodecurrentNames = []     # Save the name of the nodes current name
f = open(nameNetlist_spectre_Orig,'r')
f_readme=open(PATH_folder_input+'README.txt','r')
f_netlist = open(nameNetlist_spectre,'w')
l_readme=list(f_readme.readlines())
l_readme=[w.replace('\n','') for w in l_readme]
l_netlist = list(f.readlines())
l_netlist = [w.replace('\n','') for w in l_netlist] # Here is stored the netlist as a list 
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
f.close()
f_readme.close()
#### Create the lists with the names of the node voltage/current expected #####

x = 0
while x <quant_pixels:
    nodeVoltageName = name_n_VoltageDVS+str(x)
    nodeCurrentName = name_n_CurrentDVS+str(x)
    l_nodevoltageNames.append(nodeVoltageName)
    l_nodecurrentNames.append(nodeCurrentName)
    x = x + 1

len_nodeVoltageName = len(l_nodevoltageNames)

#print l_nodevoltageNames
#print l_nodecurrentNames


#get the signal's period
len_readme = len(l_readme)
i=0

while i<len_readme:
    str_readme=l_readme[i]
    find_T = str_readme.find('T')
    if (find_T != -1 ):
        lst_tmp=str_readme.split(' ')
        #print 'lst_tmp'+str(lst_tmp)
        index_T=lst_tmp.index('T')
        T=lst_tmp[index_T+1]
        i=len_readme
    else:
        i=i+1


#index_T = l_readme.index('T')
#T = l_readme[T+2]

print float(T)


################################################################################

#### Search for the node voltage connected to the specific current source
#### and both change the name of the current source as the file data


################## Replacing the I source by intuitive names ########### 
i = 0
f_netlist.seek(0,0)

x = 0
while x < len_netlist:
    string = l_netlist[x]
    find_nameVoltage = string.find('isource')
    find_parameter = string.find('parameters')
    find_tran = string.find('tran tran')
    if (find_parameter != -1):
        lst_tmp=string.split(' ')
        len_lst_tmp=len(lst_tmp)
        j=0
        while (j<len_lst_tmp):
            find_T=lst_tmp[j].find('T')
            if (find_T != -1):
                #lst_tmp[j]='Vdon T=%1.10f'%float(T)
                #string=' '.join(lst_tmp)
                #l_netlist[x]=string
                new_line = 'parameters Vdon=%2.3e'%Vdon+' Vdoff=%2.3e'%Vdoff+' T=%2.3e'%float(T)+' T_Rst=%3.3e'%T_Rst
                l_netlist[x]=new_line
                j=len_lst_tmp
            else:
                j=j+1
                
    if (find_tran != -1):
        lst_tmp=string.split(' ')
        len_lst_tmp=len(lst_tmp)
        j=0
        print 'lst_tmp tran'+str(lst_tmp)
        while (j<len_lst_tmp):
            find_T=lst_tmp[j].find('stop')
            if (find_T != -1):
                lst_tmp[j]='stop=%3.3e'%(T_Rst+float(T))
                string=' '.join(lst_tmp)
                l_netlist[x]=string
                j=len_lst_tmp
            else:
                j=j+1
    
    if (find_nameVoltage != -1):
         
         find_nameVoltage = string.find(name_n_VoltageDVS)
         if (find_nameVoltage != -1):
             i=i+1
             #print 'x = %d'%x+'  lst[X]'+string
             lst_tmp=string.split(' ')
             lst_tmp=[w.replace('(','') for w in lst_tmp]
             #print lst_tmp
             voltage_name=lst_tmp[1] # here the name node voltage
             index=l_nodevoltageNames.index(voltage_name)
             #print index
             j=x+1
             while j<len_netlist:
                 string=l_netlist[j]
                 lst_tmp=string.split(' ')
                 #print lst_tmp
                 if lst_tmp[0] != '':
                     nxt_ins=j
                     j=len_netlist
                 else:
                     j=j+1
                     
             #writing the desired information
             #print 'nxt_inst %d' %nxt_ins
             del l_netlist[x:nxt_ins]
             line1 = l_nodecurrentNames[index]+' ('+l_nodevoltageNames[index]+' 0) isource \\'
             line2 = '      file='+'"'+ PATH_folder_input+name_Signalsinput+'_'+str(index)+ext_input+'"'+' \\'  
             line3 = '      type=pwl delay=T_Rst edgetype=halfsine scale=1 stretch=1 pwlperiod=T'+' \\'
             line4 = '      noisefile='+'"'+ PATH_folder_input+name_noise_file+str(index)+ext_input+'"'
             l_netlist.insert(x,line1)
             l_netlist.insert(x+1,line2)
             l_netlist.insert(x+2,line3)
             l_netlist.insert(x+3,line4)
             len_netlist=len(l_netlist)
             #print '--------------------------------------------------------'    
    x=x+1
print 'total pixels %d'%i

'''

################### Calculate the news one values to Width and Length of the all transistor ############

name_pfet = 'pfet'
name_nfet = 'nfet'
quant_nmos = 0
quant_pmos = 0
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
line = 0

# parameter transistors
# NFET
sigma_delta_L_N = 0.017e-6
mu_L_N = 0.035e-6
sigma_delta_W_N = 0.1e-6
mu_W_N = 0.02e-6

# PFET
sigma_delta_L_P = 0.017e-6
mu_L_P = 0.035e-6
sigma_delta_W_P = 0.08e-6
mu_W_P = 0.04e-6

regex_l = re.compile("l=.*")
regex_w = re.compile("w=.*")

while line < len_netlist:

    # Search for the name_pfet or name_nfet
    string = l_netlist[line]
    find_name_pfet = string.find(name_pfet)
    find_name_nfet = string.find(name_nfet)
    
    # PFET
    if (find_name_pfet != -1):
        # Paso 1. Convertir el string a una lista
        lst_tmp=string.split(' ')
        # Paso 2. Encontrar el string donde esta l y w
        sub_list_L=[m.group(0) for l in lst_tmp for m in [regex_l.search(l)] if m]
        sub_list_W=[m.group(0) for l in lst_tmp for m in [regex_w.search(l)] if m]
        # Convertir las sublistas a string
        str_L = ''.join(sub_list_L)
        str_W = ''.join(sub_list_W)
        # Conocer las posiciones donde hay que reemplazar el string
        index_L = lst_tmp.index(str_L)
        index_W = lst_tmp.index(str_W)
        # capturar el valor de L y W con su respectiva escala (n,u,m)
        L =  float(str_L[2:-1])
        scale_str_L = str_L[-1:]

        if scale_str_L == 'n':
            scale_L = 1e-9
        elif scale_str_L == 'u':
            scale_L = 1e-6
        elif scale_str_L == 'm':
            scale_L = 1e-3
            
        W =  float(str_W[2:-1])
        scale_str_W = str_W[-1:]

        if scale_str_W == 'n':
            scale_W = 1e-9
        elif scale_str_W == 'u':
            scale_W = 1e-6
        elif scale_str_W == 'm':
            scale_W = 1e-3
        # Paso 3. Calcular el nuevo valor de L y W
        if L > 180:
            L = (L*scale_L) - random.gauss(mu_L_P,sigma_delta_L_P)
        else:
            L = L*scale_L
        W = (W*scale_W) - random.gauss(mu_W_P,sigma_delta_W_P)

        # Paso 4. Reemplazar los nuevos valores en la lista
        lst_tmp[index_L] = 'l='+str("%3.2e"%L)
        lst_tmp[index_W] = 'w='+str("%3.2e"%W)
        l_netlist[line] = ' '.join(lst_tmp)
        quant_pmos = quant_pmos + 1
        
    # NFET
    elif (find_name_nfet != -1):
        # Paso 1. Convertir el string a una lista
        lst_tmp=string.split(' ')
        # Paso 2. Encontrar el string donde esta l y w
        sub_list_L=[m.group(0) for l in lst_tmp for m in [regex_l.search(l)] if m]
        sub_list_W=[m.group(0) for l in lst_tmp for m in [regex_w.search(l)] if m]
        # Convertir las sublistas a string
        str_L = ''.join(sub_list_L)
        str_W = ''.join(sub_list_W)
        # Conocer las posiciones donde hay que reemplazar el string
        index_L = lst_tmp.index(str_L)
        index_W = lst_tmp.index(str_W)
        # capturar el valor de L y W con su respectiva escala (n,u,m)
        L =  float(str_L[2:-1])
        scale_str_L = str_L[-1:]

        if scale_str_L == 'n':
            scale_L = 1e-9
        elif scale_str_L == 'u':
            scale_L = 1e-6
        elif scale_str_L == 'm':
            scale_L = 1e-3
            
        W =  float(str_W[2:-1])
        scale_str_W = str_W[-1:]

        if scale_str_W == 'n':
            scale_W = 1e-9
        elif scale_str_W == 'u':
            scale_W = 1e-6
        elif scale_str_W == 'm':
            scale_W = 1e-3
        # Paso 3. Calcular el nuevo valor de L y W
        if L > 180:
            L = (L*scale_L) - random.gauss(mu_L_N,sigma_delta_L_N)
        else:
            L = L*scale_L
        W = (W*scale_W) - random.gauss(mu_W_N,sigma_delta_W_N)

        # Paso 4. Reemplazar los nuevos valores en la lista
        lst_tmp[index_L] = 'l='+str("%3.2e"%L)
        lst_tmp[index_W] = 'w='+str("%3.2e"%W)
        l_netlist[line] = ' '.join(lst_tmp)
        quant_nmos = quant_nmos + 1
    line = line + 1

print "#NMOS = %d"%quant_nmos
print "#PMOS = %d"%quant_pmos

'''


#################### Here is written the new netlist #############################
x = 0
len_netlist = len(l_netlist) # calculate the length of the list 'l_netlist'
while x < len_netlist:
    f_netlist.write(l_netlist[x])
    f_netlist.write('\n')
    x = x + 1

f_netlist.close()
#end of code

