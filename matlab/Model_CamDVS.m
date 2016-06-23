%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Aqui esta el modelo de una camara DVS
%  Entradas: time, I_ph, Vhigh, Vlow, Vglobal_rst
%  Salidas : RREQ, CREQON,CREQOFF
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [RREQ,CREQ_ON,CREQOFF] = Model_DVS_ARRAY(I_pd,VdiffON,VdiffOFF,Vglobal_rst,hold_RREQ)

%% ========================= PARAMAMETERS MOSFET  ================= %%
nn = 1.334;
np = 1.369;
Vtn = 359.2e-3;
Vtp = 387e-3;
Kn = 227.1e-6;
Kp = 48.1e-6;
fi = 25.8e-3;
Ratio = 0.5e-6/2e-6;
Isn = 2*nn*fi^2*Kn*Ratio;
A = 20;

%Iph = input_signal(:,2);

if ( ~Vglobal_rst || ~hold_RREQ )
    log_Ipd = log(I_pd/Isn);
    Vdiff = -nn*fi*A*log_Ipd;
    if (Vdiff <= VdiffON)

        RREQ = 1;
        %output_ON(i) = 1.8;
        %Vdiff(i:len_t) = Vdiff(i:len_t) + abs(value); %reset to Vref

    elseif ( Vdiff >= VdiffOFF)

        RREQ = 1;
        %output_OFF(i) = 1.8;
        %Vdiff(i:len_t) = Vdiff(i:len_t) - abs(value); %reset to Vref

    end
end


%Vdiff_max = max(Vdiff);    %used to normalized
%Vdiff = Vdiff - Vdiff_max; %used to normalized


%for i=1:len_t
%    value = Vdiff(i);
%     if (value <= VdiffON)
        
%        output_ON(i) = 1.8;
%        Vdiff(i:len_t) = Vdiff(i:len_t) + abs(value); %reset to Vref
        
%    else
%        if ( value >= VdiffOFF)
            
%            output_OFF(i) = 1.8;
%            Vdiff(i:len_t) = Vdiff(i:len_t) - abs(value); %reset to Vref
            
%        else
%            continue
%        end
%    end
    
%end
%total_result(:,N+1) = output_ON';
%total_result(:,N+2) = output_OFF';
