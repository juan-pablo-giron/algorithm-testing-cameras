% Model ATIS

%% ========================= PARAMAMETERS MOSFET  ================= %%

close all;clc;clear;

curr_pwd = pwd;

tic;

PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/spiral8X8_250/';
%PATH_input = getenv('PATH_folder_input'); %'/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
%PATH_folder_images = getenv('PATH_folder_images'); % '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
%name_signal = getenv('name_Signalsinput') %'TrianguleWave7X8_250';
name_signal = 'spiral8X8_250';
%N = str2num(getenv('N')); %7;
%M = str2num(getenv('M')); %8;
N = 8;
M = 8;

pwd_current=pwd;

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
V_p = 1.4;          % V_tetha+
V_n = 1.6;         % V_tetha-
Vos = 5.42e-3;      % Voffset comparador
Iph_max = 100e-12;
Iph_min = 1e-15;
A = 20;             % Gain closed loop differentiator

VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;

%% ====================== Model DVS =========================== %%

name_input = strcat(PATH_input,name_signal,'_0.csv');
input_signal = importdata(name_input);
t = input_signal(:,1);
len_t = length(t);
quant_pixel = N*M;
Vdiff=zeros(len_t,quant_pixel);
Vdiff_ind = zeros(len_t,1);
% structure ON 
ON_events = {[]};
% structure OFF event
OFF_events = {[]};
Events = {[]};
Event_pix = {[]};

ind_ON = 1;
ind_OFF = 1;
ind_events = 1;

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
    
    % Paso 2. Encontrar los eventos ON y OFF.
    ON_events = {[]};
    OFF_events = {[]};
    Event_pix = {[]};
    ind_events = 1;
    for j=1:len_t
       value = Vdiff_ind(j);
       if (value <= VdiffON)
           Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) + abs(value); %reset to Vref
           vec_time_pix = [t(j) i];
           ON_events{ind_ON} = vec_time_pix;
           Event_pix.value(ind_events) = t(j);
           ind_events = ind_events + 1;
           ind_ON = ind_ON + 1;
           
       else
           if ( value >= VdiffOFF)

                Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) - abs(value); %reset to Vref
                vec_time_pix = [t(j) i];
                OFF_events{ind_OFF} = vec_time_pix;
                Event_pix.value(ind_events) = t(j);
                ind_events = ind_events + 1;
                ind_OFF = ind_OFF + 1;
           else
               continue
           end
       end

    end
    Vdiff(:,i+1) = Vdiff_ind;
    Events{i+1} = Event_pix;
end

% figure(1)
% subplot(2,1,1)
% plot(t,Vdiff(:,1))
% xlim([0 0.00013])

%% ========================================================= %%

%% =============== Exposure Measurement ==================== %%

Vint = zeros(len_t,quant_pixel);
C = 30e-15;
Vhigh = 1.7;
Vlow = 200e-3;
Matrix_Color = {[]};
Color_pix = {[]};
i = 0;
ack_Rst = 0;
ack_Vhigh = 0;

for i=0:quant_pixel-1;
    cd(PATH_input)
    name_input = strcat(name_signal,'_',num2str(i),'.csv');
    input_signal = importdata(name_input);
    Iph = input_signal(:,2);
    Vo = 0;
    Event_pix = Events{i+1};
    time_events = Event_pix.value;
    ind_events = 1;
    Vint(1,i+1) = Vo;
    for j=2:len_t-1
        
        if ~(isempty(find(time_events == t(j),1)))
           Vo = 1.8;
           Vint(j,i+1) = Vo;
           ack_Rst = 1;
        else
            
            Vint(j,i+1) = -1/C*Iph(j)*(t(j)-t(j-1)) + Vo;
            
            if Vint(j,i+1) < 0 
                
               Vint(j,i+1) = 0; 
            end
            
            Vo = Vint(j,i+1);
            
            
            
            if Vint(j,i+1) <= Vhigh && ack_Rst
                ack_Rst = 0;
                t_high = t(j);
                ack_Vhigh = 1;
                
            elseif Vint(j,i+1) <= Vlow && ack_Vhigh
                t_low = t(j);
                T_int = t_low - t_high;
                cd(curr_pwd)
                Color = CodingGrayScale(Vhigh,Vlow,T_int);
                Color_pix.vec_color(ind_events) = Color;
                Color_pix.vec_time(ind_events) = t(j);
                ind_events = ind_events + 1;
                ack_Vhigh = 0;
            end
            
        end
        
        %hold on
        %grid on
           
    end
    Matrix_Color{i+1} = Color_pix;
  % subplot(2,1,2)
  % plot(t,Vint) 
  % xlim([0 0.00013])
end


cd(curr_pwd)