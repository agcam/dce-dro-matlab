


function Cv = model_apply_TM(k, Cp, t)
% Apply the Tofts model (TM)...
% Implementation (adapted slightly) from ROCKETSHIP code
   
    Ktrans = k(1);
    ve     = k(2);
    
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

        Cv(u) = Ktrans .* M;
        
    end

    Cv = Cv';

 end
