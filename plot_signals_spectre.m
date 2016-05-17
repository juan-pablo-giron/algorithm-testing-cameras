
% =======================================================================%
% IT FUNCTION DOES THE PLOTTING OF THE SIGNALS SIMULATED ON SPECTRE 
% MODIFIED BY: JUAN PABLO GIRON RUIZ SUPPORTED BY CAPES 2016 
% COPPE/UFRJ/RJ-BRAZIL
% Part of this code was taken in https://drive.google.com/file/d/0B3xdy327Fj8GTklNRTFyQmN4NVE/view
% =======================================================================%

function y=plot2_signals_spectre(x,y1,x,y2,nameY1,nameY2,title_fig,folder_output)

PATH = '/home/netware/users/jpgironruiz/Downloads/Matlab_plotting_workshop/';
cd(PATH)
clf; close all;clear
fig = figure('visible','off'); % don't show the figure

[AX,H1,H2] = plotyy(x,y1,x,y2); 

set(get(AX(1),'Ylabel'),'String', nameY1,'Fontsize',11) 
set(get(AX(2),'Ylabel'),'String', nameY2,'Fontsize',11) 

min_y1 = min(y1);
max_y1 = max(y1);
min_y2 = min(y2);
max_y2 = max(y2);

%set(AX(1),'Xlim',[-2 30])
%set(AX(2),'Xlim',[-2 30])
set(AX(1),'Ylim',[min_y1 max_y1])
set(AX(2),'Ylim',[min_y2 max_y2])

xlabel('Time (\sec)','Fontsize',11);title(title_fig,'Fontsize',11) 

set(H1,'LineStyle','-','lineWidth', 2, 'color', 'b') 
set(H2,'LineStyle','-' ,'lineWidth', 2, 'color', 'r')

set(AX(1),'ycolor','b','lineWidth', 2) % y1 axis color
set(AX(2),'ycolor','r','lineWidth', 2) % y2 axis color

% Get exactly what you see on your screen
figure_size = get(gcf, 'position')
set(gcf,'PaperPosition',figure_size/100); 
print(gcf,'-dpng','-r100', ['./Double_Y_axes2.png']);
saveas(1,'figureTEST2.eps')


