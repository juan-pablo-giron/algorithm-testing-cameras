% este algoritmo produce una recta exponencial de subida y bajda 
% esta senhal es ideal para saber el rango dinamico de la senal

freq=50;
T=1/freq;
samples=100;
Imin = 0.01;
Imax = 1;
Iph = [Imin Imax Imin];
t = [0 T/2 T];
t_int=0:T/samples:T;
I_pd = interp1(t,Iph,t_int,'linear');
exp_Ipd = exp(I_pd);

plot(t_int,exp_Ipd)


