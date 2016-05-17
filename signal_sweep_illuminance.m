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
function y = signal_sweep_illuminance(quant_pixels,nameSignalOutput, ...
                eventsPerPeriod,period_Signal,factor_current)

%eventsPerPeriod = 1000;
%factor_current = 100e-12;
%period_Signal = 1e-3;
%quant_pixels = 1;
%nameSignalOutput = 'input';


%% Create signal
delta_t = period_Signal/eventsPerPeriod;
t  = 0:delta_t:period_Signal-delta_t;
i  = 0:length(t)-1;
current = factor_current*i/eventsPerPeriod;
tmp = zeros(length(t),2);
tmp(:,1) = t';
tmp(:,2) = current';

%% Create the output folder

nameFolder = strcat(nameSignalOutput);
[s,mess,messid]=mkdir(nameFolder);
if strcmp(mess,'')
    fprintf('Folder %s created with succesful \n',nameFolder)
else
    fprintf('Deleting the folder %s \n',nameFolder)
    rmdir(nameFolder,'s')
    [s,mess,messid]=mkdir(nameFolder);
    fprintf('Folder %s created with succesful \n',nameFolder)
end
cd(nameFolder)

%% Create the same numbers of signals than pixels


for input=0:quant_pixels-1

    
    dlmwrite(strcat(nameSignalOutput,int2str(input),'.csv'),tmp, ...
        'delimiter',' ','precision',10,'newline','unix');
    
end

%% Create the images to build the video

%frsize = [100 100]; % size of the pixel
%for i = 0:eventsPerPeriod-1
    
%    fr = 255*i*ones(frsize)/eventsPerPeriod;
    %fr(i+1) = uint8(255*i*ones(frsize)/eventsPerPeriod);
    
%    imwrite(uint8(fr),[strcat('frame',nameSignalOutput) num2str(i) '.png'])

    %imshow(uint8(fr));
    %title(['frame: ' num2str(i)])
    %pause(10*delta_t)
%    end

%% Return to the main directory
cd('..')
        