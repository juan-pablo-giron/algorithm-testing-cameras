close all
signals_simulation = importdata('Test_output.csv');
time = signals_simulation(:,1);
C_REQ_ACK = signals_simulation(:,9);
Voutsf = log(signals_simulation(:,3));
figure
subplot(2,1,1)
plot(time,C_REQ_ACK);
subplot(2,1,2)
plot(time,Voutsf)
