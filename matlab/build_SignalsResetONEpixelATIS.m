path_input = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIMTEST2/input_SIMTEST2/';
name_file = 'trianguleWave_ATIS.csv';
tic
current_pwd = pwd;
cd (path_input)
data = importdata(name_file);
time = data(:,1);
I_ph = data(:,2);
I = 0;
vdd = 1.8;
samples = 20;
len_time = length(time);
resetSignal = 1.8*ones(1,len_time);
i = 1;
while i<=len_time
   
    index = find(I_ph([i:len_time]) > I,1);
    
    start = i + index - 1;
    stop = start + samples;
    resetSignal(start:stop) = 0;
    I = I_ph(start);
    i = stop + 1;    
    
end

subplot(2,1,1)
plot (time,resetSignal)
subplot(2,1,2)
plot (time,I_ph)


nameSignalOutput = 'Rst_ATIS';
signal(:,1) = time';
signal(:,2) = resetSignal';

cd('/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIMTEST2/input_SIMTEST2')
dlmwrite(strcat(nameSignalOutput,'.csv'),signal,'delimiter',' ','precision',10,'newline','unix');



toc