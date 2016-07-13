% Este script plotea la salida de una camara DVS 
clear all; % clc; close all;
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

cd(PATH_sim_output_matlab)

%name_simulation = 'DVS2x2_resol20';
%name_simulation ='DVS2x2_TW_T30ms';
string_data = strcat('data_',name_simulation,'.csv');
string_index_file = 'index_data.csv';
%number_bits = 3;
middle_point = 0.9;

% header
%Importing the data

data_Sim = importdata(string_data);
index_desired = importdata(string_index_file);
len_index = length(index_desired);
len_row_data_Sim = length(data_Sim);

scaleTime = 1e3;

vec_desiredData = zeros(len_row_data_Sim,6); % Always 6 [time data parity(ON/OFF)
digitalSignal = zeros(len_row_data_Sim,len_index);
vec_pixels = zeros(len_row_data_Sim,1); 
time = scaleTime*data_Sim(:,1);
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
        if vec_desiredData(cur_index,4) == 1 & vec_desiredData(cur_index,6) == 1
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
    
	
end 



% Paso 4. Plot


cd(PATH_folder_images)

% ON EVENTS

i = 0;
%X = 0:X_length;
%Y = 0:Y_length;
X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);

%z  = zeros(Y_length+1,X_length+1);
len_ON_events = length(ON_events);


if ( len_ON_events > 1)
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
        z([y1 y2],[x1 x2]) = t;
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
    %vec_time_pix = ON_events{1};
    %min_t = vec_time_pix(1);
    %vec_time_pix = ON_events{len_ON_events};
    %max_t = vec_time_pix(1);
    %set(gca,'zlim',[min_t max_t])
    xlabel('X')
    ylabel('Y')
    zlabel('Time ms')
    name_title = 'ON EVENTS';
    name_fig = 'ON_events_3D';
    title(name_title)
    saveas(fig_ON,strcat(name_fig,'.fig'),'fig');
    saveas(fig_ON,strcat(name_fig,'.png'),'png');
end


len_OFF_events = length(OFF_events);
z  = zeros(2*M,2*N);

i = 0;

if ( len_OFF_events > 1)
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
        z([y1 y2],[x1 x2]) = t;
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
    %vec_time_pix = OFF_events{1};
    %min_t = vec_time_pix(1);
    %vec_time_pix = OFF_events{len_OFF_events};
    %max_t = vec_time_pix(1);
    %set(gca,'zlim',[min_t max_t])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'OFF EVENTS';
    name_fig = 'OFF_events_3D';
    title(name_title)
    saveas(fig_OFF,strcat(name_fig,'.fig'),'fig');
    saveas(fig_OFF,strcat(name_fig,'.png'),'png');
end

%dlmwrite('desiredSignals.csv',vec_desiredData,'delimiter',',','precision',10,'newline','unix');

cd(pwd_current)

toc
