%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 		Parametros tecnologia AMS 180nm
%		Extraido de: Simulaciones en PSP Model & ENG-331_rev2
%       v. 2014-02-16
%		folivera
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constantes fisicas
T0 = 273;          	% reference temperature...............gradK.
UT0 = .0259;       	% thermal voltage (300 gradoK)........V
epsOx = .345e-16;  	% permittivity of oxide ..............F/um  
q= 1.602e-19;       % carga del electron ... C
kB=1.381e-23;       % cte de boltzman   .... J/K
UT=kB*T/q;

% Datos tecnologia
tox = 3.5e-3; 	   	% um	
Cox = (epsOx/tox); 	% F/um2
LVA=1;     %um, L de los datos de VA que ya estan normalizados
Lmin=0.180;   % um
Wmin=1.5;   % um

%% CANAL N
%Kn------------- 
p1 =   4.392e-09;
p2 =  -4.143e-06;
p3 =    0.001135;
Kn = p1.*T.^2 + p2.*T + p3;
%Vton-------------
p1 =  -1.022e-06;
p2 =   5.106e-05;
p3 =      0.4085;  
VTon = p1.*T.^2 + p2.*T + p3;
%%nn--------------
p1 =   3.368e-07;
p2 =  -2.505e-05;
p3 =       1.215;
nn = p1*T.^2 + p2.*T + p3;

VAn1=1.892; 
VAn0=6.466;
% VA = VAn1*L + VAn0 (L=[um]) donde VAn1=1.892 VAn0=6.466 funciona muy bien en la faja de
% L=1um hasta L=20um 

%gamman = 0.68;	%V^(1/2)
DLn=0.035; %um
DWn=0.02; %um

%Cap extrinsecas
% Cgsd0 (F/um) Overlap capacitance
Covn=0.33e-15;
% Cj (F/um^2) STI area capacitance
% Cjsw (F/um) STI sidewall capacitance 
% N+ S/D to SXDIODE 
Cjn=1.12e-15;
Cjwn=0.155e-15;

%% CANAL P  
%Kp------------- 
p1 =   3.716e-10;
p2 =   -3.93e-07;
p3 =   0.0001418;
Kp = p1.*T.^2 + p2.*T + p3;
%Vtop-------------
p1 =  -1.117e-06;
p2 =  -1.349e-05; 
p3 =      0.4798;
VTop = p1.*T.^2 + p2.*T + p3;
%%np--------------
p1 =   4.395e-07;
p2 =  -6.114e-05;
p3 =       1.276;
np = p1*T.^2 + p2.*T + p3;

VAp0=14.04; 
VAp1=5.217;
% VA = VAp1*L + VAp0 (L=[um]) donde VAp1=5.217 VAp0=14.04 funciona muy bien en la faja de
% L=1um hasta L=20um

%gammap = 0.61;	%V^(1/2)
DWp= 0.04;   % um
DLp= 0.035;   % um

% Cap extrinsecas
% Cgsd0 (F/um) Overlap capacitance
Covp=0.36e-15;
% Cj (F/um^2) STI area capacitance
% Cjsw (F/um) STI sidewall capacitance 
% P+ S/D NW DIODE
Cjp=1.15e-15;
Cjwp=0.09e-15;

%% Mismatch
%Dados de arquivo de documentacao AMS, ENG-349_rev1.pdf
%Tirados da tabela para W=10um L=2um
%Ak
Akp_n = 0.066/100*1e-6;%AMS
Akp_p = 0.56/100*1e-6;%AMS
%AVt
Avt_n = 3.233e-3*1e-6;%AMS
Avt_p = 2.145e-3*1e-6;%AMS

%% Ruido Flicker
KFlicker_n = 6.9620e-025;%S=KF/(WL)*(1/f) com W,L em [m]
KFlicker_p = 3.9598e-024;%S=KF/(WL)*(1/f) com W,L em [m]
         