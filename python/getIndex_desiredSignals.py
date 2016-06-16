## Esta function recibe una lista con las senhales simuladas
## Ademas de la cantidad de bits y otra lista con las senhales deseadas
## y finalmente una lista con los nombres de los buses de datos
## El retorno de la funcion es escribir un archivo .csv indicando las
## posiciones de las senhales deseadas.

def getIndex_desiredSignals(lst_AllSignals,lst_DesiredSignals,lst_bus_data,number_bits,path_file_index):
    
    # build the list specifying the number of the bit

    lst_signals = []
    lst_index = []
    len_lst_DS = len(lst_DesiredSignals)
    len_lst_AS = len(lst_AllSignals)

    for i in range(0,len_lst_DS):

        name_signal = lst_DesiredSignals[i]
        try:
            isBusdata = lst_bus_data.index(name_signal)
            for j in range(0,number_bits):
                print j
                lst_signals.append(name_signal+'<'+str(j)+'>')
        except ValueError:
            lst_signals.append(name_signal)

    print lst_signals

    # Creates the lst with the index

    len_lst_signals = len(lst_signals)

    for i in range(0,len_lst_signals):
        index = lst_AllSignals.index(lst_signals[i])
        lst_index.append(index)

    # Writing the file

    File = open(path_file_index,'w')
    for item in lst_index:
      File.write("%d\n" % item)
    File.close()




    
