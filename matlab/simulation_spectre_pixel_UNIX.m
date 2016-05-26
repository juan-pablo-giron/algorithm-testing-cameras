


%% =====================================================================%%
% It function execute several script written in python which allow
% simulate a netlist using the Spectre simulador, it script return in the 
% same PATH of the netlist the file that correspond to signals sorted
% by the Clumnas ASCII format, that could be read by Matlab. The user can 
% specifiy the signals that want to plot, upon 2 signals at same time.
% The algortihm also create one folder with the name specified by the user
% so, the result can be found in that folder. The results is both in .png 
% as .fig format to an easy reading.
%% =====================================================================%%


function [] = simulation_spectre_pixel_UNIX(name_simulation,nameNetlist_spectre)


%% ==== Here are the desired signals that the user want see ============%%

% Dont include the numbers 
lst_name_signals = 'V_pd,I_pd,Vout_sf,Voff,Von,C_OFF_REQ,C_ON_REQ,C_OFF_ACK,C_ON_ACK,Vrst';
vec_signals = regexp(lst_name_signals,',','split');
len_vector_signals = length(vec_signals);
desired_signal2plot = 'C_ON_REQ';
index_desiredSignal2Plot =  f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals);
X_length = 1;
Y_length = 1;
number_pixel = X_length*Y_length;


%%  =================    GET THE PATH FROM ENV VARIABLES =============%%


PATH_scriptMatlab = getenv('PATH_scriptMatlab')
PATH_script = getenv('PATH_script')
PATH_scriptPython = getenv('PATH_scriptPython')
PATH_netlist_spectre = getenv('PATH_netlist_spectre')
PATH_simulation = getenv('PATH_simulation')
PATH_folder_simulation=getenv('PATH_folder_simulation')
PATH_sim_output_matlab = getenv('PATH_sim_output_matlab')
PATH_folder_input = getenv('PATH_folder_input')
PATH_folder_images = getenv('PATH_folder_images')
PATH_folder_nohup = getenv('PATH_folder_nohup')
nameinput = getenv('nameinput')
name_folder_matlab_output = getenv('name_folder_matlab_output')
name_matlab_output = getenv('name_matlab_output')
name_images = getenv('name_images')
name_folder_nohup = getenv('name_folder_nohup')



%% ==================== generates the signals ========================= %%

eventsPerPeriod = 1000;
I_ph_max = 100e-12;
I_ph_min = 1e-12;
period_Signal = 1e-3;
Nperiods = 4;
finalTime = Nperiods*period_Signal;
delta_t = period_Signal/eventsPerPeriod;
cd(PATH_scriptMatlab)

% Only ON events
%signal_ramp_illuminance_ON_events(PATH_folder_input,PATH_folder_images, ...
%    number_pixel,nameinput,eventsPerPeriod,period_Signal,delta_t,I_ph_max,I_ph_min)
%cd(PATH_scriptMatlab)

% OFF Events



% Triangule (ON/OFF) Events
signal_triangule(PATH_folder_input,PATH_folder_images, ...
    number_pixel,nameinput,eventsPerPeriod,period_Signal,delta_t,I_ph_max,I_ph_min)

cd(PATH_scriptMatlab)

%% ==================== CALCULATE THE EXPECTED BEHAVIOUR  ============= %%

% DVS_PIXEL

DVS_model_fn(PATH_folder_input,PATH_sim_output_matlab,name_simulation)


%% ===================== CALL TO SCRIPTS  ==============================%%

nameNetlist_output = strcat('netlist_',name_simulation);
ext_input = '.csv';


% Here is changed the netlist by intuitives names 
cd(PATH_scriptPython)

command = ['python' ' ' 'setting_input_netlist_UNIX.py' ' ' ...
   PATH_netlist_spectre ' ' PATH_folder_simulation ' ' PATH_folder_input ...
   ' ' nameNetlist_spectre ' ' nameNetlist_output ' '...
   nameinput ' ' ext_input ' ' int2str(number_pixel) ' ' ...
   num2str(period_Signal) ' ' num2str(finalTime) ' ' num2str(delta_t) ...
   ' ' lst_name_signals];


system(command)

% here is executed the spectre simulator

cd(PATH_scriptPython)

command = ['python' ' ' 'executing_spectre_command_UNIX.py' ...
    ' ' PATH_folder_simulation ' ' nameNetlist_output ' ' ...
    PATH_sim_output_matlab ' ' name_matlab_output];

status=system(command)

% End Simulation

cd(PATH_scriptMatlab)

%plot the signals
desired_signal2plot = 'C_ON_REQ';
Index_ON =  f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals);
Index_ON = Index_ON + 1;

desired_signal2plot = 'C_OFF_REQ';
Index_OFF = f_findIndexInCell(desired_signal2plot,vec_signals,len_vector_signals);
Index_OFF = Index_OFF + 1;

time_start = 1e-3;
time_stop = 2e-3;

plot_signal_unique_pixel(PATH_sim_output_matlab,...
PATH_folder_input,Index_ON,Index_OFF,time_start,time_stop)


% Move the file output_matlab_NAMESIMULATION to the respective folder
cd(PATH_scriptMatlab)
name_out_matlab = strcat('output_matlab_',name_simulation,'.out');
command = ['mv' ' ' name_out_matlab ' ' PATH_folder_nohup];
system(command)

display('END_SIMULATION')

exit
