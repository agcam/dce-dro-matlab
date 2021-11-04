


function Cv = model_apply_eTM(k, Cp, t)
% Apply the extended Tofts model (eTM)...
% Implementation (adapted slightly) from ROCKETSHIP code
 
    Ktrans = k(1);
    ve     = k(2);
    vp     = k(3);
    
    Cv = zeros(1, numel(t));
    for u = 1:numel(t)

        T  = t(1:u);
        CP = Cp(1:u);

        F = CP .* exp( (-Ktrans./ve) .* (T(end)-T) );

        if (numel(T) == 1)
            M = 0;
        else
            M = trapz(T,F);
        end

        Cv(u) = vp * Cp(u) + Ktrans .* M;
        
    end

    Cv = Cv';

end
