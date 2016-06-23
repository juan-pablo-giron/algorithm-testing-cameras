function []=interp_InputSignal(PATH_input,nameSignal,quant_pixel,t_start,t_stop,len_t)
curr_pwd = pwd;
cd(PATH_input)
for pixel=0:quant_pixel-1
	name_file = strcat(nameSignal,'_',int2str(pixel),'.csv');
	data=importdata(name_file);
	time=data(:,1);
	I_pd=data(:,2);
	time_interp = t_start:1/(100*len_t):t_stop;
	I_pd_interp = interp1(time,I_pd,time_interp,"linear");
	F=fopen(name_file);
	dlmwrite(F,[time_interp' I_pd_interp'],'delimiter',' ','precision',10,'newline','unix');
	fclose(F);
end
