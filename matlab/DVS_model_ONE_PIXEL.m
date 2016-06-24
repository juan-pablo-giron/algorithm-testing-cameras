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

clear all;clc;close all;

tic;

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



%% Build the vector for the output
% here is read the time that is equal to others input. At least there is
% one pixel

name_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/spiral8X8_250/spiral8X8_250_0.csv';

input_signal = importdata(name_input);
t = input_signal(:,1);
Iph = input_signal(:,2);
len_t = length(t);  


%% Equations

% Known vaiables
Vref = 1.5;
V_p = 1.4;          % V_tetha+
V_n = 1.6;         % V_tetha-
Vos = 5.42e-3;      % Voffset comparador
log_Iph = log(Iph/Isn);
Iph_max = 100e-12;
Iph_min = 1e-15;
A = 20;             % Gain closed loop differentiator

VdiffON = V_p - Vref + Vos;  
VdiffOFF= V_n - Vref + Vos;

% it loop simulated the behaviour of the model on the time.

log_Iph = log(Iph/Isn);
Vdiff = Vref*ones(1,len_t);

%Vdiff = -nn*fi*A*log_Iph;
%Vdiff_max = max(Vdiff);    %used to normalized
%Vdiff = Vdiff - Vdiff_max; %used to normalized
%Vdiff  = Vref/Vdiff_max*Vdiff;

for i=1:len_t
    value = -nn*fi*A*log(Iph(i)/Isn) ; %Vdiff(i);
    if (value <= VdiffON)
        
        %output_ON(i) = 1.8;
        %Vdiff(i:len_t) = Vdiff(i:len_t) + abs(value); %reset to Vref
        Vdiff(i) = Vref;
    else
        if ( value >= VdiffOFF)
            
            %output_OFF(i) = 1.8;
            %Vdiff(i:len_t) = Vdiff(i:len_t) - abs(value); %reset to Vref
            Vdiff(i) = Vref;
        else
            continue
        end
    end
    Vdiff(i) = value;
    
end

%subplot(3,1,1)
%plot(t,Vdiff)
%grid on
subplot(2,1,1)
plot(t,Iph)
xlim([0 0.5e-3])
grid on
subplot(2,1,2)
plot(t,-nn*fi*A*log_Iph)
xlim([0 0.5e-3])
grid on
toc;

