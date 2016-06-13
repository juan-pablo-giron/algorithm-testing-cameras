% It script creates a triangule wave as steps that increases progessive
clear all;clc;close all;
resol = 255; % Resolution
T = 5e-3; % Signal's period
Imax = 100;
Imin = 1;
deltaI = (Imax - Imin)/(resol-1);
samplesPerHold = 2; 
deltat = (T/2)/(samplesPerHold*resol); % T/2 porque es para arriba y para abjao en el mismo periodo
t = 0:deltat:T;
len_t = length(t);

if (rem(len_t,2) ~= 0 )
    t = 0:deltat:T-deltat;
    len_t = length(t);
end

I_ph = zeros(1,len_t);
I = Imin;
i = 0;
while ( i<=len_t)
    
    if ( i < len_t/2)
        
        I_ph(i+1:i+2) = I;
        I = I + deltaI;
        
        
    else
        
        I = I - deltaI;
        I_ph(i+1:i+2) = I;
       
    end
    
    if ( i + samplesPerHold <len_t)
        i = i+samplesPerHold;
    else
        i = len_t + 1;
    end
    
end
plot(t,I_ph)