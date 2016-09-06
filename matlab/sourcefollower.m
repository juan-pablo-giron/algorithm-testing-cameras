% ================================================================= %
% =============       DESIGN OF SOURCE FOLLOWER            ======== % 
% ===============   USING THE GM/ID METHODOLOGY   ================= %
% ================================================================= %
% This algorithm design one source follower PMOS
% ================================================================= %
clear all;
clc;
close all;

%% ================== TRANSISTOR'S PARAMETERS  ===================== %


nn = 1.334;
np = 1.369;
Vtn = 359.2e-3;
Vtp = 387e-3;
Kn = 227.1e-6;
Kp = 48.1e-6;
fi = 25.8e-3;

%% =================== LOAD OF DATABASE CURVES ===================== %


Wknow = 22e-6;
%Lknow = 10e-6;
Lknow = 1e-6;
L  = 1e-6;
L4 = 2e-6;
ratio = Wknow/Lknow;
Id = 50e-9;
Vdd = 1.8;

% here is defined the Inversion coefficient

ICmin = 0.1;
ICmax = 10;
Isn = 2*nn*Kn*fi^2;
Isp = 2*np*Kp*fi^2;

% NMOS
% vgs_gmn = importdata('gmoverid_22u10u_nmos.csv');
% vgs_idn = importdata('idnmos22u10u.csv');
% gmoveridn = vgs_gmn(:,2);
% idn_norm = vgs_idn(:,2)/ratio;
% ICn = idn_norm/(Isn);

%PMOS
%vgs_gmp = importdata('gmoverid_22u10u_pmos.csv');
%vgs_idp = importdata('idpmos22u10u.csv');
vgs_gmp = importdata('gmoverid_22u1u_pmos.csv');
vgs_idp = importdata('idpmos22u1u.csv');
gmoveridp = vgs_gmp(:,2);
idp_norm = -vgs_idp(:,2)/ratio;
ICp = idp_norm/(Isp);

%% ====================== DESIGN OF THE CIRCUIT =================== %

[row,col] = find(ICp > ICmin,1);
row = row - 1; %the previous is the valid
WL1 = Id / idp_norm(row);
WL2 = WL1;
vgs2 = vgs_idp(row,1);
Vbias2 = Vdd - vgs2;

%% ===================   OUTPUT CIRCUIT   ========================== %

fprintf('=== GREAT WE HAD FOUND A GOOD DESIGN ===\n')

fprintf('============ SPECIFICATIONS   ==========\n')
fprintf('Id = %1.2fnA\n',Id/1e-9)
fprintf('Working in Weak Inversion\n')
fprintf('==========   DIMENSIONS  ================\n')
fprintf('W1 = %1.2f um\n',WL1);
fprintf('L1 = %1.2f um\n',L/1e-6);
fprintf('W2 = %1.2f um\n',WL2);
fprintf('L2 = %1.2f um\n',L/1e-6);
fprintf('vbias2 = %1.2f V\n',Vbias2);


