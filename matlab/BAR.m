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

matlabpool open 8;

N = 32; 
M = 32;
quant_pixel=N*M;
freq = 200;
T = 1/freq;
curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';

cd(PATH_input);
nameSignal = strcat('BAR',int2str(N),'X',int2str(M),'_',int2str(freq));
name_folder = strcat(nameSignal,'/');
[s,mess1,mess2]=mkdir(name_folder);

% Creando el directorio de la entrada

if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');
cd(curr_path);



Imax = 100e-12;
Imin = 20e-12;

t = linspace(0,T,M+2);
len_t = length(t);
vec_Iph = Imin*ones(len_t,1);
Matrix_Iph = zeros(len_t,M);
vec_Iph(1) = Imax;

% Shift-rigth al vector Iph

for i=1:M
    
    Y = circshift(vec_Iph,1);
    Matrix_Iph(:,i) = Y;
    vec_Iph = Y;
    
end



time_interp = linspace(0,T,200*len_t);

cd(PATH_input)
h = figure(1);
ind_pix = 0;
parfor i=1:M
    vec_Iph = Matrix_Iph(:,i);
    I_pd_interp = interp1(t',vec_Iph,time_interp','linear');
    plot(time_interp*1e3,I_pd_interp,'Color',[1/i,2/(5*i),3/(4*i)]);
    hold on
    for j=1:N
        name_file = strcat(nameSignal,'_',num2str((i-1)*N+(j-1)),'.csv');
        dlmwrite(name_file,[time_interp' I_pd_interp],'delimiter',' ','precision',10,'newline','unix');
        %ind_pix = ind_pix + 1;
    end
end

saveas(h,nameSignal,'png');
saveas(h,nameSignal,'fig');
xlabel('time ms')
ylabel('I_{pd} (pA)')

matlabpool close;

cd(curr_path);

toc;
