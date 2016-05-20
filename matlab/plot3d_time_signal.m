
clear all;clc;close all;

PATH_DIR_SIM ='/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM1/output_matlab_SIM1/';
cd(PATH_DIR_SIM)

%% ==================================================================== %%

%% ==================   DATA SPECIFIED BY THE USER ==================== %%

X_length = 1;
Y_length = 1;
quant_pixels = X_length*Y_length;

value_ON = 1.2;
value_OFF = 0.02;

lst_name_signals = 'V_pd,I_pd,Vout_sf,Voff,Von,C_OFF_REQ,C_ON_REQ,C_OFF_ACK,C_ON_ACK,Vrst';
vec_signals = regexp(lst_name_signals,',','split');  
len_vector_signals = length(vec_signals);% No include the time
desired_signal2plot = 'C_ON_REQ';
index_desiredSignal2Plot =  f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals);
index_desiredSignal2Plot = index_desiredSignal2Plot+1; %Include the time.
len_vector_signals = len_vector_signals + 1; %include the time
%% ======================  READING THE INFORMATION  =================== %%

lst_data = importdata('output_matlab_SIM1.csv');
rows_lst_data = length(lst_data);
time = lst_data(:,1);


%% ====================== PLOT THE SIGNAL AS A SURFACE ================ %%

%% Define the array of the camera given by the X and Y lengths.
z  = zeros(X_length+1,Y_length+1);
matrix_index_valueON = {[]}; %Storage the valid data in one struct saving resource
% Find all ON_values on the desired signal for
% all the pixels on the array using the built-in function FIND

i = 0;
while i < quant_pixels
    
    next_signal_pixel = i*quant_pixels + index_desiredSignal2Plot; %It index indicates where is the next valid signal
    desired_signal = lst_data(:,next_signal_pixel);
    index_valueON = find(desired_signal >= value_ON);
    matrix_index_valueON{i+1} = index_valueON;
    i = i + 1;
end

%% Printing the output for N(X) x M(Y) pixels

i = 0;

% is build the array of the camera

X = 0:X_length;
Y = 0:Y_length;

while i < quant_pixels
   
    j = 1;
    valid_data = (matrix_index_valueON{i+1});
    len_valid_data_matrix = length(valid_data);
    row = rem(i,X_length);
    col = fix(i/X_length);
    y1  = row+1;
    y2  = y1+1;
    x1  = col+1;
    x2  = x1+1;
    while j <= len_valid_data_matrix
       z(:,:) = NaN; % Avoid that Matlab create lines no desired
       next_point = valid_data(j);
       z([y1 y2],[x1 x2]) = time(next_point);
       % surface plot
       surf(X,Y,z)
       hold on
       grid on
       j = j + 1;
          
    end
    
    i = i+1;
    
end

% adjusting apperance

set(gca,'xtick',X);
set(gca,'ytick',Y);
min_t = min(time);
max_t = max(time);
set(gca,'zlim',[min_t max_t])
xlabel('X')
ylabel('Y')
zlabel('Time')
name_title = strcat('Events per time with the signal',desired_signal2plot);
name_fig = strcat('Fig_TimeVs',desired_signal2plot);
title(name_title)
savefig(name_fig)









