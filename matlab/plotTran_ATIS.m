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
time = scaleTime*data_Sim(:,1);
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

vec_desiredData(:,2) = vec_pixels;
vec_desiredData(:,3) = digitalSignal(:,index_Threshold); % Kind event Threshold
vec_desiredData(:,4) = digitalSignal(:,index_En_ReadRow); %en read row
vec_desiredData(:,5) = digitalSignal(:,index_En_ReadPixel); %en read pixel
vec_desiredData(:,6) = digitalSignal(:,index_Globalrst); %global reset


% paso 3. Maquina de estados para determinar la validez de un dato

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
X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);
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
    %colorbar;
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    set(gca,'Ydir','reverse')
    xlim([0 N])
    ylim([0 M])
    xlabel('X')
    ylabel('Y')
    zlabel('Time ms')
    name_title = 'ON EVENTS';
    name_fig = 'ON_events_3D';
    title(name_title)
    saveas(fig_ON,strcat(name_fig,'.fig'),'fig');
    saveas(fig_ON,strcat(name_fig,'.png'),'png');
end



z  = zeros(2*M,2*N);

len_OFF_events = length(OFF_events);
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
        z([y1 y2],[x1 x2]) = t;
        surf(X,Y,z)
        hold on
        grid on
        i = i+1;

    end

    % adjusting apperance
    %colorbar;
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    set(gca,'Ydir','reverse')
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'OFF EVENTS';
    name_fig = 'OFF_events_3D';
    title(name_title)
    saveas(fig_OFF,strcat(name_fig,'.fig'),'fig');
    saveas(fig_OFF,strcat(name_fig,'.png'),'png');
end


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
resol = 255;
Clim = [0 255];

cd(pwd_current)

[vec_color vec_COD_TIME] = CodingGrayScale(Vhigh,Vlow,resol,Clim);

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

vec_desiredData_A(:,1) = time;
vec_desiredData_A(:,2) = vec_pixels;
vec_desiredData_A(:,3) = digitalSignal_A(:,index_Threshold); % Kind event Vhigh or Vlow
vec_desiredData_A(:,4) = digitalSignal_A(:,index_En_ReadRow); %en read row
vec_desiredData_A(:,5) = digitalSignal_A(:,index_En_ReadPixel); %en read pixel
vec_desiredData_A(:,6) = digitalSignal_A(:,index_Globalrst); %global reset
vec_desiredData_A(:,7) = digitalSignal_A(:,index_Req_fr); % Req_fr

% paso 3. Maquina de estados para determinar la validez de un dato

state = 0;
i=1;
Matrix_time_pix_colour = zeros(1,3);
Matrix_time_high_low = zeros(N*M,2);
Matrix_time_high_low(:,1) = [0:N*M-1]';
ind_TPC=1;

while (i<=len_row_data_Sim)
		   
    if (state == 0)
    
        ind_En_RdPix = find(vec_desiredData_A([i:len_row_data_Sim],5) == 1,1);
        cur_index = i+ind_En_RdPix-1;
        if vec_desiredData_A(cur_index,4) == 1 & vec_desiredData_A(cur_index,6) == 1
            % There is a valid data

            if vec_desiredData_A(cur_index,3) == 0
                % Vhigh received
                pixel = vec_desiredData_A(cur_index,2);
                t = vec_desiredData_A(cur_index,1);
                Matrix_time_high_low(pixel+1,1) = t;
            else
                % Vlow received
                pixel = vec_desiredData_A(cur_index,2);
                t = vec_desiredData_A(cur_index,1);
                Matrix_time_high_low(pixel+1,2) = t;
                t_high = Matrix_time_high_low(pixel+1,1);
                t_low = Matrix_time_high_low(pixel+1,2);
                T_int = t_low - t_high;
                ind_table = find(vec_COD_TIME <= T_int , 1);
                Color = vec_color(ind_table);
                Matrix_time_pix_colour(ind_TPC,1) = t_low;
                Matrix_time_pix_colour(ind_TPC,2) = pixel; % From 0 to N-1.
                Matrix_time_pix_colour(ind_TPC,3) = Color;
                ind_TPC = ind_TPC + 1;
            end
            i = i+ind_En_RdPix;
            state = 1;
        else
            i = i+ind_En_RdPix;
            state = 0;
        end
    else
        ind_En_RdPix = find(vec_desiredData_A([i:len_row_data_Sim],5) == 0,1);
        i = i+ind_En_RdPix-1;
        state = 0;
        
    end
    
	
end 



% Paso 4. Painting the images

close all;

% Sort the Matrix_time_pixel_colour by time less to higher

Matrix2print = sortrows(Matrix_time_pix_colour,1);

% Building the frames to plotting
len_Matrix2print = length(Matrix2print);
Struct_Frames = {[]};
vec_time_pix_colour_tmp = N*M*ones(1,3);
ind_struct = 1;
ind_Matrix_tmp = 1;
struct_lims = {[]};

for x=0:N-1
    
    struct_lims{x+1} = num2str(x);
    
end

for i=1:len_Matrix2print
    
    time    = Matrix2print(i,1);
    pixel   = Matrix2print(i,2);
    colour  = Matrix2print(i,3);
    if isempty(find(vec_time_pix_colour_tmp(:,2) == pixel,1))
        vec_time_pix_colour_tmp(ind_Matrix_tmp,1) = time;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,2) = pixel;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,3) = colour; 
        ind_Matrix_tmp = ind_Matrix_tmp + 1;
    else
        Struct_Frames{ind_struct} = vec_time_pix_colour_tmp;
        vec_time_pix_colour_tmp = N*M*ones(1,3);
        ind_Matrix_tmp = 1;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,1) = time;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,2) = pixel;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,3) = colour;
        ind_struct = ind_struct + 1;
        ind_Matrix_tmp = ind_Matrix_tmp + 1;
    end
    
    if i == len_Matrix2print
        Struct_Frames{ind_struct} = vec_time_pix_colour_tmp;
    end
end

% Painting

max_col = floor(sqrt(length(Struct_Frames)));%3;
max_rows = ceil(sqrt(length(Struct_Frames)))+1;%ceil(length(Struct_Frames)/3);

 h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
 
for i=1:length(Struct_Frames)
   vec_time_pix_colour_tmp = Struct_Frames{i};
   len_vec = length(vec_time_pix_colour_tmp);
   Matrix_paint = zeros(M,N);
   Matrix_paint(:,:) = NaN;
   for j=1:len_vec
      pixel = vec_time_pix_colour_tmp(j,2);
      colour = vec_time_pix_colour_tmp(j,3);
      indx = fix((pixel)/M)+1;indy = rem(pixel,N)+1;
      Matrix_paint(indx,indy) = colour; 
   end
  
   c_min = uint8(min(vec_time_pix_colour_tmp(:,3)));
   c_max = uint8(max(vec_time_pix_colour_tmp(:,3)));
   CMAP = uint8(unique(vec_time_pix_colour_tmp(:,3)));
   
   subplot(max_rows,3,i)
      
   imagesc(uint8(Matrix_paint),[0 255])
   colormap(gray)
   
   if c_min ~= c_max
        colorbar('Ylim',[c_min c_max],'YTick',CMAP);
    else
        colorbar('YTick',CMAP);
    
    end
   
   
   % Find the NaN value to Mark them.
   [rows columns] = find(isnan(Matrix_paint));
   text(columns,rows,'\color{white}NE','HorizontalAlignment','center', ...
       'FontSize',8)
   
   %Creating the title
   title(strcat('Time = [ ',num2str(min(vec_time_pix_colour_tmp(:,1))*1e3), ...
       ' - ', num2str(max(vec_time_pix_colour_tmp(:,1))*1e3),'] ms'))
   
   % Creating lines to marking 
   vc_lineX = linspace(0,N+1,200);
   vc_lineY = ones(1,length(vc_lineX))/2;
    
   for x=1:N
       
       for y=1:M
           
           hold on;
           plot(vc_lineX,vc_lineY+y,'--','Color',[0.7 0.7 0.7]);
           
       end
       hold on
       line([x+0.5 x+0.5],[0 M+1],'LineStyle','--','Color',[0.7 0.7 0.7])
   end
   
   
   
   % Changing the labels axis
   xlabel(['Columns',' ','(',char(i+96),') '])
   ylabel('Rows')
   set(gca,'XTick',[1:N])
   set(gca,'YTick',[1:M])
   set(gca,'XTickLabel',struct_lims)
   set(gca,'YTickLabel',struct_lims)
  
end

cd(PATH_folder_images)

set(gcf,'PaperPositionMode','auto')
print('-depsc2', 'Output_ATIS.eps')
print('-dpng', 'Output_ATIS.png')
saveas(gcf,'Output_ATIS','fig');


cd(pwd_current)
toc
%exit

