% ================================================================= %
% =================== OPERATIONAL AMPLIFIER  ====================== % 
% ===============  USING THE GM/ID METHODOLOGY   ================== %
% ================================================================= %
% This algorithm design a OPAMP based on Miller compensation using the me-
% thodology gm/id. it is based on a semi-empirical method where were
% extracted the curves gm/id, the normalized current Id/(W/L), the 
% gm/id versus the Vgs voltage and finally we have a curve to differ-
% ents values of Vgs and Vds with a transistor's length fixed.
% it algoritm find the minimum area while satisfy the specs.
% It algorithm was made by: Juan Pablo Giron supported by CAPES. 2016.
% ================================================================= %
clc;
close all; clear all;

%% ================== TRANSISTOR'S PARAMETERS  ===================== %

cd(pwd)

nn = 1.334;
np = 1.369;
Vtn = 359.2e-3;
Vtp = 387e-3;
Kn = 227.1e-6;
Kp = 48.1e-6;
fi = 25.8e-3;

%% =================== LOAD OF DATABASE CURVES ===================== %

Wknow = 22e-6;
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

% Load the parametric setting 
settingParametricSim;

% NMOS
vgs_gmn = importdata('gmoverid_22u1u_nmos.csv');
vgs_idn = importdata('idnmos22u1u.csv');
gmoveridn = vgs_gmn(:,2);
idn_norm = vgs_idn(:,2)/ratio;
ICn = idn_norm/(Isn);
len_gmidn = length(gmoveridn);
Cgs_primeN = importdata('./DATA_GMID/Cgs_primeNMOS.csv');
Cdb_primeN = importdata('./DATA_GMID/Cbd_primeNMOS.csv');
Cgb_primeN = importdata('./DATA_GMID/Cgb_primeNMOS.csv');

%PMOS
vgs_gmp = importdata('gmoverid_22u1u_pmos.csv');
vgs_idp = importdata('idpmos22u1u.csv');
gmoveridp = vgs_gmp(:,2);
idp_norm = -vgs_idp(:,2)/ratio;
ICp = idp_norm/(Isp);
len_gmidp = length(gmoveridp);
Cgs_primeP = importdata('./DATA_GMID/Cgs_primePMOS.csv');
Cdb_primeP = importdata('./DATA_GMID/Cbd_primePMOS.csv');

% Load of Parameters AMS 180nm
T = 25; % 25 grados celsius
technoAMS180nm;

%% ======================= DESIGN CIRCUIT ========================== %

% ======== Equations to be used. ======== %
% Cc = 0.22*Cl ( To 60 degree of phase)
% I5 = SR*Cc; ( It can change on the current subthreshold range)
% GB = gm1/Cc; Gain-bandwidth unity.
% gm6 = 2.2gm1*Cl/Cc 
% Assuming: (1) Cl > Cc (2) I7 = 3*I5 (3) (gm/Id)_4 = (gm/Id)_6  

% ============== Specs ============ %

ft = (1e6)/0.922;
GB = 2*pi*ft;
Cl = 140e-15;
NDP = 2.2;
Z = 10;
IC_min = 0.1; % Subthreshold Inversion Coefficent
Vos_min = 5e-3;
Vos_max = 10e-3;
WL_min = 0.5;
Wmin = 0.5;
tol = 0.0001;
LDS = 0.240; % Source Drain Metal Width

% ======= DESIGN ========= %

Cc = (0.22*Cl); % 10% more to satisfy the inequality
L1 = 1; % Para Transistor M1 
L2 = 3; % Para los demas transistores

indx = 1; % Transistores M1 
indx5= 1; % Transistor M2
indx6= 1; % Transistor M5
Cguess = 0;

len_Wpar = length(W_par);
len_Lpar = length(L_par);
IC_current = 0;
sStopM1 = 0;
sStopM2 = 0;
runs = 0;


% ---- busqueda de los gmoverid ----- %


% T1: Par diferencial, tipo p
% T3: Espejos carga par diferencial, tipo n
% T5: source comun 2da etapa, tipo n
% T6: polarizacion 2da etapa, tipo p
% T7: fuente de corriente par diferencial (tipo p)

% Largos
L1 = 3; L3 = 3; 
L5 = 1; L6 = 3;
L7 = L6;
Wmin = 0.5;

indx = find(ICp >= IC_min ,1);
gmsobreID1 = gmoveridp(indx);

indx5 = find(ICn >= IC_min ,1);
gmsobreID5 = gmoveridn(indx5);
gmsobreID3=gmsobreID5;

indx6 = find(ICp >= IC_min,1); % limit of the weak inversion
gmsobreID6 = gmoveridp(indx6);

% CALCULO de if1, if5, if3, if6
% gmsobreID = (1/(n*UT))*(2./(sqrt(1+if)+1));
% if=(2/(n*UT*gmsobreID)-1)^2-1;
if1=(2/(np*fi*gmsobreID1)-1)^2-1;
if5=(2/(nn*fi*gmsobreID5)-1)^2-1;
if3=(2/(nn*fi*gmsobreID3)-1)^2-1;
if6=(2/(np*fi*gmsobreID6)-1)^2-1;

%%%%%%%%%%%%
%% SINTESIS DEL AMPLIFICADOR MILLER
%%%%%%%%%%%%
fprintf('Comienzo sintesis de amp. Miller ...\n')
Cf = 2.9e-12; Cguess = 0;
while abs((Cguess-Cf)/Cf) > .001;
    Cguess = Cf;
    % primera etapa
    gm1 = GB*Cf;
    ID1 = gm1/gmsobreID1; 
    WsobreL1 = ID1/(0.5*np*fi^2*Kp*if1); 
    W1 = WsobreL1*L1;
    if W1<Wmin,
        W1=Wmin;
        L1=W1/WsobreL1;
    end
        
    % Espejo de corriente (T3)
    WsobreL3 = ID1/(0.5*nn*fi^2*Kn*if3); 
    W3 = WsobreL3*L3;
    if W3<Wmin,
        W3=Wmin;
        L3=W3/WsobreL3;
    end
    
    % segunda etapa
    gm5 = Z*gm1;
    ID2 = gm5/gmsobreID5; 
    WsobreL5 = ID2/(0.5*nn*fi^2*Kn*if5); 
    W5 = WsobreL5*L5;
    if W5<Wmin,
        W5=Wmin;
        L5=W5/WsobreL5;
    end
    
    % T6 y T7 (bias 1er y 2da etapa)
    WsobreL6 = ID2/(0.5*np*fi^2*Kp*if6); 
    W6 = WsobreL6*L6; 
    W7 = W6*(2*ID1/ID2);    % M7 entrega 2ID1  < ID2 que entrega M6
    if W7<Wmin,
        W7=Wmin;
        W6=W7*ID2/2/ID1;
        L6=W6/WsobreL6;
        L7=L6;
    end

    
    % recalculo de Cf, C1, C2 
    
    % C1: capacidad en el nodo salida 1er etapa
    % C1 = Cjd3 + Cjd2 + Cg5;
    % Modelo ACM: Caps intrinsecas
    caps_T5=ACMintrcap(nn,Cox,W5,L5,if5);
    Cgs5=caps_T5(1);
    Cgb5=caps_T5(5);
    C1 = Cjn*W3*LDS+Cjwn*(2*W3+2*LDS)+Cjp*W1*LDS+Cjwp*(2*W1+2*LDS)+ Cgs5+Cgb5+Covn*W5;
    
    % C2: capacidad en el nodo de salida;
    % C2 = Cjd5 + Cjd6 + CL
    C2 = Cl+Cjn*W5*LDS+Cjwn*(2*W5+2*LDS)+Cjp*W6*LDS+Cjwp*(2*W6+2*LDS);
    
    Cf = 0.5*NDP/Z*(C1+C2+sqrt((C1+C2)^2+4*C1*C2*Z/NDP));
    
end

% VERIFICO QUE CONVERGIO A "ALGO"
if ~isfinite(Cf),
    error('No converge! Revise los parametros de entrada ...')
else
    fprintf('Exito!\n\n');
end
%% fin SINTESIS DEL AMPLIFICADOR MILLER
%%%%%%%%%%%%

%{



while abs((Cguess-Cc)/Cc) > tol;
    
    Cguess = Cc;
    
    % ============ Step 1 --PMOS-- ============= %%
    % %Calculate gm1=GB*Cc
    % Id1 = gm1/(gm/id)*
    % (W/L)1 = Id/Id*
    % (W/L)1 = (W/L)2

    gm1 = GB*Cc;
    gmoveridp1 = gmoveridp(indx);
    ID1 = gm1/gmoveridp1;
    WL1 = ID1 / (2*np*fi^2*Kp*ICp(indx);
    
    if W1<Wmin,
        W1=Wmin;
        L1=W1/WsobreL1;
    end
    

    % ========  Step 2: Find M2 NMOS ========= %%
    % gm6 = 2.2*gm1*Cl/Cc
    % Id6 = gm6/(gm/id)6
    % (W/L)6 = Id / Id*

    gm2 = Z*gm1;
    gmoveridn2 = gmoveridn(indx2);
    ID2 = gm2 / gmoveridn2;
    WL2 = ID2 / idn_norm(indx2);

    WL3 = ID1 / idn_norm(indx2); gmoveridn3 = gmoveridn(indx2);
    WL5 = 2*ID1 / idp_norm(indx3);
    WL4 = ID2*WL5 / (2*ID1);
    %{
    
    %% Find the minimum voltage offset with minimum area
    
    [sOk_voffset,Voffset]=f_calc_voffset_PAIRPMOS(Vos_min,Vos_max, ...
        WL1*L1*1e-6,L1*1e-6,WL3*L2*1e-6,L2*1e-6,gmoveridp1,gmoveridn3);
    
    while ~sOk_voffset
        
        if Voffset > Vos_min || (sStopM1==1 && sStopM2==1)
            error('Check the Specs, I can not find a good design.. Increase Vos_max')
        else
           % Optimization phase area finding the minimum offset


           if WL1 < WL_min && sStopM1 == 0 && ICp(indx) < IC_min
                indx = indx - 1;
                WL1 = ID1 / idp_norm(indx-1);
                sStopM1 = 1;
           else
                indx = indx + 1;
                WL1 = ID1 / idp_norm(indx);
           end

           if WL2 < WL_min && sStopM2 == 0 && ICn(indx) < IC_min
                indx2 = indx2 - 1;
                WL2 = ID2 / idn_norm(indx2-1);
                sStopM2 = 1;
           else
                indx2 = indx2 + 1;
                WL2 = ID2 / idn_norm(indx2);
           end

           WL3 = ID1 / (2*nn*fi^2*Kn*ICn(indx2)); gmoveridn3 = gmoveridn(indx2);

           if WL3*L2 < Wmin
               indx2 = indx2 - 1;
               sStopM2 = 1;
               WL3 = ID1 / (2*nn*fi^2*Kn*ICn(indx2)); gmoveridn3 = gmoveridn(indx2);
           end
           % Calculates again the new value of Voffset
           [sOk_voffset,Voffset]=f_calc_voffset_PAIRPMOS(Vos_min,Vos_max, ...
             WL1*L1*1e-6,L1*1e-6,WL3*L2*1e-6,L2*1e-6,gmoveridp1,gmoveridn3);
            
           
            
                
         
        end
    end
    
    % ======  Step 3 Find M3, M4 and M5 (NMOS,PMOS,PMOS) =========== %%

    %WL3 = ID1 / idn_norm(indx2); gmoveridn3 = gmoveridn(indx2);
    
    % Optimization of M5
    WL5 = 2*ID1 / idp_norm(indx3);
    while ( WL5 >= WL_min && ICp(indx3) <= IC_min )
        
        indx3 = indx3 + 1;
        WL5 = 2*ID1 / idp_norm(indx3);
        
    end
    WL5 = 2*ID1 / idp_norm(indx3-1); % The previous is the right value
    WL4 = ID2*WL5 / (2*ID1);
    %}
    
    % ========== Step 4 Calculate Cc ============ %%
    
    %% Hace la busqueda del mejor W y L en las tablas 
    
    % ------------- Cbd1 PMOS ----------------- %
    posL = find ( L_par >= L1,1);
    posW = find ( W_par >= WL1,1);
    if isempty(posL); posL = len_Lpar; end;
    if isempty(posW); posW = len_Wpar; end;
    posArrayCap = (len_Wpar * posL - 1) + (posW - 1);
    ind_tmp = find(Cdb_primeP(:,1) >= vgs_gmp(indx,1) ,1);  
    Cbd1 = Cdb_primeP(ind_tmp,posArrayCap)*WL1*L1*1e-12;
    
    % ------------- Cdb3 NMOS ----------------- %
    posL = find ( L_par >= L2,1);
    posW = find ( W_par >= WL3,1);
    if isempty(posL); posL = len_Lpar; end;
    if isempty(posW); posW = len_Wpar; end;
    posArrayCap = (len_Wpar * posL - 1) + (posW - 1);
    ind_tmp = find(Cdb_primeN(:,1) >= vgs_gmn(indx2,1) ,1); 
    Cdb3 = Cdb_primeN(ind_tmp,posArrayCap)*WL3*L2*1e-12;
    
    % ------------- Cgs2 NMOS ----------------- %
    posL = find ( L_par >= L2,1);
    posW = find ( W_par >= WL2,1);
    if isempty(posL); posL = len_Lpar; end;
    if isempty(posW); posW = len_Wpar; end;
    posArrayCap = (len_Wpar * posL - 1) + (posW - 1);
    ind_tmp = find(Cgs_primeN(:,1) >= vgs_gmn(indx2,1) ,1); 
    Cgs2 = Cgs_primeN(ind_tmp,posArrayCap)*WL2*L2*1e-12;
    
    % ------------- Cdb4 PMOS ----------------- %
    posL = find ( L_par >= L2,1);
    posW = find ( W_par >= WL4,1);
    if isempty(posL); posL = len_Lpar; end;
    if isempty(posW); posW = len_Wpar; end;
    posArrayCap = (len_Wpar * posL - 1) + (posW - 1);
    ind_tmp = find(Cdb_primeP(:,1) >= vgs_gmp(indx3,1) ,1);  
    Cbd4 = Cdb_primeP(ind_tmp,posArrayCap)*WL4*L2*1e-12;
    
    % ------------- Cbd2 NMOS ----------------- %
    posL = find ( L_par >= L2,1);
    posW = find ( W_par >= WL2,1);
    if isempty(posL); posL = len_Lpar; end;
    if isempty(posW); posW = len_Wpar; end;
    posArrayCap = (len_Wpar * posL - 1) + (posW - 1);
    ind_tmp = find(Cdb_primeN(:,1) >= vgs_gmn(indx2,1) ,1);  
    Cbd2 = Cdb_primeN(ind_tmp,posArrayCap)*WL2*L2*1e-12;
    
    % ------------- Cgb2 NMOS ----------------- %
    posL = find ( L_par >= L2,1);
    posW = find ( W_par >= WL2,1);
    if isempty(posL); posL = len_Lpar; end;
    if isempty(posW); posW = len_Wpar; end;
    posArrayCap = (len_Wpar * posL - 1) + (posW - 1);
    ind_tmp = find(Cgb_primeN(:,1) >= vgs_gmn(indx2,1) ,1);  
    Cgb2 = Cgb_primeN(ind_tmp,posArrayCap)*WL2*L2*1e-12;
    
    %C1 = Cgs2 + Cdb3 + Cbd1;
    %C2 = Cl + Cbd2 + Cbd4;
    
    % --------- PROPOSED BY JESPERS ----------- %
    % C1: capacidad en el nodo salida 1er etapa
    % C1 = Cjd3 + Cjd2 + Cg5;
    
    W1 = WL1*L1;
    W2 = WL2*L2;
    W3 = WL3*L2;
    W4 = WL4*L2;
    
    % ---- ACM Capacitances ----- %
    
    if2 = ICn(indx2);
    sq = sqrt(1+if2);
    Cgs2 = Cox*2/3*(1-1./sq).*(1-1./(sq+1).^2);
    Cgb2= (nn-1)/nn*(Cox-Cgs2);
    
    C1 =  Cjn*W3*LDS+Cjwn*(2*W3+2*LDS)+Cjp*W1*LDS+Cjwp*(2*W1+2*LDS)+ Cgs2+Cgb2+Covn*W2;
    
    % C2: capacidad en el nodo de salida;
    % C2 = Cjd5 + Cjd6 + CL
    
    C2 = Cl+Cjn*W2*LDS+Cjwn*(2*W2+2*LDS)+Cjp*W4*LDS+Cjwp*(2*W4+2*LDS);
    
    % ------------ END ---------------- %
    
    Cc = 0.5*(NDP/Z)*(C1+C2+sqrt((C1+C2)^2 + 4*C1*C2*Z/NDP));
    
    % Condition to increase the indx_j
       
    %{
    
    if ICp(indx+1) < IC_min    
        indx = indx + 1;
    end
    if ICn(indx2+1) < IC_min
        indx2 = indx2 + 1;
    end
    if ICp(indx3+1) < IC_min
        indx3 = indx3 + 1;
    end
    %}
    runs = runs + 1;
end

fprintf('Runs %d \n',runs)

%% Optimization Current Source M4 and M5


% =============== OUTPUTS ================= %%



WL1b = WL1;
WL3b = WL3;


fprintf('---------------------------------------- \n')
fprintf('Id5 = %1.2f nA \n',2*ID1/1e-9)
fprintf('Cc = %1.2f fF \n',Cc/1e-15)
fprintf('BW =  %d Mhz\n',GB/(2*pi)/1e6)

fprintf('===========  SIZING =================== \n')
fprintf('W1a & W1b = %1.2f um\n',L1*WL1)
fprintf('L1 = %1.2f um\n',L1)
fprintf('WL3a & WL3b = %1.2f um\n',L2*WL3)
fprintf('L3 = %1.2f um\n',L2)
fprintf('WL2 = %1.2f um\n',WL2*L2)
fprintf('L3 = %1.2f um\n',L2)
fprintf('WL4 = %1.2f um\n',L2*WL4)
fprintf('L4 = %1.2f um\n',L2)
fprintf('WL5 = %1.2f um\n',L2*WL5)
fprintf('L5 = %1.2f um\n',L2)

gmoveridp1

%}

fprintf('\nDiseño:\n\tfT: \t%3.2f MHz\n\tMF: \t%3.2fº\n\tCL: \t%3.2f fF\n',ft/1e6,62,Cl*1e15);
%fprintf(fid,'\tVdd = %1.2f V\tVss = %1.2f V\n',VDD,VSS);
%fprintf(fid,'\nResultado:\n\tfT: \t%3.2f MHz\n\tMF: \t%3.2fº\n\tfase cero RHP: \t%3.2fº (incluida)\n\tfase doublet: \t%3.2fº (no incluida)\n',fTexp/1e6,margin,phasezero,phasedoublet);
%fprintf(fid,'\tfdoub / fT: %2.3f\n',fdoubsobrefT);
%fprintf(fid,'\tGanancia: \t\t%3.2f dB\n\t\tEtapa 1: \t%3.2f dB\n\t\tEtapa 2: \t%3.2f dB \n',A,Av1,Av2);
%fprintf(fid,'\tOSwing: %1.2f V : %1.2f V (%1.2f V)\n\tICMR: \t%1.2f V : %1.2f V (%1.2f V)\n',OSmax,OSmin,OSwing,VCMmax,VCMmin,ICMR);
%fprintf(fid,'\nConsumo: %3.2f uW (%3.3f uA)\n\tID1 = \t%3.3f uA\n\tID2 = \t%3.2f uA\n',(VDD-VSS)*Idd*1e6,Idd*1e6,ID1*1e6,ID2*1e6);
fprintf('\(gm/ID)1: \t%2.2f\n(gm/ID)5: \t%2.2f\n',gmsobreID1,gmsobreID5);
fprintf('\nCapacidad Miller: \tCf = %1.2f fF\n',Cf*1e15);
%fprintf(fid,'Capacidades Parásitas: \tC1 = %1.3f pF\n\t\t\tC2-CL = %1.3f pF\n\t\t\tC3 = %1.3f pF\n',C1*1e12,(C2-Cl)*1e12,C3*1e12);
fprintf('\nTamaños:\n\tW1 = %2.1f um\tL1 = %2.1f um\n\tW5 = %2.1f um\tL5 = %2.1f um\n',W1,L1,W5,L5);
fprintf('\tW3 = %2.1f um\tL3 = %2.1f um\n\tW6 = %2.1f um\tL6 = %2.1f um\n',W3,L3,W6,L6);
fprintf('\tW7 = %2.1f um\tL7 = %2.1f um\n',W7,L7);
%fprintf(fid,'\nSuperficie: \t%3.0f um2\n',Surf);


