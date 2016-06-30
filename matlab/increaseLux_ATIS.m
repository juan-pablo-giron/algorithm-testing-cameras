% Esta función proporciona el conjunto de datos necesarios para 
% simular una cámara ATIS.

tic;

clear all;clc;close all;

N = 8; 
M = 8;
freq = 200;
rpm = freq*60;

curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
%PATH_input = '/sdcard/documents/MSc/Cadence_analysis/Inputs/';
cd(PATH_input);
nameSignal = strcat('illuminationAtis',int2str(N),'X',int2str(M),'_',int2str(freq));
name_folder = strcat(nameSignal,'/');
[s,mess1,mess2]=mkdir(name_folder);
if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');
cd(curr_path);

T = 1/freq;
delta_time = T/quant_pixel;
vec_time = 0:delta_time:T;
len_t=length(vec_time);
t_start=vec_time(1);
t_stop=vec_time(len_t);
frames = 8;
samples = 2;

matrix = zeros(M,N);
