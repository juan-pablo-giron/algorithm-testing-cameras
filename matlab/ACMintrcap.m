%Cálculo de capacidades intrínsecas para un MOSFET
%utilizando el modelo ACM.


function y = ACMintrcap(n,Coxoua,W,L,i)
 

sq = sqrt(1+i);
Cox = Coxoua*W*L;
Cgs = Cox*2/3*(1-1./sq).*(1-1./(sq+1).^2);
Cgd = 0*i; %saturación
Cbs = (n-1)*Cgs;
Cbd =(n-1)*Cgd;
Cgb = (n-1)/n*(Cox-Cgs-Cgd);
Csd = 0*i; %saturación
Cds = 0*i;
Cm = 0*i;

y = [Cgs' Cgd' Cbs' Cbd' Cgb' Csd' Cds' Cm'];
