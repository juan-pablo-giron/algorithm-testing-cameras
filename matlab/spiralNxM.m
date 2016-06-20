%function []=spiralNxM(N,M,freq)

%         <------- N ------>
%         ^ Pix0 Pix1 .....
%         |   .
%         |     .
%         M       .
%         |         .
%         |           .PixN,M

tic;

N = 2; 
M = 2;

curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
cd(PATH_input)
%dlmwrite('test.csv',[20 30],'delimiter',' ','-append','precision',10,'newline','unix');
cd(curr_path)

pixel = 0;
start_col = 0;
start_row = 1;
I0 = 50e-12;
Ich = 100e-12;
freq = 200; 
state = 0;
quant_pixel = N*M;

while (pixel < quant_pixel)
    
   
    
    
end




toc;