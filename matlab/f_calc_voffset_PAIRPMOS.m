function [sok_voffset,Voffset_total] = f_calc_voffset_PAIRPMOS(Voffsetmin,Voffsetmax,Wpair,Lpair,Wmirror,Lmirror,gmid_pair,gmid_mirror)

    %mismatch parameters

    %NMOS
    Abetanmos = 0.5*(1/100)*1e-6;
    Avtnmos = 0.5*10e-9;
    Abetawnmos = 0.01e-6;
    Abetalnmos = 0.05e-6;
    Avtwnmos = 0.06e-6;
    Avtlnmos = 0.075e-6;
    %PMOS
    Abetapmos = 0.5*(4.8/100)*1e-6;
    Avtpmos = 0.5*6.5e-9;
    Abetawpmos = -0.15e-6;
    Abetalpmos = 0;
    Avtwpmos = 0.13e-6;
    Avtlpmos = 0.14e-6;

    %mismatch Pair
    sigma_vt_2 = (Avtpmos^2)/(Wpair*Lpair);
    sigma_beta_2 = (Abetapmos^2)/(Wpair*Lpair);
    Voffset_pair = sqrt(sigma_vt_2 + sigma_beta_2/gmid_pair^2);

    % mirror current

    % mismatch 
    sigma_vt_2 = (Avtnmos^2)/(Wmirror*Lmirror);
    sigma_beta_2 = (Abetanmos^2)/(Wmirror*Lmirror);
    sigma_id = sqrt( sigma_beta_2 + sigma_vt_2*gmid_mirror^2);
    Voffset_mirror = sigma_id/gmid_pair;


    Voffset_total = sqrt(Voffset_pair^2 + Voffset_mirror^2);
    
    if Voffset_total>Voffsetmin && Voffset_total<Voffsetmax
        
        sok_voffset = 1;
    else
        sok_voffset = 0;

    end
end

