% Este script plotea la salida de una camara DVS 


PATH_sim_output_matlab = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/DVS2x2_X_Arbiter_TS_20res/output_matlab/';
cd(PATH_sim_output_matlab)
name_simulation = 'DVS2x2_resol20';
string_data = strcat('data_',name_simulation,'.csv');
string_index_file = 'index_data.csv';
number_bits = 3;
middle_point = 0.9;
% header

%Importing the data

data_Sim = importdata(string_data);
index_desired = importdata(string_index_file);
len_index = length(index_desired);
len_row_data_Sim = length(data_Sim);

vec_desiredData = zeros(len_row_data_Sim,len_index);
time = data_Sim(:,1);
vec_desiredData(:,1) = time;

for i=1:len_index
    % Convert the analog signal in digital signal
    tmp_signal = data_Sim(:,index_desired(i));
    
    vec_desiredData(:,i+1)=data_Sim(:,index_desired(i));
end




