%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Aqui esta el modelo de una camara DVS
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% ========================= PARAMAMETERS MOSFET  ================= %%

close all;clc;clear;

tic;


PATH_input = getenv('PATH_folder_input'); %'/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
PATH_folder_images = getenv('PATH_folder_images'); % '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
name_signal = getenv('name_Signalsinput'); %'TrianguleWave7X8_250';
N = str2num(getenv('N')); %7;
M = str2num(getenv('M')); %8;
V_p = str2num(getenv('Vdon'));
V_n = str2num(getenv('Vdoff'));
T_Rst = 200e-6;

pwd_current=pwd;

%% Transistor's parameters
nn = 1.334;
np = 1.369;
Vtn = 359.2e-3;
Vtp = 387e-3;
Kn = 227.1e-6;
Kp = 48.1e-6;
fi = 25.8e-3;
Ratio = 0.5e-6/2e-6;
Isn = 2*nn*fi^2*Kn*Ratio;

% Known vaiables
Vref = 1.5;
Vos = 5.42e-3;      % Voffset comparador
Iph_max = 1e-9;
Iph_min = 20e-12;
A = 20;             % Gain closed loop differentiator


VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;
Iph_max = 1e-9;
Iph_min = 20e-12;


name_input = strcat(PATH_input,name_signal,'_0.csv');
input_signal = importdata(name_input);
t = input_signal(:,1);
len_t = length(t);
quant_pixel = N*M;
Vdiff=zeros(len_t,quant_pixel);
Vdiff_ind = zeros(len_t,1);
% structure ON 
ON_events = {[]}; ON_events2TC = zeros(1,2);
% structure OFF event
OFF_events = {[]}; OFF_events2TC = zeros(1,2);
xmax = 90e-3;
xmin = -90e-3;

ind_ON = 1;
ind_OFF = 1;

cd(PATH_input)

for i=0:quant_pixel-1;

    % paso 1. Encontrar Vdiff para cada uno de los pixeles
    name_input = strcat(name_signal,'_',num2str(i),'.csv');
    input_signal = importdata(name_input);
    Iph = input_signal(:,2);
    log_Iph = log(Iph/Isn);
    Vdiff(:,i+1) = -nn*fi*A*log_Iph;
    Vdiff_ind = Vdiff(:,i+1);
    Vdiff_max = max(Vdiff_ind);    %used to normalized
    Vdiff_ind = Vdiff_ind - Vdiff_max; %used to normalized
    
    % Cambia aleatoriamente el valor de Vref debido al offset inducido pela
    % chave
    
    x = xmin + rand(1,1)*(xmax - xmin);
        
    % Paso 2. Encontrar los eventos ON y OFF.
    ind_event = 1;
    for j=1:len_t
       value = Vdiff_ind(j);
       VdiffON = V_p - (Vref+x) + Vos;  
       VdiffOFF= V_n - (Vref+x) + Vos;
       if (value <= VdiffON)
           Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) + abs(value); %reset to Vref
           vec_time_pix = [t(j)+T_Rst i];
           ON_events2TC(ind_ON,1) = i;
           ON_events2TC(ind_ON,2) = Iph(j);
           ON_events{ind_ON} = vec_time_pix;
           Event_pix.value(ind_event) = t(j);
           ind_ON = ind_ON + 1;
           ind_event=ind_event+1;
           x = xmin + rand(1,1)*(xmax - xmin); % Voffset inducido pela chave
       else
           if ( value >= VdiffOFF)

                Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) - abs(value); %reset to Vref
                vec_time_pix = [t(j)+T_Rst i];
                OFF_events2TC(ind_OFF,1) = i;
                OFF_events2TC(ind_OFF,2) = Iph(j);
                OFF_events{ind_OFF} = vec_time_pix;
                Event_pix.value(ind_event) = t(j);
                ind_OFF = ind_OFF + 1;
                ind_event=ind_event+1;
                x = xmin + rand(1,1)*(xmax - xmin); % Voffset inducido pela chave
           else
               continue
           end
       end

    end
    Vdiff(:,i+1) = Vdiff_ind;
    Events{i+1} = Event_pix;
end


% Paso 3. Plot


cd(pwd_current)
close all;
plot_bar_events_DVS_Model(ON_events2TC,OFF_events2TC,Iph_min,Iph_max,'MODEL');
close all;
plot3dDVS_fn(ON_events,OFF_events,'MODEL')

cd(pwd_current)

toc
%exit
