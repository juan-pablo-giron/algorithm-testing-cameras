
% To plot several graphics



clear all;clc;close all;

curr_pwd = pwd;
tic;

PATH_sim_output_matlab = getenv('PATH_sim_output_matlab');
name_simulation = getenv('name_simulation');

cd(PATH_sim_output_matlab)

data = importdata(strcat('data_',name_simulation,'.csv'));

fileID = fopen('header.txt');
C = textscan(fileID,'%s','Delimiter',',');
g.signal = cellstr(C{:});
len_signals = length(g.signal);
fclose(fileID);

toc
cd(curr_pwd)