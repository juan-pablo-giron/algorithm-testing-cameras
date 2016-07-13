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
    for j=1:len_t
       value = Vdiff_ind(j);
       if (value <= VdiffON)
           Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) + abs(value); %reset to Vref
           vec_time_pix = [t(j) i];
           ON_events{ind_ON} = vec_time_pix;
           Event_pix.value(ind_event) = t(j);
           ind_ON = ind_ON + 1;
           ind_event=ind_event+1;
       else
           if ( value >= VdiffOFF)

                Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) - abs(value); %reset to Vref
                vec_time_pix = [t(j) i];
                OFF_events{ind_OFF} = vec_time_pix;
                Event_pix.value(ind_event) = t(j);
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

% Paso 3. Plot


cd(PATH_folder_images)

i = 0;
X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);
scaleTime=1e3;
len_ON_events = length(ON_events);

struct_limsX = {[]};
struct_limsY = {[]};
for x=1:2*N
    
    if rem(x,2) == 1
        struct_limsX{x} = '';
    else
        struct_limsX{x} = num2str(x/2 - 1);
    end
end

for x=1:2*M
    
    if rem(x,2) == 1
        struct_limsY{x} = '';
    else
        struct_limsY{x} = num2str(x/2 - 1);
    end
end

if ( len_ON_events > 1)
    fig_ON = figure('Visible','off','units','normalized');%,'outerposition',[0 0 1 1]);
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
    %colorbar;
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    %set(gca,'XTickLabels',struct_limsY)
    %set(gca,'YTickLabels',struct_limsX)
    set(gca,'Ydir','reverse')
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'ON EVENTS MODEL';
    name_fig = 'ON_events_3D_Model';
    title(name_title)
    set(fig_ON,'PaperPositionMode','auto')
    print('-depsc2','DVS_ON_Model.eps')
    print('-dpng','DVS_ON_Model.png')
    saveas(gcf,'DVS_ON_Model','fig');
end


len_OFF_events = length(OFF_events);
z  = zeros(2*M,2*N);
i = 0;

if ( len_OFF_events >1)
    fig_OFF = figure('Visible','off');
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
    set(gca,'Ydir','reverse')
    set(gca,'xtick',X);
    set(gca,'ytick',Y);
    xlim([0 N])
    ylim([0 M])
    xlabel('COLUMNS')
    ylabel('ROWS')
    zlabel('Time ms')
    name_title = 'OFF EVENTS MODEL';
    title(name_title)
    set(fig_OFF,'PaperPositionMode','auto')
    print('-depsc2','DVS_OFF_Model.eps')
    print('-dpng','DVS_OFF_Model.png')
    saveas(gcf,'DVS_OFF_Model','fig');
end



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
    t = input_signal(:,1);
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

% Free memory

% clearvars -except Matrix_time_pix_colour Vdiff Vint t curr_pwd PATH_input ...
%     PATH_folder_images name_signal N M

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

max_subfig = 16;
ind_subfig = 1;
ind_nameFig = 1;
% Garantizar que siempre se vean un maximo de subplot
% si es hay demasiados frames, entonces se subdividen
% las figuras. Dando un mejor visual.

frames_maxsubfig = ceil(length(Struct_Frames)/max_subfig);
elements_fig = ceil(length(Struct_Frames)/frames_maxsubfig);
max_col = ceil(sqrt(elements_fig));
max_rows = max_col;    


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
   
   subplot(max_rows,max_col,ind_subfig)
      
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
   
   if (ind_subfig == elements_fig)
       
       ind_subfig = 1;
       cd(PATH_folder_images)
       set(gcf,'PaperPositionMode','auto')
       print('-depsc2', ['Output_Model_ATIS',num2str(ind_nameFig),'.eps'])
       print('-dpng', ['Output_Model_ATIS',num2str(ind_nameFig),'.png'])
       saveas(gcf,['Output_Model_ATIS',num2str(ind_nameFig)],'fig');
       close all;
       
       if i ~= length(Struct_Frames)
           %para no crear una figura en blanco sin nada
           h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
           ind_nameFig = ind_nameFig + 1;
           cont_plot = 1; % Avisa si es necesario grabar la ultima grafica
       else
           cont_plot = 0;
           
       end
   else
       ind_subfig = ind_subfig + 1;
       
   end
   
   
end

if cont_plot

    cd(PATH_folder_images)
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2', ['Output_Model_ATIS',num2str(ind_nameFig),'.eps'])
    print('-dpng', ['Output_Model_ATIS',num2str(ind_nameFig),'.png'])
    saveas(gcf,['Output_Model_ATIS',num2str(ind_nameFig)],'fig');
end

toc
cd(curr_pwd)
exit