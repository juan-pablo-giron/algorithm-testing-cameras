
% Esta funcion hace el plot para la respuesta de un ATIS
% recibe como entrada una matrix de NX3 donde las cols son
% [time NroPixel Colour]

function [] = plot2dATIS(Matrix_time_pix_colour,string)

N = str2num(getenv('N')); 
M = str2num(getenv('M')); 
PATH_folder_images = getenv('PATH_folder_images'); 

Matrix2print = sortrows(Matrix_time_pix_colour,1);

% Building the frames to plotting

[r c] = size(Matrix2print);

len_Matrix2print = r;
Struct_Frames = {[]};
vec_time_pix_colour_tmp = N*M*ones(1,3);
ind_struct = 1;
ind_Matrix_tmp = 1;
struct_lims = {[]};
for x=0:N-1
    
    struct_lims{x+1} = num2str(x);
    
end

for i=1:len_Matrix2print
    
    time    = Matrix2print(i,1);
    pixel   = Matrix2print(i,2);
    colour  = Matrix2print(i,3);
    if isempty(find(vec_time_pix_colour_tmp(:,2) == pixel,1))
        vec_time_pix_colour_tmp(ind_Matrix_tmp,1) = time;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,2) = pixel;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,3) = colour; 
        ind_Matrix_tmp = ind_Matrix_tmp + 1;
    else
        Struct_Frames{ind_struct} = vec_time_pix_colour_tmp;
        vec_time_pix_colour_tmp = N*M*ones(1,3);
        ind_Matrix_tmp = 1;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,1) = time;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,2) = pixel;
        vec_time_pix_colour_tmp(ind_Matrix_tmp,3) = colour;
        ind_struct = ind_struct + 1;
        ind_Matrix_tmp = ind_Matrix_tmp + 1;
    end
    
    if i == len_Matrix2print
        Struct_Frames{ind_struct} = vec_time_pix_colour_tmp;
    end
end

% Painting

max_subfig = 16;
ind_subfig = 1;
ind_nameFig = 1;
% Garantizar que siempre se vean un maximo de subplot
% si hay demasiados frames, entonces se subdividen
% las figuras. Dando un mejor visual.

frames_maxsubfig = ceil(length(Struct_Frames)/max_subfig);
elements_fig = ceil(length(Struct_Frames)/frames_maxsubfig);
max_col = ceil(sqrt(elements_fig));
max_rows = max_col;    


h=figure('Visible','off','units','normalized','outerposition',[0 0 1 1]);

for i=1:length(Struct_Frames)
   vec_time_pix_colour_tmp = Struct_Frames{i};
   len_vec = length(vec_time_pix_colour_tmp(:,1));
   Matrix_paint = zeros(M,N);
   Matrix_paint(:,:) = NaN;
   for j=1:len_vec
      pixel = vec_time_pix_colour_tmp(j,2);
      colour = vec_time_pix_colour_tmp(j,3);
      indx = fix((pixel)/M)+1;indy = rem(pixel,N)+1;
      Matrix_paint(indx,indy) = colour; 
   end
  
   c_min = uint8(min(vec_time_pix_colour_tmp(:,3)));
   c_max = uint8(max(vec_time_pix_colour_tmp(:,3)));
   CMAP = uint8(unique(vec_time_pix_colour_tmp(:,3)));
   
   subplot(max_rows,max_col,ind_subfig)
      
   imagesc(uint8(Matrix_paint),[0 255])
   colormap(gray)
   
   if c_min ~= c_max
        if length(CMAP) >10
            ind_CMAP = floor(linspace(1,length(CMAP),10));
            colorbar('Ylim',[c_min c_max],'YTick',CMAP(ind_CMAP));
        else
            colorbar('Ylim',[c_min c_max],'YTick',CMAP);
        end
    else
        colorbar('YTick',CMAP);
    
    end
   
   % Find the NaN value to Mark it.
   [rows columns] = find(isnan(Matrix_paint));
   text(columns,rows,'\color{white}NE','HorizontalAlignment','center', ...
       'FontSize',10)
   
   %Creating the title
   title(strcat('Time = [ ',num2str(min(vec_time_pix_colour_tmp(:,1))*1e3), ...
       ' - ', num2str(max(vec_time_pix_colour_tmp(:,1))*1e3),'] ms'))
   
   % Creating lines to marking 
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
    
   % Changing the labels axis
   xlabel(['Columns',' ','(',char(i+96),') '])
   ylabel('Rows')
   set(gca,'XTick',[1:N])
   set(gca,'YTick',[1:M])
   set(gca,'XTickLabel',struct_lims)
   set(gca,'YTickLabel',struct_lims)
   
   if (ind_subfig == elements_fig)
       
       ind_subfig = 1;
       cd(PATH_folder_images)
       set(gcf,'PaperPositionMode','auto')
       print('-depsc2', ['Output_',string,'_ATIS',num2str(ind_nameFig),'.eps'])
       print('-dpng', ['Output_',string,'_ATIS',num2str(ind_nameFig),'.png'])
       saveas(gcf,['Output_',string,'_ATIS',num2str(ind_nameFig)],'fig');
       saveas(gcf,['Output_',string,'_ATIS',num2str(ind_nameFig)],'svg');
       close all;
       
       if i ~= length(Struct_Frames)
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
   
   
end

if cont_plot

    cd(PATH_folder_images)
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2', ['Output_',string,'_ATIS',num2str(ind_nameFig),'.eps'])
    print('-dpng', ['Output_',string,'_ATIS',num2str(ind_nameFig),'.png'])
    saveas(gcf,['Output_',string,'_ATIS',num2str(ind_nameFig)],'fig');
    saveas(gcf,['Output_',string,'_ATIS',num2str(ind_nameFig)],'svg');
end