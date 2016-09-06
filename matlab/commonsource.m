% ================================================================= %
% =============       DESIGN OF COMMON SOURCE            ========== % 
% ===============   USING THE GM/ID METHODOLOGY   ================= %
% ================================================================= %
% This algorithm design one common source with NMOS as Active load
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
Lknow = 1e-6; %% SEE THE DATABASE TO CHANGE IT ALSO.
L  = 1e-6;
L4 = 2e-6;
ratio = Wknow/Lknow;
Id = 50e-9;
Vdd = 1.8;
size_min = 1;
% here is defined the Inversion coefficient

ICmin = 0.1;
ICmax = 10;
Isn = 2*nn*Kn*fi^2;
Isp = 2*np*Kp*fi^2;

% NMOS
%vgs_gmn = importdata('gmoverid_22u10u_nmos.csv');
%vgs_idn = importdata('idnmos22u10u.csv');
vgs_gmn = importdata('gmoverid_22u1u_nmos.csv');
vgs_idn = importdata('idnmos22u1u.csv');
gmoveridn = vgs_gmn(:,2);
idn_norm = vgs_idn(:,2)/ratio;
ICn = idn_norm/(Isn);

%PMOS
%vgs_gmp = importdata('gmoverid_22u10u_pmos.csv');
%vgs_idp = importdata('idpmos22u10u.csv');
vgs_gmp = importdata('gmoverid_22u1u_pmos.csv');
vgs_idp = importdata('idpmos22u1u.csv');
gmoveridp = vgs_gmp(:,2);
idp_norm = -vgs_idp(:,2)/ratio;
ICp = idp_norm/(Isp);

%% ====================== DESIGN OF THE CIRCUIT =================== %

%PMOS
[row,col] = find(ICp > ICmin,1);
row = row - 1; %the previous is the valid
WL1 = Id / idp_norm(row);
Vop = Vdd-vgs_idp(row);

%NMOS
[row,col] = find(ICn > ICmin,1);
row = row - 1; %the previous is the valid
WL2 = Id / idn_norm(row);
vgs2 = vgs_idn(row,1);


if (WL2 < size_min )
   
    row = 1;
    WL2 = Id / idn_norm(row);
    len_v = length(ICn);
    sError = 1;
    while ( WL2 > size_min && row<=len_v )

        if ( ICn(row) < ICmin ) 

            row_tmp = row;
            sError = 0;
        else
            sError = 1;
            row = len_v + 1;
        end

        if ( row == len_v)
            sError = 1;
        end

        row = row + 1;
        WL2 = Id/idn_norm(row);
    end

    if (sError == 0)
        WL2=Id/idn_norm(row_tmp);
        vgs2= vgs_idn(row_tmp,1);
    else
        fprintf('Please decrease the Size Minimum for the M2 transistor')
    end
end

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
fprintf('vbias2 = %1.2f mV\n',vgs2/1e-3);
fprintf('Operation Point %1.2f V\n',Vop);
fprintf('=========================================\n')

%figure(1)
%semilogx(idn_norm,gmoveridn)
%grid on
%figure(2)
%semilogy(vgs_gmn(:,1),idn_norm)
%grid on