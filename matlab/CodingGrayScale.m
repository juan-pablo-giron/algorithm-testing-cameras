% Coding the gray scale 
% Esta funcion tiene como entradas dos umbrales Vhigh y Vlow y un tiempo
% y retorna un valor entre 0 e 255, que indica que tipo de color
% dentro de la escala cinza 
% los datos son fijos.

function [vec_color vec_COD_TIME] = CodingGrayScale(Vhigh,Vlow,resol,Clim)

CURVES = importdata('/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/CODING_GRAYSCALE_ATIS/CURVES_2000pts.csv');
time_RST = 100e-9; % tiempo fijo que se usó para extraer las curvas. 

%Vhigh = 1.7;
%Vlow = 200e-3;
%resol = 4;
%Clim = [0 255];
vec_color = linspace(Clim(1),Clim(2),resol);

len_CURVES = length(CURVES);
vec_COD_TIME = zeros(resol,1); % es el vectore final que contiene los n espacios definido por la resolucion
vec_time_curves = zeros(len_CURVES/2,1);

% Tomando los tiempos de todas las curvas
for i=1:len_CURVES/2
    vec_time = CURVES(:,2*i-1);
    v_int = CURVES(:,2*i);
    len_v_int = length(v_int);
    start_time = find(vec_time >= time_RST,1);
    index1 = find(v_int(start_time:len_v_int)<=Vhigh,1);
    t_high = vec_time(index1+start_time);
    index2 = find(v_int(start_time:len_v_int)<=Vlow,1);
    t_low = vec_time(index2+start_time);
    %if ~(isempty(index1) || isempty(index2)) 
    vec_time_curves(i) = t_low - t_high;
    %end
end

% creando los limites

step = floor((len_CURVES/2)/resol);
vec_time_curves = sort(vec_time_curves,'descend');
for i=1:resol-1
   
   vec_COD_TIME(i) = vec_time_curves(step*i);
      
end
