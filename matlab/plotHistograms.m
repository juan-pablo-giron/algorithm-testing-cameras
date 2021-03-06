% ============================================================= 
% Este script dibuja los histogramas para la sensibilidad de con
% traste.
% Entradas : Matrix_pix_edges_ON -> vector columna de N*M posiciones repre-
%            senta la media de pulsos por el canal ON.
%            Matrix_pix_edges_OFF -> vector columna de N*M posiciones repre-
%            senta la media de pulsos por el canal OFF.
%           'string' para decir si los histogramas es del modelo
%            o simulado.
%            VDIFF -> es la diferencia entre abs(Vref-Vdon)
% =============================================================

function [] = plotHistograms(Matrix_pix_edges_ON,Matrix_pix_edges_OFF, ...
                    string,VDIFF)


PATH_folder_images = getenv('PATH_folder_images');
cd(PATH_folder_images)


%% ======================   Histograms    ============================= %%

Ibright = 100e-12;
Idark  = 20e-12;
SensivityStimulus = log(Ibright/Idark);

%% ------------------------ ON CHANNEL  -------------------------------%%

mu = mean(Matrix_pix_edges_ON);

figure('Visible','on','units','normalized')
valid_indx = Matrix_pix_edges_ON > 0;
hist(Matrix_pix_edges_ON(valid_indx));
set(gca,'xscale','log','xlim',[1 40]);
xlabel('#events/pixel/edge')
ylabel('# pixels')
title(['\mu=',num2str(mu)])
legend(['VDIFF ON = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_HIST1_ON_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_HIST1_ON_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_HIST1_ON_',num2str(VDIFF)],'fig');

% HIST 2

%close all;
figure('Visible','on','units','normalized')
Matrix_pix_edges_ON2 = 100*SensivityStimulus./Matrix_pix_edges_ON(valid_indx);
mu = mean(Matrix_pix_edges_ON2);
sigma = std(Matrix_pix_edges_ON2);
hist(Matrix_pix_edges_ON2);
set(gca,'xlim',[1 40]);
xlabel('%{\theta_{ev}}^+')
ylabel('# pixels')
title(['\mu = ',num2str(mu),' ','\sigma = ',num2str(sigma)])
legend(['VDIFF ON = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_CS_ON_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_CS_ON_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_CS_ON_',num2str(VDIFF)],'fig');


%%  ---------------------  OFF CHANNEL ---------------------------- %
%close all;
figure('Visible','on','units','normalized')
mu = mean(Matrix_pix_edges_OFF);
valid_indx = Matrix_pix_edges_OFF > 0;
hist(Matrix_pix_edges_OFF(valid_indx));
set(gca,'xscale','log','xlim',[1 40]);
xlabel('#events/pixel/edge')
ylabel('# pixels')
title(['\mu=',num2str(mu)])
legend(['VDIFF OFF = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_HIST1_OFF_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_HIST1_OFF_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_HIST1_OFF_',num2str(VDIFF)],'fig');

% HIST 2

%close all;
figure('Visible','on','units','normalized')
Matrix_pix_edges_OFF2 = 100*SensivityStimulus./Matrix_pix_edges_OFF(valid_indx);
mu = mean(Matrix_pix_edges_OFF2);
sigma = std(Matrix_pix_edges_OFF2);
hist(Matrix_pix_edges_OFF2);
set(gca,'xlim',[1 40]);
xlabel('% {\theta_{ev}}^-')
ylabel('# pixels')
title(['\mu = ',num2str(mu),' ','\sigma = ',num2str(sigma)])
legend(['VDIFF OFF = ',num2str(VDIFF)])
grid on

% SAVE FIGURES
set(gcf,'PaperPositionMode','auto')
print('-depsc2', [string,'_CS_OFF_',num2str(VDIFF),'.eps'])
print('-dpng', [string,'_CS_OFF_',num2str(VDIFF),'.png'])
saveas(gca,[string,'_CS_OFF_',num2str(VDIFF)],'fig');
