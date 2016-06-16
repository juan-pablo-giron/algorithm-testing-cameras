
data = importdata('/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIMTEST2/input_SIMTEST2/input_SIMTEST20.csv');
time = data(:,1);
I_pd = data(:,2);

len_time = length(time);
%I_pd = -100e-12*ones(1,len_time);
Vcap = zeros(1,len_time);
V = 1.8; % Condicion inicial del capacitor
C = 30e-15;
for i=1:len_time-1
    
    Vcap(i) = V;
    V = V - I_pd(i)*(time(i+1)-time(i))/C;
    
    
end

plot(time,Vcap,'r')
grid on
axis([0 time(len_time) 0.1 1.7 ])
Time_high = find(V<=1.7,1)
Time_low = find(V<=0.1,1)

time_ = (time(Time_low)-time(Time_high))/1e-3

TENER PRESENTE EL RESET PARA EL CALCULO DE LA TENSION