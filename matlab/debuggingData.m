
% Este script ayuda a depurar la información redudante generada
% por Spectre Simulation, la cual repite las filas impares 
% dejando el archivo excesivamente grande.

clear all; close all;

NAME_FILE = 'Cgs_prime';
FILE = importdata(['./DATA_GMID/',NAME_FILE,'.csv']);
cols = length(FILE(1,:));
rows = length(FILE(:,1));

NEW_FILE = zeros(rows,cols/2 + 1);

for i=1:cols
   
    if i == 1
        % La variable en comun de todos los datos
        NEW_FILE(:,1) = FILE(:,1);
    elseif rem(i,2) == 0
        % El dato
        NEW_FILE(:,i/2+1) = FILE(:,i);
        
    else 
        continue;
        
    end
    
end

% Imprimir en otro archivo
dlmwrite(['./DATA_GMID/',NAME_FILE,'NMOS','.csv'],NEW_FILE,'delimiter',',','precision','%1.10e')



