% Esta funcion hace el plot bar para determinar la cantidad de eventos 
% realizados por el sensor DVS
% Recibe como parametros los eventos ON y OFF, Idark and Ibrigth.
% No retorna nada, sino que graba una imagen con la cantidad de eventos
% por variación temporal.

% Ecuaciones usadas para el contraste temporal ON
% TC_ON = abs(log(Ibright/Idark))
% TC_OFF = abs(log(Idark/Ibright))

function []=plot_bar_events_DVS_Model(M_ON_Events,M_OFF_Events, ...
    Idark,Ibright,string)

curr_pwd = pwd;

PATH_folder_images = getenv('PATH_folder_images'); 

V_p = str2double(getenv('Vdon'));
V_n = str2double(getenv('Vdoff'));
Vref = 1.5;

% Paso 1. Contruir un vector 

TC_ON = abs(log(linspace(Idark,Ibright,100)/Idark));
TC_OFF = abs(log(linspace(Idark,Ibright,100)/Ibright));

% Paso 2. Construir 

vec_TC_ON = zeros(100,1);
vec_TC_OFF = zeros(100,1);

len_M_ON = length(M_ON_Events(:,1));
len_M_OFF = length(M_OFF_Events(:,1));

% ON Channel

for i=1:len_M_ON

    pixel = M_ON_Events(i,1);
    Iph = M_ON_Events(i,2);
    TC = abs(log(Iph/Idark));
    index = find(TC_ON >= TC,1);
    vec_TC_ON(index) = vec_TC_ON(index) + 1;
        
end

% OFF Channel

for i=1:len_M_OFF

    pixel = M_OFF_Events(i,1);
    Iph = M_OFF_Events(i,2);
    TC = abs(log(Iph/Ibright));
    index = find(TC_OFF <= TC,1);
    vec_TC_OFF(index) = vec_TC_OFF(index) + 1;
        
end

% Paso 3. Plot

cd(PATH_folder_images)

figure('Visible','off');
bar(vec_TC_ON,'FaceColor', [0.7 0.7 0.7], 'EdgeColor', [0.7 0.7 0.7])
%hist(vec_TC_ON,10)%'FaceColor', [0.7 0.7 0.7], 'EdgeColor', [0.7 0.7 0.7])
hold on
bar(vec_TC_OFF,'FaceColor', 'k', 'EdgeColor', 'k')
%hist(vec_TC_OFF,10);%'FaceColor', 'k', 'EdgeColor', 'k')
legend(['VdiffON=',num2str(abs(V_p-Vref)),'V'],['VdiffOFF=',num2str(abs(V_n-Vref)),'V'])
xlabel('\theta_{ev}(%)')
ylabel('#pixels')
xlim([0 100])
title(['Total events = ',num2str(sum(vec_TC_OFF)+sum(vec_TC_ON))])

set(gcf,'PaperPositionMode','auto')
print('-depsc2', ['BAR_TC_',string,'.eps'])
print('-dpng', ['BAR_TC_',string,'.png'])
saveas(gcf,['BAR_TC_',string],'fig')

cd(curr_pwd)



