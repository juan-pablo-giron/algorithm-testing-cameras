%% ================================================================ %%
%   The function of this script is calculates the desired behavioural
%   response of one pixel DVS. The response is based in the model presented
%   by Tobi Delbruck and Linares-barranco. It script determines the
%   quantity of pixels with the quantity of files in the input PATH.
%   Input: -full path of the file input simulated in the circuit in Cadence
%          -Name of the simulation            
%   Output: - This script write a .csv file with 2N+1 columns where 2 is be
%   cause are two signals ON/OFF, N is the total of pixels of the array, 
%   and the first columns is refer to the the simulation is to one period.
%   The column are order so: time ON_pix0 OFF_pix0 ON_pix1 OFF_pix1 so on
%% ================================================================ %%

%function [] = DVS_model_fn(path_input_simulation,path_output,Name_simulation)



clear all;clc;close all;

path_input_simulation='/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM2/input_SIM2/';
path_output = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM2/input_SIM2/';
Name_simulation='SIM2';
D = dir([path_input_simulation, '/*.csv']);
Num = length(D(not([D.isdir]))); %Count how files there are.

%% ========================= PARAMAMETERS MOSFET  ================= %%
nn = 1.334;
np = 1.369;
Vtn = 359.2e-3;
Vtp = 387e-3;
Kn = 227.1e-6;
Kp = 48.1e-6;
fi = 25.8e-3;
Ratio = 0.5e-6/2e-6;
Isn = 2*nn*fi^2*Kn*Ratio;

%% ========================== MODEL =============================== %%

quant_pixels = Num;


%% Build the vector for the output
% here is read the time that is equal to others input. At least there is
% one pixel

name_input = strcat(path_input_simulation,'input_',Name_simulation,int2str(0),'.csv');
input_signal = importdata(name_input);
t = input_signal(:,1);
len_t = length(t);  
output_ON = zeros(1,len_t);
output_OFF = zeros(1,len_t);
total_result = zeros(len_t,2*quant_pixels+1);
total_result(:,1) = t;

%% Equations

% Known vaiables
Vref = 1.46;
V_p = 1.3;          % V_tetha+
V_n = 1.62;         % V_tetha-
Vos = 5.42e-3;      % Voffset comparador
A = 20;             % Gain closed loop differentiator

VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;

% it loop simulated the behaviour of the model on the time.

for N=1:quant_pixels
    name_input = strcat(path_input_simulation,'input_',Name_simulation,int2str(N-1),'.csv');
    input_signal = importdata(name_input);
    Iph = input_signal(:,2);
    log_Iph = log(Iph/Isn);  
    Vdiff = -nn*fi*A*log_Iph;
    Vdiff_max = max(Vdiff);    %used to normalized
    Vdiff = Vdiff - Vdiff_max; %used to normalized
    
    
    for i=1:len_t
       value = Vdiff(i);
       if (value <= VdiffON)

           output_ON(i) = 1.8;
           Vdiff(i:len_t) = Vdiff(i:len_t) + abs(value); %reset to Vref

       else
           if ( value >= VdiffOFF)

                output_OFF(i) = 1.8;
                Vdiff(i:len_t) = Vdiff(i:len_t) - abs(value); %reset to Vref

           else
               continue
           end
       end

    end
    total_result(:,N+1) = output_ON';
    total_result(:,N+2) = output_OFF';
    

end
% Setting the Vref as the plot in spectre
%Vdiff = Vdiff + Vref;

%% Write the file a .csv file
cd(path_output)
dlmwrite(strcat('Expected_behaviour_',Name_simulation,'.csv'),total_result, ...
        'delimiter',' ','precision',10,'newline','unix');
    
%% plot

subplot(2,1,1)
plot(t,total_result(:,2))
ylabel('ON EVENTS')
xlabel('time')

subplot(2,1,2)
plot(t,total_result(:,3))
ylabel('OFF EVENTS')
xlabel('time')


