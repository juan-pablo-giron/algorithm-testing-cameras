% Coding the gray scale 
% Esta funcion tiene como entradas dos umbrales Vhigh y Vlow y un tiempo
% y retorna un valor entre 0 e 255, que indica que tipo de color
% dentro de la escala cinza 
% los datos son fijos.

%clear all;close all;clc;

%Vhigh = 1.7;
%Vlow  = 0.2; 

function Color = CodingGrayScale(Vhigh,Vlow,Time_Sim)

% CURVES = importdata('/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/CODING_GRAYSCALE_ATIS/CURVES.csv');
% Ipd_start = 20e-12;
% Ipd_stop = 1e-9;
CURVES = importdata('/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/CODING_GRAYSCALE_ATIS/CURVES_100pAmax.csv');
Ipd_start = 10e-12;
Ipd_stop = 100e-12;
resol = 255;
delta_Ipd = (Ipd_stop-Ipd_start)/(resol-1);

%Time_Sim =  2.179086540000000e-06;
%Vhigh = 1.7;
%Vlow = 200e-3;

len_CURVES = length(CURVES);
vec_times = zeros(len_CURVES/2,1);

for i=1:len_CURVES/2
   
    index1 = find(abs(CURVES(:,2*i))<=Vhigh,1);
    t_high = CURVES(index1,2*i-1);
    index2 = find(abs(CURVES(:,2*i))<=Vlow,1);
    t_low = CURVES(index2,2*i-1);
    if isempty(index1) || isempty(index2)
        vec_times(i) = NaN;
    else
        t_int = t_high - t_low;
        vec_times(i) = abs(t_int);
    
    end
    
    
    
end

% Return the colour

if isempty(find(vec_times <= Time_Sim,1))
    Color = NaN;
else
    
    Color = find(vec_times <= Time_Sim,1);
    
end
