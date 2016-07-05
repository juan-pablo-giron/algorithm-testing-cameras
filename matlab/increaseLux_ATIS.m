% Esta funci�n proporciona el conjunto de datos necesarios para 
% simular una c�mara ATIS.

tic;

clear all;clc;close all;

curr_path = pwd;

N = 8; 
M = 8;
freq = 150;
frames = 8;
rpm = freq*60;
T_Rst = 200e-6;

PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
%PATH_input = '/sdcard/documents/MSc/Cadence_analysis/Inputs/';
cd(PATH_input);
nameSignal = strcat('illuminationAtis',int2str(N),'X',int2str(M),'_',int2str(freq));
name_folder = strcat(nameSignal,'/');

%% Creating the directory

[s,mess1,mess2]=mkdir(name_folder);
if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');

Imax= 1e-9;
Imin= 20e-12;
Inot = 1e-12;
T = 1/freq;
samples = 2;
vec_time = linspace(0,T,(frames+1)*samples);
len_t=length(vec_time);
Matrix_Color = zeros(M*N,len_t);
Matrix_Ipd = zeros(M*N,len_t);
Matrix_tmpColor = zeros(M,N);
Matrix_tmpIpd = zeros(M,N);
Color_max = 255;
Color_min = 0;
deltaColor = (Color_max - Color_min)/(N/2*frames);
deltaIpd = (Imax - Imin)/(N/2*frames);
Color = deltaColor;
Ipd = Imin;
cd(PATH_input)

for fr=0:frames

    Rini = M/2;Rend = Rini + 1;
    Cini = N/2;Cend = Cini + 1;
    
    if ( fr ~= 0 )
    
        for ind=1:N/2
           Matrix_tmpColor(Rini,[Cini:Cend]) = Color;       
           Matrix_tmpColor([Rini:Rend],Cend) = Color;
           Matrix_tmpColor(Rend,[Cini:Cend]) = Color;
           Matrix_tmpColor([Rini:Rend],Cini) = Color;
           
           Matrix_tmpIpd(Rini,[Cini:Cend]) = Ipd;       
           Matrix_tmpIpd([Rini:Rend],Cend) = Ipd;
           Matrix_tmpIpd(Rend,[Cini:Cend]) = Ipd;
           Matrix_tmpIpd([Rini:Rend],Cini) = Ipd;
           Rini = Rini - 1 ; Rend = Rend + 1;
           Cini = Cini - 1 ; Cend = Cend + 1;
           Color = Color + deltaColor;
           Ipd = Ipd + deltaIpd;
        end
    else
        
        Matrix_tmpColor(:,:) = 0;
        Matrix_tmpIpd(:,:) = Inot;
    end
    %Matrix_tmp
    %h = figure('Visible','off');
    %imwrite(uint8(Matrix_tmp),strcat('frame_',num2str(fr),'.png'));
    %colormap('gray')
    %colorbar
    %grid on;
    %xlabel('Columns')
    %ylabel('Rows')
    %set(gca,'xtick',[0:N]);
    %set(gca,'ytick',[0:M]);
    %title(strcat('Time = ',num2str(vec_time(fr+1))))
    %saveas(gca,strcat('Frame_',num2str(fr)),'png')
    
    % Colocando los valores de la matriz dentro del vector unidimensional
    % de pixeles
    
    for ind_x=1:M
        
        for ind_y=1:N
            
            lim_inf = (samples)*fr+1;
            lim_sup = lim_inf + (samples-1);
            
            Matrix_Color(ind_y + (ind_x-1)*M,lim_inf:lim_sup) = Matrix_tmpColor(ind_x,ind_y);
            Matrix_Ipd(ind_y + (ind_x-1)*M,lim_inf:lim_sup) = Matrix_tmpIpd(ind_x,ind_y);
        end
    end
    Matrix_tmpColor(:,:) = 0;
    
end

%% Interporlation

time_interp = linspace(0,T,200*len_t);

for i=1:N*M
	
	I_pd_interp = interp1(vec_time,Matrix_Ipd(i,:),time_interp,'linear');
	name_file=strcat(nameSignal,'_',num2str(i-1),'.csv');
	dlmwrite(name_file,[time_interp' I_pd_interp'],'delimiter',' ','precision',10,'newline','unix');
	%plot(time_interp,I_pd_interp)
    %hold on;
end

%% Writing the README FILE

fid = fopen('README.txt','wt');
fprintf(fid,' N %d\n M %d\n T %d \n freq %d (Hz) \n Period_total %d',N,M,T,freq,T+T_Rst);
fclose(fid);

cd(curr_path);
