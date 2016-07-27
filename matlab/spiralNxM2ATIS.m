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

matlabpool open 8;

N = 4; 
M = 4;
freq = 100;
rpm = freq*60;

curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
cd(PATH_input);
nameSignal = strcat('spiral_ATIS_',int2str(N),'X',int2str(M),'_',int2str(freq));
name_folder = strcat(nameSignal,'/');
[s,mess1,mess2]=mkdir(name_folder);
if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');
cd(curr_path);
pixel = 0;
start_col = 1;end_Col = N;
start_row = 2;end_row = M;

I0 = 20e-15;
quant_pixel = N*M;
Ich1 = linspace(18e-12,1e-9,quant_pixel);
delta_Ich1 = Ich1(2) - Ich1(1);
I_ph = 1e-9;

scaleTime = 1e3;

state = 0;

Array = I0*ones(M,N);
i = 1;j=1;
samples = 2;
T = 1/freq;
delta_time = T/quant_pixel;
vec_time = linspace(0,T,2*samples*N*M+2); % + 2 para incluir un pequeno delay 
len_t=length(vec_time);
t_start=vec_time(1);
t_stop=vec_time(len_t);


Matrix_pixels = zeros(len_t,N*M);

% Only for the plot

X = 0:2*N-1;
Y = 0:2*M-1;
z  = zeros(2*M,2*N);
h = figure(1);

% y -> Columns
% x -> Rows


% Ajustando el primer valor

Matrix_pixels(:,:) = I0;
Matrix_pixels(:,:) = I0;
ind_time_start1 = 3;
ind_time_start2 = len_t/2 + 3;


% Se contruye una matriz de N*M con numeros del 1 hasta N*M

Matrix_next_pixel = zeros(M,N);
pix = 1;
for row=1:N
    
    for col=1:M
        
        Matrix_next_pixel(row,col) = pix;
        pix = pix + 1;
        
    end
    
end



% Only are fired ON spikes between 0 to T/2

while (pixel < quant_pixel)
   
   z(:,:) = NaN;
   
   
      
   switch state
       
       case 0
           
            % the gradient go to rigth
            if ( j < end_Col)
                
                ind_pix = Matrix_next_pixel(i,j);
                
                time1 = vec_time(pixel+ind_time_start1);
                Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = I_ph;
                Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = I_ph;
                ind_time_start1 = ind_time_start1 + 1;
                % --- plot ---%
                y1  = i;
                y2  = y1+1;
                x1  = j;
                x2  = x1+1;
                z([y1 y2],[x1 x2]) = scaleTime*time1;
                surf(X,Y,z)
                hold on
                grid on
                % --- End plot ---%
                j = j + 1;
                pixel = pixel + 1;
                I_ph = I_ph - delta_Ich1; 
            else
                end_Col = end_Col - 1;
                state = 1;
                %export = false;
            end
            
       case 1
       
            % The gradient is downing by one column
            if ( i < end_row )
                
                ind_pix = Matrix_next_pixel(i,j);
                %fprintf('Pixel Nro = %d \n',ind_pix)
                time1 = vec_time(pixel+ind_time_start1);
                Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = I_ph;
                Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = I_ph;
                ind_time_start1 = ind_time_start1 + 1;
                
                % --- plot ---%
                y1  = i;
                y2  = y1+1;
                x1  = j;
                x2  = x1+1;
                z([y1 y2],[x1 x2]) = scaleTime*time1;
                surf(X,Y,z)
                hold on
                grid on
                % --- End plot ---%
                
                i = i + 1;
                pixel = pixel + 1;
                I_ph = I_ph - delta_Ich1;
            else
                end_row = end_row - 1;
                state = 2;
                %export = false;
            end
       case 2
           
            % el gradiente esta yendo de derecha a izquierda
            if ( j > start_col)
                
                ind_pix = Matrix_next_pixel(i,j);
                %fprintf('Pixel Nro = %d \n',ind_pix)
                time1 = vec_time(pixel+ind_time_start1);
                Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = I_ph;
                Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = I_ph;
                ind_time_start1 = ind_time_start1 + 1;
                
                % --- plot ---%
                y1  = i;
                y2  = y1+1;
                x1  = j;
                x2  = x1+1;
                z([y1 y2],[x1 x2]) = scaleTime*time1;
                surf(X,Y,z)
                hold on
                grid on
                % --- End plot ---%
                
                j = j - 1;
                pixel = pixel + 1;
                I_ph = I_ph - delta_Ich1;
            else
                start_col = start_col + 1;
                state = 3;
                %export = false;
            end
       case 3
           
           % El gradiente esta subiendo por una columna
           if ( i >= start_row) 
               
               ind_pix = Matrix_next_pixel(i,j);
               time1 = vec_time(pixel+ind_time_start1);
               Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = I_ph;
               Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = I_ph;
               ind_time_start1 = ind_time_start1 + 1;
               % --- plot ---%
               y1  = i;
               y2  = y1+1;
               x1  = j;
               x2  = x1+1;
               z([y1 y2],[x1 x2]) = scaleTime*time1;
               surf(X,Y,z)
               hold on
               grid on
               % --- End plot ---%

               
               i = i - 1;
               pixel = pixel + 1;
               I_ph = I_ph - delta_Ich1;
           else
               i = i + 1;
               j = j + 1;
               start_row = start_row + 1;
               %export = false;
               if pixel+1 == quant_pixel
                   
                   state = 4;
               else
                   state = 0;
               end
               
           end
       case 4
           % Left one pixel only!
           
           ind_pix = Matrix_next_pixel(i,j);
           time1 = vec_time(pixel+ind_time_start1);
           Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = I_ph;
           Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = I_ph;
           ind_time_start1 = ind_time_start1 + 1;
                      
           pixel = pixel + 1;
           %export = true;
           % --- plot ---%
           y1  = i;
           y2  = y1+1;
           x1  = j;
           x2  = x1+1;
           z([y1 y2],[x1 x2]) = scaleTime*time1;
           surf(X,Y,z)
           hold on
           grid on
           % --- End plot ---%
   end
   
end


% Only are fired OFF spikes between T/2 to T

%{

pixel = 0;
state = 0;
start_col = 1;end_Col = N;
start_row = 2;end_row = M;
i = 1;j=1;

while (pixel < quant_pixel)
   
   %z(:,:) = NaN;
   
      
   switch state
       
       case 0
           
            % the gradient go to rigth
            if ( j < end_Col)
                ind_pix = Matrix_next_pixel(i,j);
                time1 = vec_time(pixel+ind_time_start1);
                Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = Ich2(ind_pix);
                Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = Ich2(ind_pix);
                ind_time_start1 = ind_time_start1 + 1;
                % --- plot ---%
                %y1  = i;
                %y2  = y1+1;
                %x1  = j;
                %x2  = x1+1;
                %z([y1 y2],[x1 x2]) = scaleTime*time1;
                %surf(X,Y,z)
                %hold on
                %grid on
                % --- End plot ---%
                j = j + 1;
                pixel = pixel + 1;
                %export = true;
            else
                end_Col = end_Col - 1;
                state = 1;
                %export = false;
            end
            
       case 1
       
            % The gradient is downing by one column
            if ( i < end_row )
                %Array(i,j) = Ich(pixel+1);
                ind_pix = Matrix_next_pixel(i,j);
                time1 = vec_time(pixel+ind_time_start1);
                Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = Ich2(ind_pix);
                Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = Ich2(ind_pix);
                ind_time_start1 = ind_time_start1 + 1;
                
                % --- plot ---%
                %y1  = i;
                %y2  = y1+1;
                %x1  = j;
                %x2  = x1+1;
                %z([y1 y2],[x1 x2]) = scaleTime*time1;
                %surf(X,Y,z)
                %hold on
                %grid on
                % --- End plot ---%
                
                i = i + 1;
                pixel = pixel + 1;
                %export = true;
            else
                end_row = end_row - 1;
                state = 2;
                %export = false;
            end
       case 2
           
            % el gradiente esta yendo de derecha a izquierda
            if ( j > start_col)
                %Array(i,j) = Ich(pixel+1);
                ind_pix = Matrix_next_pixel(i,j);
                time1 = vec_time(pixel+ind_time_start1);
                Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = Ich2(ind_pix);
                Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = Ich2(ind_pix);
                ind_time_start1 = ind_time_start1 + 1;
                
                % --- plot ---%
                %y1  = i;
                %y2  = y1+1;
                %x1  = j;
                %x2  = x1+1;
                %z([y1 y2],[x1 x2]) = scaleTime*time1;
                %surf(X,Y,z)
                %hold on
                %grid on
                % --- End plot ---%
                
                j = j - 1;
                pixel = pixel + 1;
                %export = true;
            else
                start_col = start_col + 1;
                state = 3;
                %export = false;
            end
       case 3
           
           % El gradiente esta subiendo por una columna
           if ( i >= start_row) 
               %Array(i,j) = Ich(pixel+1);
               ind_pix = Matrix_next_pixel(i,j);
               time1 = vec_time(pixel+ind_time_start1);
               Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = Ich2(ind_pix);
               Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = Ich2(ind_pix);
               ind_time_start1 = ind_time_start1 + 1;
               % --- plot ---%
               %y1  = i;
               %y2  = y1+1;
               %x1  = j;
               %x2  = x1+1;
               %z([y1 y2],[x1 x2]) = scaleTime*time1;
               %surf(X,Y,z)
               %hold on
               %grid on
               % --- End plot ---%

               
               i = i - 1;
               pixel = pixel + 1;
               %export = true;
           else
               i = i + 1;
               j = j + 1;
               start_row = start_row + 1;
               if pixel+1 == quant_pixel
                   
                   state = 4;
               else
                   state = 0;
               end
               
           end
       case 4
           % Left one pixel only!
           ind_pix = Matrix_next_pixel(i,j);
           time1 = vec_time(pixel+ind_time_start1);
           Matrix_pixels(ind_time_start1+pixel:len_t,ind_pix) = Ich2(ind_pix);
           Matrix_pixels(ind_time_start1+pixel+1:len_t,ind_pix) = Ich2(ind_pix);
           ind_time_start1 = ind_time_start1 + 1;
                      
           pixel = pixel + 1;
           % --- plot ---%
           %y1  = i;
           %y2  = y1+1;
           %x1  = j;
           %x2  = x1+1;
           %z([y1 y2],[x1 x2]) = scaleTime*time1;
           %surf(X,Y,z)
           %hold on
           %grid on
           % --- End plot ---%
   end
end

%}

cd(PATH_input)


% Interpolation


time_interp = linspace(0,T,len_t*50);

parfor pixel=1:quant_pixel
    
   I_pd=Matrix_pixels(:,pixel);
   I_pd_interp = interp1(vec_time',I_pd,time_interp','linear');
   name_file = strcat(nameSignal,'_',int2str(pixel-1),'.csv');
   dlmwrite(name_file,[time_interp' I_pd_interp],'delimiter',' ','precision',10,'newline','unix'); 
end
matlabpool close

period = T;
fid = fopen('README.txt','wt');
fprintf(fid,' N %d\n M %d\n T %d \n freq %d (Hz) \n Sample %d \n RPM %d \n',N,M,period,1/period,samples,rpm);
fclose(fid);



colorbar;
set(gca,'xtick',X);
set(gca,'ytick',Y);
set(gca,'Ydir','reverse')
xlabel('COLUMNS')
ylabel('ROWS')
zlabel('Time ms')
name_title = 'Spiral';
title(name_title)
xlim([0 N])
ylim([0 M])
saveas(h,nameSignal,'fig')
saveas(h,nameSignal,'png')
cd(curr_path)
toc;