% Este script plotea la salida de una camara DVS 
clear all; clc; close all;
pwd_current = pwd;

PATH_sim_output_matlab = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/DVS2x2_X_Arbiter_TS_20res/output_matlab/';
%PATH_sim_output_matlab = '/sdcard/documents/MSc/Cadence_analysis/Sim_DATA_PIXELS/output_matlab/';
cd(PATH_sim_output_matlab)

%mide el tiempo que dura el script en ejecutarse 
tic;


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

vec_desiredData = zeros(len_row_data_Sim,5); %falta la senal de global reset
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
%vec_desiredData(:,6) = digitalSignal(:,index_Globalrst); %global reset


%paso 4. Maquina de estados para determinar la validez de un dato

state = 0;
% structure ON 
ON_events = {[]};
% structure OFF event
OFF_events = {[]};

i=1;
ind_ON=1;
ind_OFF = 1;
while (i<=len_row_data_Sim)
		   
    if (state == 0)
    
        ind_En_RdPix = find(vec_desiredData([i:len_row_data_Sim],5) == 1,1);
        cur_index = i+ind_En_RdPix-1;
        if vec_desiredData(cur_index,4) == 1 % && vec_desiredData(ind_En_RdPix,6)
            % There is a valid data

            if vec_desiredData(cur_index,3) == 0
                % ON EVENT
                t = vec_desiredData(cur_index,1);
                pix = vec_desiredData(cur_index,2);
                vec_time_pix = [t pix];
                ON_events{ind_ON} = vec_time_pix;
                ind_ON = ind_ON + 1;
            else
                % OFF Event
                t = vec_desiredData(cur_index,1);
                pix = vec_desiredData(cur_index,2);
                vec_time_pix = [t pix];
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
    
	% ind_GlobalRst = find(vec_desiredData(:,5)==0,1);
	%i = ind_GlobalRst;
	% ind_GlobalRst = find(vec_desiredData(:,5)==1,1);
	
%	ind_read_pixel_H = find(vec_desiredData(:,4) == 1,1) 
%	i = i + 1
	%state 1
	
end 

ON_events=ON_events';
OFF_events=OFF_events';
cd(pwd_current)
toc
