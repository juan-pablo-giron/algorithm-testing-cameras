%% ================================================================ %%
%   It script is intended to show the response of the DVS model pixel
%   The model can be found in the papers of Tobi Delbruck and 
%   Linares-barranco.
%% ================================================================ %%

%function [output] = DVS_model_fn(full_path_input_simulation)

clear all;clc;close all;

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

%% Input signal
full_path_input_simulation = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM1_MOD/input_SIM1_MOD/input_SIM1_MOD0.csv';
signal = importdata(full_path_input_simulation);

t2 = signal(:,1);
Iph2 = signal(:,2);

Iph = Iph2(1:length(Iph2)); % The first element is infinty
t = t2(1:length(t2)); % The first element is infinity


%% output spectre
full_path_input_simulation = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM1_MOD/output_matlab_SIM1_MOD/output_matlab_SIM1_MOD.csv';
signal = importdata(full_path_input_simulation);

t_spectre = signal(:,1);
C_ON_REQ = signal(:,8);

% Take the second period
index_valid_period0 = find(t_spectre >= 1e-3,1)
index_valid_period1 = find(t_spectre >= 2e-3,1)

%current_factor = 100e-12;
%t = 0.1:.00001:10;
C1 = 400e-15;
C2 = 20e-15;
A = C1/C2;
%b = 0;
%Iph = current_factor*t;
%Iph = current_factor*t;
len_t = length(t);
output = zeros(1,len_t);
%% Equations

% Known vaiables
Vref = 1.46;
V_p = 1.3;  % V_tetha+
V_n = 1.6;  % V_tetha-
Vos = 5.42e-3;% Voffset comparador

log_Iph = log(Iph/Iph(1));  
Vdiff = -nn*fi*A*log_Iph;
Vdiff_max = max(Vdiff);    %used to normalized
Vdiff = Vdiff - Vdiff_max; %used to normalized
Vtemp = Vdiff;
On_event = V_p - Vref + Vos;
%Off_event = ;
mem = 0;
ones = 0;
for i=1:len_t
   value = Vdiff(i);
   if (value <= On_event)
        
       output(i) = 1.8;
       Vdiff(i:len_t) = Vdiff(i:len_t) + abs(value); %reset middle point
       ones = ones + 1;     
   else
        
       continue
        
   end
    
end
ones
% Setting the Vref as the plot in spectre
Vdiff = Vdiff + Vref;
h = figure(1);
subplot(311)
stem((t+1e-3),output)
xlabel('Tiempo')
ylabel('ON Events expected')

subplot(312)
%plot(t,Vdiff)
plot(t_spectre([index_valid_period0:index_valid_period1]), ...
    C_ON_REQ([index_valid_period0:index_valid_period1]),'r')
xlabel('Tiempo')
ylabel('ON Events From Pixel simulated')

subplot(313)
plot(t+1e-3,nn*fi*(-A)*log(Iph/Isn))
xlabel('Tiempo')
ylabel('-A*n*\phi_{t}*Log(Iph/Isn)')

saveas(h,'Plot2.png','png')

%% ================================================================ %%


%% ================================================================ %%
