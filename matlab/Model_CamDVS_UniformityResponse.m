%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Aqui esta el modelo de una camara DVS
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% ========================= PARAMAMETERS MOSFET  ================= %%

close all;clc;clear;

tic;

%matlabpool open 8

PATH_input = getenv('PATH_folder_input'); %'/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';
%PATH_input = 'C:\Users\Ana Maria Zu?iga V\Documents\JP\MATLAB\Inputs\BAR32X32_200\';
PATH_folder_images = getenv('PATH_folder_images'); % '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/TrianguleWave7X8_250/';

%PATH_input='/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/BAR32X32_200/';

name_signal = getenv('name_Signalsinput'); 
N = str2num(getenv('N')); 
M = str2num(getenv('M')); 
V_p = str2num(getenv('Vdon'));
V_n = str2num(getenv('Vdoff'));
Vref = 1.5;
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

%matlabpool close

% Mean events fired per pixel edges

Matrix_pix_edges_ON = Matrix_pix_edges_ON/MaxEdges;
Matrix_pix_edges_OFF = Matrix_pix_edges_OFF/MaxEdges;


%% ======================   Histograms    ============================= %%
cd(pwd_current)
Vref = 1.5;
VDIFF = abs(Vref - V_n);
string = 'MODEL';
plotHistograms(Matrix_pix_edges_ON,Matrix_pix_edges_OFF,string,VDIFF)

cd(pwd_current)
toc;

clear all,close all;

exit;