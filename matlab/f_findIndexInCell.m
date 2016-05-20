function index = f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals)


for i=1:len_vector_signals
    if strcmp(desired_signal2plot,vec_signals{i})
        index = i;
        return
    end
end