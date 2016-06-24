% It script creates a triangule wave as steps that increases progessive

%function []=spiralNxM(N,M,freq)

%         <------- N ------>
%         ^ Pix0 Pix1 .....
%         |   .
%         |     .
%         M       .
%         |         .
%         |           .PixN,M

% The curve is similar to:
%
%       __
%     _|  |_
%   _|      |_
% _|          |_

tic;

clear all;clc;close all;

N = 2; 
M = 2;
quant_pixel=N*M;
freq = 250;
resol = 255; % Count colours that we wanna to see 
rpm = freq*60;
t_hold = (1/freq)/resol;
samplesPerHold = 2; 
T = t_hold*resol;
scaleTime = 1e3;

curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
%PATH_input = '/sdcard/documents/MSc/Cadence_analysis/Inputs/';

cd(PATH_input);
nameSignal = strcat('TrianguleWave',int2str(N),'X',int2str(M),'_',int2str(freq));
name_folder = strcat(nameSignal,'/');
[s,mess1,mess2]=mkdir(name_folder);

if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');
cd(curr_path);

Imax = 1e-9;
Imin = 1e-12;
deltaI = (Imax - Imin)/(resol-1);

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

for p=0:quant_pixel-1
    
    i = 0;
    while ( i<=len_t)

        if ( i < len_t/2)

            I_ph(i+1:i+samplesPerHold) = I;
            I = I + deltaI;


        else

            I = I - deltaI;
            I_ph(i+1:i+samplesPerHold) = I;

        end

        if ( i + samplesPerHold <len_t)
            i = i+samplesPerHold;
        else
            i = len_t + 1;
        end

    end
    signal(:,1) = t';
    signal(:,2) = I_ph';
    
    % interp1
    cd(PATH_input)
    t_start=t(1);
 	t_stop=t(length(t));
 	time_interp = t_start:t_stop/(25*len_t*samplesPerHold):t_stop;
 	I_pd_interp = interp1(t,I_ph,time_interp,'linear');
    name_file = strcat(nameSignal,'_',num2str(p),'.csv');
	dlmwrite(name_file,[time_interp' I_pd_interp'],'delimiter',' ','precision',10,'newline','unix');
    

end

h=figure(1)
semilogy(time_interp*scaleTime,I_pd_interp*1e12);
xlabel('time ms')
ylabel('I_{pd} (pA)')
grid on;
saveas(h,strcat(nameSignal,'.png'),'png');
saveas(h,strcat(nameSignal,'.fig'),'fig');
cd(curr_path);
