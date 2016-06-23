function []=create_InputSignal(time,delta_time,N,M,samples,Array,nameSignal,PATH_input)

curr_pwd = pwd;
cd(PATH_input)
pixel = 0;
for ind_y=1:M
    for ind_x=1:N
        % Here is sampled the signal the by 'samples' times.
        vec_time = time:delta_time/samples:delta_time-delta_time/samples + time;
        value_pixel = Array(ind_y,ind_x);
        vec_value = value_pixel*ones(1,length(vec_time));
        name_file = strcat(nameSignal,'_',int2str(pixel),'.csv');
        dlmwrite(name_file,[vec_time' vec_value'],'delimiter',',','-append','precision',10,'newline','unix');
        pixel = pixel + 1;
    end
   
end

cd(curr_pwd)
    
