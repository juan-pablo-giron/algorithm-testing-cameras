%function []=spiralNxM(N,M,freq)

%         <------- N ------>
%         ^ Pix0 Pix1 .....
%         |   .
%         |     .
%         M       .
%         |         .
%         |           .PixN,M

tic;

clear all;clc;close all;

N = 4; 
M = 4;

curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
cd(PATH_input);
nameSignal = strcat('spiral',int2str(N),'X',int2str(M));
[s,mess1,mess2]=mkdir(nameSignal);
if (~strcmp(mess1,''))
   
    rmdir(nameSignal)
    mkdir(nameSignal);
end
PATH_input = strcat(PATH_input,nameSignal,'/');
cd(curr_path);
pixel = 0;
start_col = 1;end_Col = N;
start_row = 2;end_row = M;
I0 = 0;
Ich = 1;
freq = 200; 
state = 0;
quant_pixel = N*M;
Array = I0*ones(M,N);
i = 1;j=1;

T = 1/freq;
delta_time = T/quant_pixel;
vec_time = 0:delta_time:T-delta_time;
samples = 20;

% Only for the plot

X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);
while (pixel < quant_pixel)
   
   z(:,:) = NaN;
   switch state
       
       case 0
           
            % the gradient go to rigth
            if ( j < end_Col)
                Array(i,j) = Ich;
                time = vec_time(pixel+1);
                j = j + 1;
                pixel = pixel + 1;
                export = true;
            else
                end_Col = end_Col - 1;
                state = 1;
                export = false;
            end
            
       case 1
       
            % The gradient is downing by one column
            if ( i < end_row )
                Array(i,j) = Ich;
                time = vec_time(pixel+1);
                i = i + 1;
                pixel = pixel + 1;
                export = true;
            else
                end_row = end_row - 1;
                state = 2;
                export = false;
            end
       case 2
           
            % el gradiente esta yendo de derecha a izquierda
            if ( j > start_col)
                Array(i,j) = Ich;
                time = vec_time(pixel+1);
                j = j - 1;
                pixel = pixel + 1;
                export = true;
            else
                start_col = start_col + 1;
                state = 3;
                export = false;
            end
       case 3
           
           % El gradiente esta subiendo por una columna
           if ( i >= start_row) 
               Array(i,j) = Ich;
               time = vec_time(pixel+1);
               i = i - 1;
               pixel = pixel + 1;
               export = true;
           else
               i = i + 1;
               j = j + 1;
               start_row = start_row + 1;
               export = false;
               if pixel+1 == quant_pixel
                   
                   state = 4;
               else
                   state = 0;
               end
               
           end
       case 4
           % Left one pixel only!
           Array(i,j) = Ich;
           time = vec_time(pixel+1);
           pixel = pixel + 1;
           export = true;
   end
   % --- Export data ---%
   
   if (export)
        create_InputSignal(time,delta_time,N,M,samples,Array,nameSignal,PATH_input)
        Array(:,:) = I0;
   end
    
       
   
   % --- End expor data ---%
   % --- plot ---%
   y1  = i;
   y2  = y1+1;
   x1  = j;
   x2  = x1+1;
   z([y1 y2],[x1 x2]) = time;
   surf(X,Y,z)
   hold on
   grid on
   % --- End plot ---%
      
end
cd(curr_path)
toc;