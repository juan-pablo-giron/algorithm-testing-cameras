
data = importdata('/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM3/input_SIM3/input_SIM30.csv');
time = data(:,1);
I_pd = -1*data(:,2);

len_time = length(time);
%I_pd = -100e-12*ones(1,len_time);
V = zeros(1,len_time);
V(1) = 1.8; % Condicion inicial del capacitor
C = 30e-15;
for i=1:len_time-1
   
    V(i+1) = 1/C*I_pd(i)*(time(i+1)-time(i))+V(i);
    
end
hold on
plot(time,V,'r')