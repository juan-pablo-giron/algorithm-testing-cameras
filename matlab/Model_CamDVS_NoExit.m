%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Aqui esta el modelo de una camara DVS
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% ========================= PARAMAMETERS MOSFET  ================= %%

close all; %clc;clear;

tic;


PATH_input = getenv('PATH_folder_input'); %'/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
PATH_folder_images = getenv('PATH_folder_images'); % '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
name_signal = getenv('name_Signalsinput'); %'TrianguleWave7X8_250';
N = str2num(getenv('N')); %7;
M = str2num(getenv('M')); %8;
V_p = str2num(getenv('Vdon'));
V_n = str2num(getenv('Vdoff'));

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
Vref = 1.495;
%V_p = 1.4;          % V_tetha+
%V_n = 1.6;         % V_tetha-
Vos = 5.42e-3;      % Voffset comparador
A = 20;             % Gain closed loop differentiator

VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;



name_input = strcat(PATH_input,name_signal,'_0.csv')
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
    
    for j=1:len_t
       value = Vdiff_ind(j);
       if (value <= VdiffON)
           Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) + abs(value); %reset to Vref
           vec_time_pix = [t(j) i];
           ON_events{ind_ON} = vec_time_pix;
           ind_ON = ind_ON + 1;
       else
           if ( value >= VdiffOFF)

                Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) - abs(value); %reset to Vref
                vec_time_pix = [t(j) i];
                OFF_events{ind_OFF} = vec_time_pix;
                ind_OFF = ind_OFF + 1;
           else
               continue
           end
       end

    end
    Vdiff(:,i+1) = Vdiff_ind;
    
end

% Paso 3. Plot


cd(PATH_folder_images)

% ON EVENTS

i = 0;
%X = 0:X_length;
%Y = 0:Y_length;
X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);
scaleTime=1e3;

%z  = zeros(Y_length+1,X_length+1);
len_ON_events = length(ON_events);


if ( len_ON_events >1)
    fig_ON = figure(1);
    colormap(fig_ON,'gray')
    while i < len_ON_events

        vec_time_pix = ON_events{i+1};
        t = vec_time_pix(1);
        pixel = vec_time_pix(2);
        row = fix(pixel/N);
        col = rem(pixel,N);
        y1  = row+1;
        y2  = y1+1;
        x1  = col+1;
        x2  = x1+1;
        z(:,:) = NaN; % Avoid that Matlab create lines no desired
        z([y1 y2],[x1 x2]) = scaleTime*t;
        surf(X,Y,z)
        hold on
        grid on
        i = i+1;

    end

    % adjusting apperance
    colorbar;
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    set(gca,'Ydir','reverse')
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'ON EVENTS MODEL';
    name_fig = 'ON_events_3D_Model';
    title(name_title)
    saveas(fig_ON,strcat(name_fig,'.fig'),'fig');
    saveas(fig_ON,strcat(name_fig,'.png'),'png');
end


len_OFF_events = length(OFF_events);
z  = zeros(2*M,2*N);

i = 0;

if ( len_OFF_events >1)
    fig_OFF = figure(2);
    colormap(fig_OFF,'gray')
    while i < len_OFF_events

        vec_time_pix = OFF_events{i+1};
        t = vec_time_pix(1);
        pixel = vec_time_pix(2);
        row = fix(pixel/N);
        col = rem(pixel,N);
        y1  = row+1;
        y2  = y1+1;
        x1  = col+1;
        x2  = x1+1;
        z(:,:) = NaN; % Avoid that Matlab create lines no desired
        z([y1 y2],[x1 x2]) = scaleTime*t;
        surf(X,Y,z)
        hold on
        grid on
        i = i+1;

    end

    % adjusting apperance
    colorbar;
    set(gca,'Ydir','reverse')
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'OFF EVENTS MODEL';
    name_fig = 'OFF_events_3D_Model';
    title(name_title)
    saveas(fig_OFF,name_fig,'fig');
    saveas(fig_OFF,name_fig,'png');
end

cd(pwd_current)

toc

