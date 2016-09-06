% ================================================================= %
% ============= DESIGN OF THE AMPLIFIER OF TRANSIMPEDANCE  ======== % 
% ===============  USING THE GM/ID METHODOLOGY   ================== %
% ================================================================= %
% This algorithm design one amplifier of transimpedance using the me-
% thodology gm/id. it is based on a semi-empirical method where were
% extracted the curves gm/id, the normalized current Id/(W/L), the 
% gm/id versus the Vgs voltage and finally we have a curve to differ-
% ents values of Vgs and Vds with a transistor's length fixed.
% it algoritm find the minimum area to a amplifier working in subthres
% hold operation regimen, and predict the gain which is close to the 
% simulated at Cadence's simulator. 
% it algorithm was made by: Juan Pablo Giron supported by CAPES. 2016.
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

% VA early extraction DC SWEEP sources features
Vgs_min = 100e-3;
Vgs_max = 350e-3;
Vgs_step = 10e-3;
Vds_min = 100e-3;
Vds_max = 1.8;
Vds_step = 1e-3;
v_vds = Vds_min:Vds_step:Vds_max;
v_vgs = Vgs_min:Vgs_step:Vgs_max;

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
Va_nmos = importdata('CurvesVA_DC_SWEEP_VDS_VGS_NMOS_V2.csv');

%PMOS
%vgs_gmp = importdata('gmoverid_22u10u_pmos.csv');
%vgs_idp = importdata('idpmos22u10u.csv');
vgs_gmp = importdata('gmoverid_22u1u_pmos.csv');
vgs_idp = importdata('idpmos22u1u.csv');
gmoveridp = vgs_gmp(:,2);
idp_norm = -vgs_idp(:,2)/ratio;
ICp = idp_norm/(Isp);
Va_pmos = importdata('CurvesVA_DC_SWEEP_VDS_VGS_PMOSV2.csv');


%% ======================= DESIGN CIRCUIT ========================== %

% specs
vdd = 1.8;
Id1 = 0.5e-12;
%Id4 = 120e-12;
Id4 = 100e-12; 
vds1 = 4*fi; %the minimum vds for M1.
size_min = 0; %It is reached with Lmin = 2u and W= 500n. Only for M4!!!
k = Id1/Id4;

% WL1
[row,column] = find(ICn > ICmin , 1);
row = row - 1; % The previous is the valid
vgs1= vgs_idn(row,column);
gm1 = gmoveridn(row)*Id1;
gmoverid1 = gmoveridn(row);
WL1 = Id1/idn_norm(row);
WL2 = WL1;
vbias2 = vgs1 + vds1;

%WL3
[row,column] = find(ICp > ICmin ,1);
row = row - 1; %the previous is the valid
vgs3 = vgs_idp(row,column);
gm3 = gmoveridp(row,column)*Id1;
WL3 = Id1/idp_norm(row);
WL5 = WL3;
vds3 = vdd - vgs3;

%WL4 
%Note: Here is implemented and loop to find a size of the transistor
%reasonable, e.g WL>1

row = 1;
len_v = length(ICn);
sError = 1;
WL4 = Id4/idn_norm(row);
while ( WL4 > size_min && row<=len_v )
   
    if ( ICn(row) < ICmin ) 
        
        row_M4 = row;
        sError = 0;
    else
        sError = 1;1
        row = len_v + 1;
    end
    
    if ( row == len_v)
        sError = 1;
    end
    
    row = row + 1;
    WL4 = Id4/idn_norm(row);
end

if (sError == 0)
    WL4=Id4/idn_norm(row_M4);
    vgs4= vgs_idn(row_M4,1);
    gm4 = gmoveridn(row_M4)*Id4;
    gmoverid4 = gmoveridn(row_M4);
    vds4 = vdd - vgs1;
else
    fprintf('Please decrease the Size Minimum of the M4 transistor')
end

% Estimating the gain of the whole circuit
% Aproximated equation.
% Acl = -(gm1/Id1)/(1/Va3 + 1/k*(gm4/Id4) )
% Aol = -(gm1/Id1)*Va3


[~,col] = find(v_vgs >= vgs3,1);
[x,row] = find(v_vds >= vds3 , 1);
VA3 = Va_pmos(row,2*col);

Acl = -gmoverid1 / (1/VA3 + (1/k)*gmoverid4);
Aol = -gmoverid1 * VA3;


%% ===================   OUTPUT CIRCUIT   ========================== %

fprintf('=== GREAT WE HAD FOUND A GOOD DESIGN ===\n')

fprintf('============ SPECIFICATIONS   ==========\n')
fprintf('Id1 = %1.2fnA\n',Id1/1e-9)
fprintf('Id4 = %1.2fpA\n',Id4/1e-12)
fprintf('Working in Weak Inversion\n')
fprintf('==========   DIMENSIONS  ================\n')
fprintf('W1 = %1.1f um\n',WL1);
fprintf('L1 = %1.1f um\n',L/1e-6);
fprintf('W2 = %1.1f um\n',WL2);
fprintf('L2 = %1.1f um\n',L/1e-6);
fprintf('W3 = %1.1f um\n',WL3);
fprintf('L3 = %1.1f um\n',L/1e-6);
fprintf('W5 = %1.1f um\n',WL5);
fprintf('L5 = %1.1f um\n',L/1e-6);
fprintf('W4 = %1.1f um\n',WL4*L4/1e-6);
fprintf('L4 = %1.1f um\n',L4/1e-6);
fprintf('vbias2 = %1.2f mV\n',vbias2/1e-3);
fprintf('============  ESTIMATED GAIN  =========\n')
fprintf('Gain Closed Loop = %1.1f\n',Acl)
fprintf('Gain Open Loop = %1.1f\n',Aol)
fprintf('=======================================\n')

