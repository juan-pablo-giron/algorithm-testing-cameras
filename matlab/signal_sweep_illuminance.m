%% ================================================================ %%
%  It code generates the signals that make a sweep in intensity of 
%  illumination. It needs be especified bothe the quantity of pixeles desired
%  as the name of the signal, the events per unit of T and T (period of the signal)
% and the factor current. 
%  it return the same quantity of signals with a name plus the number of 
%  the pixels specifying (time vs current). Starting in zero.
%  The format is by default .csv, and one folder with the pics of the signals.
%  Written by: Juan Pablo Giron Ruiz Supported by CAPES 2016.
%%% ================================================================ %%

%%
function y = signal_sweep_illuminance(PATH_folder_input,PATH_folder_images,quant_pixels,nameSignalOutput,eventsPerPeriod,period_Signal,factor_current)

cd(PATH_folder_input)
%% Create signal
delta_t = period_Signal/eventsPerPeriod;
t  = 0:delta_t:period_Signal-delta_t;
i  = 0:length(t)-1;
current = factor_current*i/eventsPerPeriod;
tmp = zeros(length(t),2);
tmp(:,1) = t';
tmp(:,2) = current';


%% Create the same numbers of signals than pixels


for input=0:quant_pixels-1

    
    dlmwrite(strcat(nameSignalOutput,int2str(input),'.csv'),tmp, ...
        'delimiter',' ','precision',10,'newline','unix');
    
end

%% Create the images to build the video


cd(PATH_folder_images)

%frsize = [100 100]; % size of the pixel
%for i = 0:eventsPerPeriod-1
    
%    fr = 255*i*ones(frsize)/eventsPerPeriod;
    %fr(i+1) = uint8(255*i*ones(frsize)/eventsPerPeriod);
    
%    imwrite(uint8(fr),[strcat('frame',nameSignalOutput) num2str(i) '.png'])

    %imshow(uint8(fr));
    %title(['frame: ' num2str(i)])
    %pause(10*delta_t)
%end


        