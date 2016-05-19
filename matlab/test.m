function [] = test(param1,param2)


c =strcat(param1,param2);
fileID = fopen('exp.txt','w');
fprintf(fileID,'%s',c);
fclose(fileID);

exit;