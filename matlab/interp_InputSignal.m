function []=interp_InputSignal(PATH_input,nameSignal,quant_pixel,len_t,samples)
curr_pwd = pwd;
cd(PATH_input)
for pixel=0:quant_pixel-1
	name_file = strcat(nameSignal,'_',int2str(pixel),'.csv');
	data=importdata(name_file);
	time=data(:,1);
	t_start=time(1);
	t_stop=time(length(time));
	I_pd=data(:,2);
	time_interp = t_start:t_stop/(100*len_t*samples):t_stop;
	I_pd_interp = interp1(time,I_pd,time_interp,"linear");
	F=fopen(name_file,'w');
	dlmwrite(F,[time_interp' I_pd_interp'],'delimiter',' ','precision',10,'newline','unix');
	fclose(F);
end
