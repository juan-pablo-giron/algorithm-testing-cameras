% ============================================================= 
% Este script calcula la sensibilidad de contraste de la camara
% DVS.
% ============================================================= 


clear all; clc; close all;
pwd_current = pwd;


%mide el tiempo que dura el script en ejecutarse 
tic;

PATH_sim_output_matlab = getenv('PATH_sim_output_matlab');
name_simulation = getenv('name_simulation');
number_bits = str2double(getenv('number_bits'));
PATH_input = getenv('PATH_folder_input'); 
name_signal = getenv('name_Signalsinput'); 

N = str2double(getenv('N'));
M = str2double(getenv('M'));
V_p = str2num(getenv('Vdon'));
V_n = str2num(getenv('Vdoff'));


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
i=1;

% Structures to calculate sensitivity contrast
Matrix_pix_edges_ON = zeros(N*M,1);
Matrix_pix_edges_OFF = zeros(N*M,1);

while (i<=len_row_data_Sim)
		   
    if (state == 0)
    
        ind_En_RdPix = find(vec_desiredData([i:len_row_data_Sim],5) == 1,1);
        cur_index = i+ind_En_RdPix-1;
        if vec_desiredData(cur_index,4) == 1 & vec_desiredData(cur_index,6) == 1
            % There is a valid data

            if vec_desiredData(cur_index,3) == 0
                % ON EVENT
                pix = vec_desiredData(cur_index,2);
                Matrix_pix_edges_ON(pix+1) = Matrix_pix_edges_ON(pix+1) + 1; 
                
            else
                % OFF Event
                pix = vec_desiredData(cur_index,2);
                Matrix_pix_edges_OFF(pix+1) = Matrix_pix_edges_OFF(pix+1) + 1; 
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
MaxEdges = 2;
Matrix_pix_edges_ON = Matrix_pix_edges_ON/MaxEdges;
Matrix_pix_edges_OFF = Matrix_pix_edges_OFF/MaxEdges;


%% ======================   Histograms    ============================= %%
cd(pwd_current)
Vref = 1.5;
VDIFF = abs(Vref - V_n);
string = 'SIMULATED';
plotHistograms(Matrix_pix_edges_ON,Matrix_pix_edges_OFF,string,VDIFF)

cd(pwd_current)
toc

clear all,close all;clc;

exit

