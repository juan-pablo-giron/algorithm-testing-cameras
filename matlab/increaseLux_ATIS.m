% Esta funci�n proporciona el conjunto de datos necesarios para 
% simular una c�mara ATIS.

tic;

clear all;clc;close all;

curr_path = pwd;

N =2; 
M =2;
freq = 150;
frames = 255;
Max_Subplots = 20;
rpm = freq*60;
T_Rst = 200e-6;

PATH_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Inputs/';
%PATH_input = '/sdcard/documents/MSc/Cadence_analysis/Inputs/';
cd(PATH_input);
nameSignal = strcat('illuminationAtis',int2str(N),'X',int2str(M),'_',int2str(freq),'_',int2str(frames));
name_folder = strcat(nameSignal,'/');

%% Creating the directory

[s,mess1,mess2]=mkdir(name_folder);
if (~strcmp(mess1,''))
   
    rmdir(name_folder,'s');
    mkdir(name_folder);
end
PATH_input = strcat(PATH_input,nameSignal,'/');

%% parameters and declarations of variables

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
Matrix_grayscale = zeros(N/2,1);
Color_max = 255;
Color_min = 0;
deltaColor = (Color_max - Color_min)/(N/2*frames);
deltaIpd = (Imax - Imin)/(N/2*frames);
Color = deltaColor;
Ipd = Imin;
struct_limsX = {[]};
struct_limsY = {[]};
cd(PATH_input)

%% colocar los nombres en los ejes de manera correcta

for x=0:N-1
    struct_limsX{x+1} = num2str(x);
end
struct_limsY = struct_limsX;

    
%% Creating the frames    

max_subfig = 16;
ind_subfig = 1;
ind_nameFig = 1;
% Garantizar que siempre se vean un maximo de subplot
% si es hay demasiados frames, entonces se subdividen
% las figuras. Dando un mejor visual.

frames_maxsubfig = ceil((frames+1)/max_subfig);
elements_fig = ceil((frames+1)/frames_maxsubfig);
max_col = ceil(sqrt(elements_fig));
max_rows = max_col;    


h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
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
           Matrix_grayscale(ind) = Color;
           Color = Color + deltaColor;
           Ipd = Ipd + deltaIpd;
        end
    else
        
        Matrix_tmpColor(:,:) = 0;
        Matrix_tmpIpd(:,:) = Inot;
        Matrix_grayscale(:) = 0;
        Ipd = Ipd + deltaIpd;
    end
 %% Painting the frame  
    %h = figure('Visible','on');
    
    subplot(max_rows,max_col,ind_subfig)
    
    c_min = uint8(min(Matrix_grayscale));
    c_max = uint8(max(Matrix_grayscale));
    CMAP = uint8(unique(Matrix_grayscale));
   
    imagesc(uint8(Matrix_tmpColor),[0 255])
    colormap(gray)
    if c_min ~= c_max
        colorbar('Ylim',[c_min c_max],'YTick',CMAP);
    else
        colorbar('YTick',CMAP);
    
    end
    %colorbar('YTick',uint8(255*Matrix_grayscale'),'YTickLabels',{'Cold','Cool','Neutral','Warm'})
    set(gca,'XTick',[1:N])
    set(gca,'YTick',[1:M])
    set(gca,'YTickLabel',struct_limsY)
    set(gca,'XTickLabel',struct_limsX)
    grid off;
    xlabel(['Columns',' ','(',char(fr+1+96),') '])
    ylabel('Rows')
    
    lim_inf = (samples)*fr+1;
    lim_sup = lim_inf + (samples-1);
    title(strcat('Time = [ ',num2str(vec_time(lim_inf)*1e3),' - ', ...
        num2str(vec_time(lim_sup)*1e3),'] ms',' Frame = ',num2str(fr)))
    
    % Setting the lines vertical and horizontal at the image
    
    vc_lineX = linspace(0,N+1,200);
    vc_lineY = ones(1,length(vc_lineX))/2;
    
    for x=1:N
       
       for y=1:M
           
           hold on;
           plot(vc_lineX,vc_lineY+y,'--','Color',[0.7 0.7 0.7]);
           
       end
       hold on
       line([x+0.5 x+0.5],[0 M+1],'LineStyle','--','Color',[0.7 0.7 0.7])
    end
   
    if (ind_subfig == elements_fig)
       
       ind_subfig = 1;
       set(gcf,'PaperPositionMode','auto')
       print('-depsc2', ['Input_ATIS',num2str(ind_nameFig),'.eps'])
       print('-dpng', ['Input_ATIS',num2str(ind_nameFig),'.png'])
       close all;
       
       if fr ~= frames
           %para no crear una figura en blanco sin nada
           h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);
           ind_nameFig = ind_nameFig + 1;
           cont_plot = 1; % Avisa si es necesario grabar la ultima grafica
       else
           cont_plot = 0;
           
       end
   else
       ind_subfig = ind_subfig + 1;
       
   end
    
    
    %% Colocando los valores de la matriz dentro del vector unidimensional
    % de pixeles
    
    for ind_x=1:M
        
        for ind_y=1:N
                              
            Matrix_Color(ind_y + (ind_x-1)*M,lim_inf:lim_sup) = Matrix_tmpColor(ind_x,ind_y);
            Matrix_Ipd(ind_y + (ind_x-1)*M,lim_inf:lim_sup) = Matrix_tmpIpd(ind_x,ind_y);
        end
    end
    Matrix_tmpColor(:,:) = 0;
    
end


if cont_plot
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2', ['Input_ATIS',num2str(ind_nameFig),'.eps'])
    print('-dpng', ['Input_ATIS',num2str(ind_nameFig),'.png'])
end

%% Interporlation


time_interp = linspace(0,T,200*len_t);

for i=1:N*M
	
	I_pd_interp = interp1(vec_time,Matrix_Ipd(i,:),time_interp,'linear');
	name_file=strcat(nameSignal,'_',num2str(i-1),'.csv');
	dlmwrite(name_file,[time_interp' I_pd_interp'],'delimiter',' ','precision',10,'newline','unix');
	plot(time_interp,I_pd_interp)
    hold on;
end

% Writing the README FILE

fid = fopen('README.txt','wt');
fprintf(fid,' N %d\n M %d\n T %d \n freq %d (Hz) \n Frames %d \n Period_total %d ',N,M,T,freq,frames,T+T_Rst);
fclose(fid);

toc

cd(curr_path);
