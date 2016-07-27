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

name_signal = getenv('name_Signalsinput'); 
N = str2num(getenv('N')); 
M = str2num(getenv('M')); 
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

name_input = strcat(PATH_input,name_signal,'_0.csv');
input_signal = importdata(name_input);
t = input_signal(:,1);
len_t = length(t);
quant_pixel = N*M;
Vdiff=zeros(len_t,quant_pixel);
Vdiff_ind = zeros(len_t,1);

clear t

% Vec Events per pixel per edge
MaxEdges = 10;


matrix2hist1_ON = {[]};
matrix2hist1_OFF = {[]};

% Structure data
Matrix_pix_edges_ON = zeros(N*M,1);
Matrix_pix_edges_OFF = zeros(N*M,1);


% Variations
sigma_max = 10e-3; %Vrst
sigma_Vos = 5.42e-3;

cd(PATH_input)

parfor i=0:quant_pixel-1;
    
    
    % paso 1. Encontrar Vdiff para cada uno de los pixeles
    name_input = strcat(name_signal,'_',num2str(i),'.csv');
    name_noise = strcat('noise_',num2str(i),'.csv');
    input_signal = importdata(name_input);
    noise_signal = importdata(name_noise);
    Iph = input_signal(:,2);
    noise = noise_signal(:,2);
    Iph = Iph + noise; %Adding noise to the signal Iph
    log_Iph = log(Iph/Isn);
    Vdiff_ind = -nn*fi*A*log_Iph;
    Vdiff_max = max(Vdiff_ind);    %used to normalized
    Vdiff_ind = Vdiff_ind - Vdiff_max; %used to normalized
    
    % Paso 2. Encontrar los eventos ON y OFF.
    
    events_off = 0;
    events_on = 0;
    Vrnd = normrnd(0,sigma_max,1,1);
    Vos = normrnd(0,sigma_Vos,1,1);
    
    for j=1:len_t
        value = Vdiff_ind(j);
        
        VdiffON = V_p - (Vref+Vrnd) + Vos;
        VdiffOFF= V_n - (Vref+Vrnd) + Vos;
        
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
    
    Vdiff(:,i+1) = Vdiff_ind;
    Matrix_pix_edges_ON(i+1) = events_on;
    Matrix_pix_edges_OFF(i+1) = events_off;
end

matlabpool close

% Mean events fired per pixel edges

Matrix_pix_edges_ON = Matrix_pix_edges_ON/MaxEdges;
Matrix_pix_edges_OFF = Matrix_pix_edges_OFF/MaxEdges;
        
%% OFF

cd(PATH_folder_images)


%% ======================   Histograms    ============================= %%

VDIFF = abs(Vref - V_n);
Ibright = 100e-12;
Idark  = 20e-12;
SensivityStimulus = log(Ibright/Idark);

%% ------------------------ ON CHANNEL  -------------------------------%%

mu = mean(Matrix_pix_edges_ON);

figure('Visible','on','units','normalized')
valid_indx = Matrix_pix_edges_ON > 0;
hist(Matrix_pix_edges_ON(valid_indx));
set(gca,'xscale','log','xlim',[1 40]);
xlabel('#events/pixel/edge')
ylabel('# pixels')
title(['\mu=',num2str(mu)])
legend(['VDIFF ON = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
string = 'Model';
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_HIST1_ON_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_HIST1_ON_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_HIST1_ON_',num2str(VDIFF)],'fig');

% HIST 2

%close all;
figure('Visible','on','units','normalized')
Matrix_pix_edges_ON2 = 100*SensivityStimulus./Matrix_pix_edges_ON(valid_indx);
mu = mean(Matrix_pix_edges_ON2);
sigma = std(Matrix_pix_edges_ON2);
hist(Matrix_pix_edges_ON2);
set(gca,'xlim',[1 40]);
xlabel('%{\theta_{ev}}^+')
ylabel('# pixels')
title(['\mu = ',num2str(mu),' ','\sigma = ',num2str(sigma)])
legend(['VDIFF ON = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
string = 'Model';
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_CS_ON_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_CS_ON_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_CS_ON_',num2str(VDIFF)],'fig');


%%  ---------------------  OFF CHANNEL ---------------------------- %
%close all;
figure('Visible','on','units','normalized')
mu = mean(Matrix_pix_edges_OFF);
valid_indx = Matrix_pix_edges_OFF > 0;
hist(Matrix_pix_edges_OFF(valid_indx));
set(gca,'xscale','log','xlim',[1 40]);
xlabel('#events/pixel/edge')
ylabel('# pixels')
title(['\mu=',num2str(mu)])
legend(['VDIFF OFF = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
string = 'Model';
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_HIST1_OFF_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_HIST1_OFF_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_HIST1_OFF_',num2str(VDIFF)],'fig');

% HIST 2

%close all;
figure('Visible','on','units','normalized')
Matrix_pix_edges_OFF2 = 100*SensivityStimulus./Matrix_pix_edges_OFF(valid_indx);
mu = mean(Matrix_pix_edges_OFF2);
sigma = std(Matrix_pix_edges_OFF2);
hist(Matrix_pix_edges_OFF2);
set(gca,'xlim',[1 40]);
xlabel('% {\theta_{ev}}^-')
ylabel('# pixels')
title(['\mu = ',num2str(mu),' ','\sigma = ',num2str(sigma)])
legend(['VDIFF OFF = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
string = 'Model';
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_CS_OFF_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_CS_OFF_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_CS_OFF_',num2str(VDIFF)],'fig');


cd(pwd_current)
toc;

%clear all;

%exit;