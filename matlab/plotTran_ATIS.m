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
N = str2num(getenv('N'));
M = str2num(getenv('M'));
Vhigh = str2num(getenv('Vhigh'));
Vlow = str2num(getenv('Vlow'));
PATH_input = getenv('PATH_folder_input'); 
name_signal = getenv('name_Signalsinput');
T_Rst = 200e-6;%1e-3;
Iph_min = 20e-12;
Iph_max = 1e-9;

cd(PATH_sim_output_matlab)

%% DVS

string_data = strcat('data_',name_simulation,'.csv'); 
string_index_file = 'index_data.csv';
middle_point = 0.9;

%% ATIS
 
string_index_file_A = 'index_data_A.csv';

%% Algorithm

%Importing the data

data_Sim = importdata(string_data);
scaleTime = 1e3;



%% ============================================================== %
%  =========================== DVS ============================== %
%  ============================================================== %

% Datas Variables
% DVS 'time' 'data','En_Read_Row','En_Read_pixel','Global_rst'

index_desired = importdata(string_index_file); %DVS
len_index = length(index_desired); %DVS
len_row_data_Sim = length(data_Sim);
vec_desiredData = zeros(len_row_data_Sim,6); % Always 6 [time data parity(ON/OFF)
digitalSignal = zeros(len_row_data_Sim,len_index);
vec_pixels = zeros(len_row_data_Sim,1); 
time = data_Sim(:,1);
vec_desiredData(:,1) = time;


% paso 1. leer los datos de la simulacion y pasar de analogico a digital

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


% paso 2. Armar el vec_desiredData con el dato en base decimal

index_Threshold = number_bits;
index_En_ReadRow = number_bits+1;
index_En_ReadPixel = number_bits+2;
index_Globalrst  = number_bits + 3;


kindEvent = digitalSignal(:,index_Threshold); % Kind event Threshold ON / OFF
EnReadRow = digitalSignal(:,index_En_ReadRow); %en read row
EnReadPix = digitalSignal(:,index_En_ReadPixel); %en read pixel
GlobalRst = digitalSignal(:,index_Globalrst); %global reset


%paso 3. Maquina de estados para determinar la validez de un dato
% IDEA:
% Esperar hasta que la senhal EnReadPix se encuentre en 1, en ese momento
% se sabe que contamos con un dato valido, ahi en ese momento, ncesitamos
% verificar si el evento fue por el canal ON o por el canal OFF el cual
% viene definido por el valor de la senhal KindEvent. Si KindEvent es igual
% a 0 es un Evento ON  de lo contrario es un evento OFF. Una vez
% determinado el evento se va al estado 1 donde se actualiza el
% ind_En_RdPix para encontrar un falling edge, comenzando el proceso
% nuevamente.


state = 0;
% structure ON 
ON_events = {[]}; ON_events2TC = zeros(1,2);
% structure OFF event
OFF_events = {[]}; OFF_events2TC = zeros(1,2);
ind_ON=1;
ind_OFF = 1;

% Colocar el indice i despues del T_Rst.

i = find(time > T_Rst,1);

while (i<=len_row_data_Sim)
    
    if (state == 0)
        % Encontrar un rising edge en EnReadPix.
        
        ind_En_RdPix = find(EnReadPix(i:len_row_data_Sim) == 1,1) + i - 1; %en read pixel (i-1 es el offset)
        
        if isempty(ind_En_RdPix)
            % Exit loop
            i = len_row_data_Sim + 1;
        else
            
            
            % Verificar si el evento fue ON u OF
            
            if kindEvent(ind_En_RdPix) == 0
                % ON EVENT
                t = time(ind_En_RdPix);
                pixel = vec_pixels(ind_En_RdPix);
                vec_time_pix = [t pixel];
                
                % For Bar plot
                name_input = strcat(PATH_input,name_signal,'_',num2str(pixel),'.csv');
                input_signal = importdata(name_input);
                t_tmp = input_signal(:,1) + T_Rst;
                Iph = input_signal(:,2);
                j = find(t_tmp >= t,1);
                ON_events2TC(ind_ON,1) = pixel;
                ON_events2TC(ind_ON,2) = Iph(j);
                %end bar plot
                ON_events{ind_ON} = vec_time_pix;
                ind_ON = ind_ON + 1;
                state = 1;
            else
                % OFF Event
                t = time(ind_En_RdPix);
                pixel = vec_pixels(ind_En_RdPix);
                vec_time_pix = [t pixel];
                
                % For Bar plot
                name_input = strcat(PATH_input,name_signal,'_',num2str(pixel),'.csv');
                input_signal = importdata(name_input);
                t_tmp = input_signal(:,1) + T_Rst;
                Iph = input_signal(:,2);
                j = find(t_tmp >= t,1);
                OFF_events2TC(ind_OFF,1) = pixel;
                OFF_events2TC(ind_OFF,2) = Iph(j);
                %end bar plot
                
                OFF_events{ind_OFF} = vec_time_pix;
                ind_OFF = ind_OFF + 1;
                state=1;
            end
        end
        
    else
        
        ind_En_RdPix = find(EnReadPix(ind_En_RdPix:len_row_data_Sim) == 0,1) + ind_En_RdPix - 1;
        i = ind_En_RdPix;
        state = 0;
        
    end
    
    
end



% Paso 4. Plot


% plot_bar_events_DVS_model

cd(pwd_current)

plot_bar_events_DVS_Model(ON_events2TC,OFF_events2TC,Iph_min,Iph_max,'SIMULATED');

% Paso 3. Plot

plot3dDVS_fn(ON_events,OFF_events,'SIMULATED')


%% ============================================================== %
%  =======================     ATIS   =========================== %
%  ============================================================== %



cd(PATH_sim_output_matlab)

% ATIS 'time' 'data_A','En_Read_Row_A','En_Read_pixel_A','Global_rst','Req_fr'

index_desired_A = importdata(string_index_file_A); 
len_index_A = length(index_desired_A);
vec_desiredData_A = zeros(len_row_data_Sim,7); % time data Event(H/L) En_RR En_RP GR R_fr
digitalSignal_A = zeros(len_row_data_Sim,len_index_A);
vec_pixels = zeros(len_row_data_Sim,1); 
time = data_Sim(:,1);
resol = 256;
Clim = [0 255];

cd(pwd_current)

[vec_color, vec_COD_TIME] = CodingGrayScale(Vhigh,Vlow,resol,Clim);

% paso 1. leer los datos de la simulacion y pasar de analogico a digital

for i=1:len_index_A
    % Convert the analog signal in digital signal
    signalX = data_Sim(:,index_desired_A(i)+1); % Se suma 1 para contar el vector tiempo
    index_ONE = find(signalX >= middle_point);
    index_ZERO = find(signalX <middle_point);
    signalX([index_ONE]) = 1;
    signalX([index_ZERO]) = 0;
    if (i <= number_bits-1)
				signalX = (2^(i-1))*signalX;
                vec_pixels = vec_pixels + signalX;
    end
    digitalSignal_A(:,i)=signalX;
    
end


% paso 2. Armar el vec_desiredData con el dato en base decimal

index_Threshold = number_bits;
index_En_ReadRow = number_bits+1;
index_En_ReadPixel = number_bits+2;
index_Globalrst  = number_bits + 3;
index_Req_fr  = number_bits + 4;

time;
vec_pixels;
kindEvent = digitalSignal_A(:,index_Threshold); % Kind event Vhigh or Vlow
EnReadRow = digitalSignal_A(:,index_En_ReadRow); %en read row
EnReadPix = digitalSignal_A(:,index_En_ReadPixel); %en read pixel
GlobalRst = digitalSignal_A(:,index_Globalrst); %global reset
Req_fr = digitalSignal_A(:,index_Req_fr); % Req_fr

% paso 3. Maquina de estados para determinar la validez de un dato

% IDEA:
% When EnReadPix == 1 entonces lea el dato y verifique si
% kindEvent, si es 0 entonces paso por el umbral High si es bajo
% entonces paso por el umbral Low. Cuando Se haya completado la lectura
% entonces verificar cuando EnReadPix == 0, en ese momento se vuelve al
% mismo estado.

state = 0;
i=1;
Matrix_time_pix_colour = zeros(1,3); % Almacena la informacion de 
Matrix_time_high_low = zeros(N*M,2);
cross_High = zeros(N*M,2); % Flag para indicar si paso por el umbral Vhigh
cross_High(:,1) = [0:N*M-1]';
Matrix_time_high_low(:,1) = [0:N*M-1]';
ind_TPC=1;

% Colocar el indice i en la posicion despues del T_Rst

i = find(time > T_Rst,1);


while (i<=len_row_data_Sim)
    
    if (state == 0)
        % Verificar si EnReadPix == 1 para leer el dato.
        
        ind_En_RdPix = find(EnReadPix(i:len_row_data_Sim) == 1,1) + i - 1; %en read pixel (i-1 es el offset)
        
        if isempty(ind_En_RdPix)
            i = len_row_data_Sim + 1;
        else
            
            pixel = vec_pixels(ind_En_RdPix);
            
            % Verificar si paso por Vhigh o Vlow
            if kindEvent(ind_En_RdPix) == 0
                % Cross by Vhigh
                t_high = time(ind_En_RdPix);
                Matrix_time_high_low(pixel+1,1) = t_high;
                state = 1;
                cross_High(pixel+1) = 1;
            else
                
                if cross_High(pixel+1) == 1
                    t_low = time(ind_En_RdPix);
                    Matrix_time_high_low(pixel+1,2) = t_low;
                    t_high = Matrix_time_high_low(pixel+1,1);
                    T_int = t_low - t_high;
                    ind_table = find(vec_COD_TIME <= T_int , 1);
                    Color = vec_color(ind_table);
                    Matrix_time_pix_colour(ind_TPC,1) = t_low;
                    Matrix_time_pix_colour(ind_TPC,2) = pixel; % From 0 to N-1.
                    Matrix_time_pix_colour(ind_TPC,3) = Color;
                    ind_TPC = ind_TPC + 1;
                    state = 1;
                    i = ind_En_RdPix; % Update the index
                    cross_High(pixel+1) = 0;
                end
            end
        end
        
    else
        % Find the next rising edge from En_Read_Pixel
        ind_En_RdPix = find(EnReadPix(ind_En_RdPix:len_row_data_Sim) == 0,1) + ind_En_RdPix - 1;
        i = ind_En_RdPix;
        state = 0;
        
    end
    
    
    
end
    
cd(pwd_current)
plot2dATIS(Matrix_time_pix_colour,'SIMULATED')
    
cd(pwd_current)
toc
%exit


