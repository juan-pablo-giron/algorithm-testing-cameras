%% ================================================================ %%
%   
%   Function: It algortihm does the plot of the signals that correspond
%   to the ON/OFF event both to the model as the obtained by simulation.
%   It function is used when the simulation is for one unique pixel.
%   
%   Input: - PATH_OUTPUT_SIMULATION
%          - PATH_INPUT_SIGNAL
%          - Index_ON for the simulated circuit
%          - Index_OFF for the simulated circuit
%          - Time_start
%          - Time_stop
%   Output:- Creates a .Fig and .png graphic with the respective axis la- 
%   bel. The plot will've five subplots, with the following order.
%   ----------------------------------------------
%   subplot(3,2,1)       |    subplot(3,2,2)
%   ON_EVENTS_EXPECTED   |    OFF_EVENTS_EXPECTED
%   ----------------------------------------------
%   subplot(3,2,3)       |    subplot(3,2,4)
%   ON_EVENTS_SIMULATED  |    OFF_EVENTS_SIMULATED
%   ----------------------------------------------
%                   subplot(3,2,4)
%               INPUT SIGNAL (Photo current)
%   ----------------------------------------------
%% ================================================================ %%

time_start  = 1e-3;
time_stop   = 2e-3;


lst_name_signals = 'V_pd,I_pd,Vout_sf,Voff,Von,C_OFF_REQ,C_ON_REQ,C_OFF_ACK,C_ON_ACK,Vrst';
vec_signals = regexp(lst_name_signals,',','split');
len_vector_signals = length(vec_signals);

desired_signal2plot = 'C_ON_REQ';
Index_ON =  f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals);
Index_ON = Index_ON + 1; %The time is included
desired_signal2plot = 'C_OFF_REQ';
Index_OFF =  f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals);
Index_OFF = Index_OFF + 1;
PATH_OUTPUT_SIMULATION = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM1/output_matlab_SIM1/';
PATH_INPUT_SIGNAL = '/home/netware/users/jpgironruiz/Desktop/Documents/Cadence_analysis/Simulation_cameras/SIM1/input_SIM1/';

%% ======================= LOADING THE SIGNALS ===================== %%

% Entry to the directory of the simulation

cd(PATH_OUTPUT_SIMULATION)

% Obtain the name of the output expected and simulated

D = dir(['./', 'Expected*.csv']);
name_signal_expected = D.name;
D = dir(['./', 'output*.csv']);
name_signal_simulated = D.name;

signal_expected  = importdata(name_signal_expected);
signal_simulated = importdata(name_signal_simulated);

cd(PATH_INPUT_SIGNAL)
D = dir(['./', '*.csv']);
name_input_signal = D.name;
input_signal = importdata(name_input_signal);

cd(PATH_OUTPUT_SIMULATION)
% ----> Signals <-----

t   = input_signal(:,1);
Iph = input_signal(:,2);

ON_expected     = signal_expected(:,2);
OFF_expected    = signal_expected(:,3);
time_simulated  = signal_simulated(:,1);
ON_simulated    = signal_simulated(:,Index_ON);
OFF_simulated   = signal_simulated(:,Index_OFF);

% ----> Find the index of the time start/Stop <----

index_time_start_sim = find(time_simulated >= time_start);
index_time_stop_sim  = find(time_simulated >= time_stop);

%% ====================== HERE ARE PLOTTED THE SIGNALS ============== %%

h=figure('Visible','off');

title('Comparasion expected signal and simulated both ON / OFF events')

subplot(321)
stem(t+time_start,ON_expected)
xlabel('Time')
ylabel('ON Events expected')
grid on

subplot(322)
stem(t+time_start,OFF_expected)
xlabel('Time')
ylabel('OFF Events expected')
grid on

subplot(323)
plot(time_simulated(index_time_start_sim:index_time_stop_sim), ...
    ON_simulated(index_time_start_sim:index_time_stop_sim),'r')
xlabel('Time')
ylabel('ON Events simulated')
grid on

subplot(324)
plot(time_simulated(index_time_start_sim:index_time_stop_sim), ...
    OFF_simulated(index_time_start_sim:index_time_stop_sim),'r')
xlabel('Tiempo')
ylabel('OFF Events simulated')
grid on

subplot(3,2,[5,6])

semilogy(t,Iph)
xlabel('Time')
ylabel('Iph')
grid on

saveas(h,'Behaviour.png','png')
saveas(h,'Behaviour.fig','fig')