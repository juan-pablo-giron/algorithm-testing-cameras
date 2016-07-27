%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Aqui esta el modelo de una camara DVS
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% ========================= PARAMAMETERS MOSFET  ================= %%

close all;clc;clear;

tic;

matlabpool open 8

PATH_input = getenv('PATH_folder_input'); %'/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
%PATH_input = 'C:\Users\Ana Maria Zuñiga V\Documents\JP\MATLAB\Inputs\BAR32X32_200\';
PATH_folder_images = getenv('PATH_folder_images'); % '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';

%PATH_input='/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/BAR32X32_200/';

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
A = 20;             % Gain closed loop differentiator


VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;



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

% Vec Events per pixel per edge
MaxEdges = 10;
Matrix_pix_edges_ON = zeros(N*M,MaxEdges);
Matrix_pix_edges_OFF = zeros(N*M,MaxEdges);
%

vec_Color = {'r','b','g','y'};
deltaV  = linspace(0.1,0.2,length(vec_Color));

matrix2hist1_ON = {[]};
matrix2hist1_OFF = {[]};
names2legend = {[]};

sigma_max = 40e-3;

cd(PATH_input)

for ind_diff=1:length(deltaV)
    V_p = Vref - deltaV(ind_diff);
    V_n = Vref + deltaV(ind_diff);
    Matrix_pix_edges_ON = zeros(N*M,MaxEdges);
    Matrix_pix_edges_OFF = zeros(N*M,MaxEdges);
    names2legend{ind_diff} = num2str(deltaV(ind_diff));
    for edge=1:MaxEdges
        
        parfor i=0:quant_pixel-1;
        %for i=0:quant_pixel-1;
            
            % paso 1. Encontrar Vdiff para cada uno de los pixeles
            name_input = strcat(name_signal,'_',num2str(i),'.csv');
            input_signal = importdata(name_input);
            Iph = input_signal(:,2);
            log_Iph = log(Iph/Isn);
            Vdiff_ind = -nn*fi*A*log_Iph;
            Vdiff_max = max(Vdiff_ind);    %used to normalized
            Vdiff_ind = Vdiff_ind - Vdiff_max; %used to normalized
            
            % Paso 2. Encontrar los eventos ON y OFF.
            ind_event = 1;
            events_off = 0;
            events_on = 0;
            Vrnd = normrnd(0,sigma_max,1,1);
            for j=1:len_t
                value = Vdiff_ind(j);
                
                % Norm Rnd
                
                VdiffON = V_p - (Vref+Vrnd) + Vos;
                VdiffOFF= V_n - (Vref+Vrnd) + Vos;
                % Norm Rnd
                if (value <= VdiffON)
                    Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) + abs(value); %reset to Vref
                    events_on = events_on + 1;
                    Vrnd = normrnd(0,sigma_max,1,1);
                else
                    if ( value >= VdiffOFF)
                        
                        Vdiff_ind(j:len_t) = Vdiff_ind(j:len_t) - abs(value); %reset to Vref
                        events_off = events_off + 1;
                        Vrnd = normrnd(0,sigma_max,1,1);
                    else
                        continue
                    end
                end
                
            end
            %fprintf('Pixel # %d #Events_ON %d #events_off %d\n',i,events_on,events_off)
            Vdiff(:,i+1) = Vdiff_ind;
            Matrix_pix_edges_ON(i+1,edge) = events_on;
            Matrix_pix_edges_OFF(i+1,edge) = events_off;
        end
        
    end
    matrix2hist1_ON{ind_diff} = Matrix_pix_edges_ON;%mean_ON_events';
    matrix2hist1_OFF{ind_diff} = Matrix_pix_edges_OFF;%mean_OFF_events';
        
end
%matlabpool close


% Draw the histogram Number 1

%% OFF

cd(PATH_folder_images)

matrix2hist2_OFF = {[]};
Matrix_pix_events = [];

for ind_diff=1:length(deltaV)
    h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
    Matrix_pix_events = matrix2hist1_OFF{ind_diff};
    if length(Matrix_pix_events(1,:)) > 1
        vec_mean = mean(Matrix_pix_events.');
    else
        vec_mean = Matrix_pix_events;
    end
    subplot(2,2,ind_diff)
    hist(vec_mean)
    [y,x]=hist(vec_mean);
    ind_valids =  vec_mean > 0;
    matrix2hist2_OFF{ind_diff} = vec_mean(ind_valids);
    set(gca,'xscale','log','xlim',[1 100])
    title(['\mu=',num2str(mean(vec_mean)),' events & \sigma= ',num2str(std(vec_mean)),' VdiffOFF= ',num2str(names2legend{ind_diff}),'V'])
    xlabel('#events/pixel/edge')
    ylabel('# pixels')
    grid on
end

string = 'Model';
set(h,'PaperPositionMode','auto')
print('-depsc2', ['Output_',string,'_DVS_UNIFORMITY_OFF','.eps'])
print('-dpng', ['Output_',string,'_DVS_UNIFORMITY_OFF','.png'])
saveas(h,['Output_',string,'_DVS_UNIFORMITY_OFF'],'fig');

%% ON

matrix2hist2_ON = {[]};

for ind_diff=1:length(deltaV)
    h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
    Matrix_pix_events = matrix2hist1_ON{ind_diff};
    if length(Matrix_pix_events(1,:)) > 1
        vec_mean = mean(Matrix_pix_events.');
    else
        vec_mean = Matrix_pix_events;
    end
    subplot(2,2,ind_diff)
    hist(vec_mean)
    [y,x]=hist(vec_mean);
    ind_valids =  vec_mean > 0;
    matrix2hist2_ON{ind_diff} = vec_mean(ind_valids);
    set(gca,'xscale','log','xlim',[1 100])
    title(['\mu=',num2str(mean(vec_mean)),' events & \sigma= ',num2str(std(vec_mean)),' VdiffON= ',num2str(names2legend{ind_diff}),'V'])
    xlabel('#events/pixel/edge')
    ylabel('# pixels')
    grid on    
    
end

string = 'Model';
set(h,'PaperPositionMode','auto')
print('-depsc2', ['Output_',string,'_DVS_UNIFORMITY_ON','.eps'])
print('-dpng', ['Output_',string,'_DVS_UNIFORMITY_ON','.png'])
saveas(h,['Output_',string,'_DVS_UNIFORMITY_ON'],'fig');

%% Drawing the second histogram
ratio = 5; %significa un contraste de 5:1
theta = log(ratio);

for ind_diff=1:length(deltaV)
    
    h1=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
    subplot(2,2,ind_diff)
    vec_x = matrix2hist2_OFF{ind_diff};
    %ind_valid = vec_x > 0 ;
    vec_x = (theta./vec_x)*100;
    hist(vec_x)
    set(gca,'xlim',[1 100])
    xlabel('\theta_{ev}')
    ylabel('# pixels')
    title(['\mu=',num2str(mean(vec_x)),' events & \sigma= ',num2str(std(vec_x)),' VdiffOFF= ',num2str(names2legend{ind_diff}),'V'])
    grid on
    
    h2=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
    subplot(2,2,ind_diff)
    vec_x = matrix2hist2_ON{ind_diff};
    %ind_valid = vec_x > 0 ;
    vec_x = (theta./vec_x)*100;
    hist(vec_x)
    set(gca,'xlim',[1 100])
    xlabel('\theta_{ev}')
    ylabel('# pixels')
    title(['\mu=',num2str(mean(vec_x)),' events & \sigma= ',num2str(std(vec_x)),' VdiffON= ',num2str(names2legend{ind_diff}),'V'])
    grid on
end


string = 'Model';
set(h1,'PaperPositionMode','auto')
print('-depsc2', ['Output_',string,'_DVS_SENSITIVITY_OFF','.eps'])
print('-dpng', ['Output_',string,'_DVS_SENSITIVITY_OFF','.png'])
saveas(h1,['Output_',string,'_DVS_SENSITIVITY_OFF'],'fig');

set(h2,'PaperPositionMode','auto')
print('-depsc2', ['Output_',string,'_DVS_SENSITIVITY_ON','.eps'])
print('-dpng', ['Output_',string,'_DVS_SENSITIVITY_ON','.png'])
saveas(h2,['Output_',string,'_DVS_SENSITIVITY_ON'],'fig');

matlabpool close

%}

cd(pwd_current)
toc;

exit;