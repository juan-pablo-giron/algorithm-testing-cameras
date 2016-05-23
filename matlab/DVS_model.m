%% ================================================================ %%
%   It script is intended to show the response of the DVS model pixel
%   The model can be found in the papers of Tobi Delbruck and 
%   Linares-barranco.
%% ================================================================ %%

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
current_factor = 100e-12;
t = 0.1:.00001:10;
C1 = 400e-15;
C2 = 20e-15;
A = C1/C2;
b = 0;
Iph = current_factor*t;
Iph = current_factor*t;
len_t = length(t);
output = zeros(1,len_t);
%% Equations

% Known vaiables
Vref = 1.5;
V_p = 1.3;  % V_tetha+
V_n = 1.6;  % V_tetha-
Vos = 10e-3;% Voffset comparador

log_Iph = log(Iph/Isn);  
Vdiff = -nn*fi*A*log_Iph;

Vdiff_max = max(Vdiff);    %used to normalized
Vdiff = Vdiff - Vdiff_max; %used to normalized
Vtemp = Vdiff;
RS = V_p - Vref + Vos;
mem = 0;

for i=1:len_t
    %log_Iph = log(Iph(i)/Iph(1));
    %Vdiff(i) = -nn*fi*A*log_Iph + mem; 
    value = Vdiff(i);
    if (value <= RS)
        
        output(i) = 1;
        Vdiff(i:len_t) = Vdiff(i:len_t) + abs(value); %reset middle point
            
    else
        
        continue
        
    end
    
end

% Setting the Vref as the plot in spectre
Vdiff = Vdiff + Vref;

subplot(311)
stem(t,output)

subplot(312)
plot(t(1:length(Vdiff)),Vdiff)

subplot(313)
plot(t(1:length(Vtemp)),Vtemp)


%% ================================================================ %%


%% ================================================================ %%
