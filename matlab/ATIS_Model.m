% Model ATIS

%% ========================= PARAMAMETERS MOSFET  ================= %%

close all;clc;clear;

curr_pwd = pwd;

tic;

PATH_input = getenv('PATH_folder_input'); 
PATH_folder_images = getenv('PATH_folder_images'); 
name_signal = getenv('name_Signalsinput'); 
N = str2num(getenv('N')); 
M = str2num(getenv('M')); 
V_p = str2num(getenv('Vdon'));
V_n = str2num(getenv('Vdoff'));
Vhigh = str2num(getenv('Vhigh'));
Vlow = str2num(getenv('Vlow'));



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
T_Rst = 200e-6;

VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;

%% ====================== Model DVS =========================== %%

name_input = strcat(PATH_input,name_signal,'_0.csv');
input_signal = importdata(name_input);
t = input_signal(:,1);
len_t = length(t);
quant_pixel = N*M;
Vdiff=zeros(len_t,quant_pixel);
Vdiff_ind = zeros(len_t,1); % Individual
% structure ON 
ON_events = {[]}; ON_events2TC = zeros(1,2);
% structure OFF event
OFF_events = {[]}; OFF_events2TC = zeros(1,2);
Events = {[]};
Event_pix = {[]};
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
    
    % Paso 2. Encontrar los eventos ON y OFF.
    ind_event = 1;
    Event_pix = {[]};
    for j=1:len_t
       value = Vdiff_ind(j);
       if (value <= VdiffON)
           Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) + abs(value); %reset to Vref
           vec_time_pix = [t(j)+T_Rst i];
           ON_events2TC(ind_ON,1) = i;
           ON_events2TC(ind_ON,2) = Iph(j);
           ON_events{ind_ON} = vec_time_pix;
           Event_pix.value(ind_event) = t(j)+T_Rst;
           ind_ON = ind_ON + 1;
           ind_event=ind_event+1;
       else
           if ( value >= VdiffOFF)

                Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) - abs(value); %reset to Vref
                vec_time_pix = [t(j)+T_Rst i];
                OFF_events2TC(ind_OFF,1) = i;
                OFF_events2TC(ind_OFF,2) = Iph(j);
                OFF_events{ind_OFF} = vec_time_pix;
                Event_pix.value(ind_event) = t(j)+T_Rst;
                ind_OFF = ind_OFF + 1;
                ind_event=ind_event+1;
           else
               continue
           end
       end

    end
    Vdiff(:,i+1) = Vdiff_ind;
    Events{i+1} = Event_pix;
end


% plot_bar_events_DVS_model

cd(curr_pwd)
plot_bar_events_DVS_Model(ON_events2TC,OFF_events2TC,Iph_min,Iph_max,'MODEL');

% Paso 3. Plot

plot3dDVS_fn(ON_events,OFF_events,'MODEL')

%% ========================================================= %%

%% =============== Exposure Measurement ==================== %%

Vint = zeros(len_t,quant_pixel);
C = 30e-15;
%Vhigh = 1.7;
%Vlow = 200e-3;
resol = 255;
Clim = [0 255];
Matrix_Color = {[]};
Matrix_time_pix_colour = zeros(1,3);
i = 0;
ack_Rst = 0;
ack_Vhigh = 0;
vec_Times_events_pixels = zeros(1,quant_pixel);
cd(curr_pwd)
[vec_color vec_COD_TIME] = CodingGrayScale(Vhigh,Vlow,resol,Clim);
cd(PATH_input)
Event_pix = {[]};
ind_TPC = 1;


for i=0:quant_pixel-1;
    name_input = strcat(name_signal,'_',num2str(i),'.csv');
    input_signal = importdata(name_input);
    t = input_signal(:,1) + T_Rst; %Como en spectre que tiene un atraso la senal
    Iph = input_signal(:,2);
    Vo = 0;
    Event_pix = Events{i+1};
        
    time_events = Event_pix.value;
    ind_events = 1;
    Vint(1,i+1) = Vo;
    Color_pix = {[]};
    ack_Rst = 0;
    ack_Vhigh = 0;
    for j=1:len_t-1
        
        if ~(isempty(find(time_events == t(j),1)))
           Vo = 1.8;
           Vint(j+1,i+1) = Vo;
           ack_Rst = 1;
        else
            
            Vint(j+1,i+1) = -1/C*Iph(j)*(t(j+1)-t(j)) + Vint(j,i+1);
            
            if Vint(j+1,i+1) < 0 
                
               Vint(j+1,i+1) = 0; 
            end
            
            V = Vint(j+1,i+1);
            
            
            
            if V <= Vhigh && ack_Rst
                t_high = t(j+1);
                ack_Vhigh = 1;
                ack_Rst = 0;
            elseif V <= Vlow && ack_Vhigh
                t_low = t(j+1);
                T_int = t_low - t_high;
                ind_table = find(vec_COD_TIME <= T_int , 1);
                Color = vec_color(ind_table);
                Color_pix.vec_color(ind_events) = Color;
                Color_pix.vec_time(ind_events,:) = t_low;%[t_high t_low];%T_int;%t(j);
                Matrix_time_pix_colour(ind_TPC,1) = t_low;
                Matrix_time_pix_colour(ind_TPC,2) = i; % From 0 to N-1.
                Matrix_time_pix_colour(ind_TPC,3) = Color;
                ind_events = ind_events + 1;
                ind_TPC = ind_TPC + 1;
                ack_Vhigh = 0;
                ack_Rst = 0;
            end
                        
        end
             
    end
    Matrix_Color{i+1} = Color_pix;
    % for debugging
    %display('vec_color')
    %uint8(Color_pix.vec_color)
    %display('Pixel')
    %i
    %fprintf('--------------------------------')
end

% For debbuging
%{
figure(3)
subplot(2,2,1)
plot(t,Vint(:,1))
line(t,Vlow)
line(t,Vhigh)
subplot(2,2,3)
plot(t,Vdiff(:,1))


subplot(2,2,2)
plot(t,Vint(:,29))
line(t,Vlow)
line(t,Vhigh)
subplot(2,2,4)
plot(t,Vdiff(:,29))
%}

%end


%% ====================== Painting the images ======================== %%

close all;

cd(curr_pwd)
plot2dATIS(Matrix_time_pix_colour,'MODEL')

toc
cd(curr_pwd)
exit