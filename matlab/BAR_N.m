% It script creates a triangule wave as steps that increases progessive


%         <------- N ------>
%         ^ Pix0 Pix1 .....
%         |   .
%         |     .
%         M       .
%         |         .
%         |           .PixN,M



tic;

clear all;clc;close all;

N = 2; 
M = 2;
Edges = 10;
quant_pixel=N*M;
freq = 200;
T = 1/freq;
curr_path = pwd;
PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';

cd(PATH_input);
nameSignal = strcat('BAR_N',int2str(N),'X',int2str(M),'_',int2str(freq));
name_folder = strcat(nameSignal,'/');
[s,mess1,mess2]=mkdir(name_folder);

% Creando el directorio de la entrada

if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');
cd(curr_path);

closeP = 0;

if N*M > 16
    matlabpool open 8;
    closeP = 1;
end


Imax = 300e-12;
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

% Create copy Edges time 

Matrix_Iph_2 = zeros(Edges*len_t,M);

for i=1:Edges
   
    lim_inf = (i-1)*len_t + 1;
    lim_sup = lim_inf + len_t - 1;
    Matrix_Iph_2(lim_inf:lim_sup,:) = Matrix_Iph;
    
end

t = linspace(0,Edges*T,Edges*len_t);
len_t = length(t);
time_interp = linspace(0,Edges*T,200*len_t);
T2 = Edges*T;

cd(PATH_input)
h = figure(1);
ind_pix = 0;
sigma_noise = 2e-12;
mu_noise = 0;
parfor i=1:M
    vec_Iph = Matrix_Iph_2(:,i);
    I_pd_interp = interp1(t',vec_Iph,time_interp','linear');
    semilogy(time_interp*1e3,I_pd_interp,'Color',[1/i,2/(5*i),3/(4*i)]);
    hold on
    for j=1:N
        name_file = strcat(nameSignal,'_',num2str((i-1)*N+(j-1)),'.csv');
        dlmwrite(name_file,[time_interp' I_pd_interp],'delimiter',' ','precision',10,'newline','unix');
        noise = abs(normrnd(mu_noise,sigma_noise,length(time_interp),1));
        dlmwrite(['noise_',num2str((i-1)*N+(j-1)),'.csv'],[time_interp' noise],'delimiter',' ','precision',10,'newline','unix');
        %ind_pix = ind_pix + 1;
    end
end

saveas(h,nameSignal,'png');
saveas(h,nameSignal,'fig');
xlabel('time ms')
ylabel('I_{pd} (pA)')


fid = fopen('README.txt','wt');
fprintf(fid,' N %d\n M %d\n T %d \n freq %d (Hz)',N,M,T2,freq);
fclose(fid);


if closeP
    matlabpool close;
end

cd(curr_path);

toc;
