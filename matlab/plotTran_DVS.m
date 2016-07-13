% Este script plotea la salida de una camara DVS 
clear all; clc; close all;
pwd_current = pwd;

%PATH_sim_output_matlab ='/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/DVS2x2_TW_T30ms/output_matlab/';
%PATH_sim_output_matlab = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/DVS2x2_X_Arbiter_TS_20res/output_matlab/';
%PATH_sim_output_matlab = '/sdcard/documents/MSc/Cadence_analysis/Sim_DATA_PIXELS/output_matlab/';

%mide el tiempo que dura el script en ejecutarse 
tic;

PATH_sim_output_matlab = getenv('PATH_sim_output_matlab');
name_simulation = getenv('name_simulation');
PATH_folder_images = getenv('PATH_folder_images');
number_bits = str2num(getenv('number_bits'));
PATH_input = getenv('PATH_folder_input'); 
name_signal = getenv('name_Signalsinput'); 

N = str2num(getenv('N'));
M = str2num(getenv('M'));
T_Rst = 200e-6;
Iph_min = 20e-12;
Iph_max = 1e-9;

cd(PATH_sim_output_matlab)

string_data = strcat('data_',name_simulation,'.csv');
string_index_file = 'index_data.csv';
middle_point = 0.9;

% header
%Importing the data

data_Sim = importdata(string_data);
index_desired = importdata(string_index_file);
len_index = length(index_desired);
len_row_data_Sim = length(data_Sim);


vec_desiredData = zeros(len_row_data_Sim,6); % Always 6 [time data parity(ON/OFF)
digitalSignal = zeros(len_row_data_Sim,len_index);
vec_pixels = zeros(len_row_data_Sim,1); 
time = data_Sim(:,1);
vec_desiredData(:,1) = time;

%paso 1. leer los datos de la simulacion y pasar de analogico a digital

for i=1:len_index
    % Convert the analog signal in digital signal
    signalX = data_Sim(:,index_desired(i)+1); % Se suma 1 para contar el vector tiempo
    index_ONE = find(signalX >= middle_point);
    index_ZERO = find(signalX <middle_point);
    signalX([index_ONE]) = 1;
    signalX([index_ZERO]) = 0;
    if (i <= number_bits-1)
				signalX = (2^(i-1))*signalX;
                vec_pixels = vec_pixels + signalX;
    end
    digitalSignal(:,i)=signalX;
    
end


%paso 2. Armar el vec_desiredData con el dato en base decimal

index_Threshold = number_bits;
index_En_ReadRow = number_bits+1;
index_En_ReadPixel = number_bits+2;
index_Globalrst  = number_bits + 3;

vec_desiredData(:,2) = vec_pixels;
vec_desiredData(:,3) = digitalSignal(:,index_Threshold); % Kind event Threshold
vec_desiredData(:,4) = digitalSignal(:,index_En_ReadRow); %en read row
vec_desiredData(:,5) = digitalSignal(:,index_En_ReadPixel); %en read pixel
vec_desiredData(:,6) = digitalSignal(:,index_Globalrst); %global reset


%paso 3. Maquina de estados para determinar la validez de un dato

state = 0;
% structure ON 
ON_events = {[]}; ON_events2TC = zeros(1,2);
% structure OFF event
OFF_events = {[]}; OFF_events2TC = zeros(1,2);
i=1;
ind_ON=1;
ind_OFF = 1;
while (i<=len_row_data_Sim)
		   
    if (state == 0)
    
        ind_En_RdPix = find(vec_desiredData([i:len_row_data_Sim],5) == 1,1);
        cur_index = i+ind_En_RdPix-1;
        if vec_desiredData(cur_index,4) == 1 & vec_desiredData(cur_index,6) == 1
            % There is a valid data

            if vec_desiredData(cur_index,3) == 0
                % ON EVENT
                t = vec_desiredData(cur_index,1);
                pix = vec_desiredData(cur_index,2);
                vec_time_pix = [t pix];
                
                % For Bar plot
                name_input = strcat(PATH_input,name_signal,'_',num2str(pix),'.csv');
                input_signal = importdata(name_input);
                t_tmp = input_signal(:,1) + T_Rst;
                Iph = input_signal(:,2);
                j = find(t_tmp >= t,1);
                ON_events2TC(ind_ON,1) = pix;
                ON_events2TC(ind_ON,2) = Iph(j);
                %end bar plot
                ON_events{ind_ON} = vec_time_pix;
                ind_ON = ind_ON + 1;
            else
                % OFF Event
                t = vec_desiredData(cur_index,1);
                pix = vec_desiredData(cur_index,2);
                vec_time_pix = [t pix];
                
                % For Bar plot
                name_input = strcat(PATH_input,name_signal,'_',num2str(pix),'.csv');
                input_signal = importdata(name_input);
                t_tmp = input_signal(:,1) + T_Rst;
                Iph = input_signal(:,2);
                j = find(t_tmp >= t,1);
                OFF_events2TC(ind_OFF,1) = pix;
                OFF_events2TC(ind_OFF,2) = Iph(j);
                %end bar plot
                
                
                OFF_events{ind_OFF} = vec_time_pix;
                ind_OFF = ind_OFF + 1;
            end
            i = i+ind_En_RdPix;
            state = 1;
        else
            i = i+ind_En_RdPix;
            state = 0;
        end
    else
        ind_En_RdPix = find(vec_desiredData([i:len_row_data_Sim],5) == 0,1);
        i = i+ind_En_RdPix-1;
        state = 0;
        
    end
    
	
end 



% Paso 4. Plot


% plot_bar_events_DVS_model

cd(pwd_current)

plot_bar_events_DVS_Model(ON_events2TC,OFF_events2TC,Iph_min,Iph_max,'SIMULATED');

% Paso 3. Plot

plot3dDVS_fn(ON_events,OFF_events,'SIMULATED')



cd(pwd_current)

toc
exit

