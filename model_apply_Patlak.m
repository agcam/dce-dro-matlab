


function Cv = model_apply_Patlak(k, Cp, t)
% Apply the Patlak model (PLK)...
% Implementation (adapted slightly) from ROCKETSHIP code
  
    ktrans = k(1);
    vp     = k(2);

    Cv = zeros(1, numel(t));

    for u = 1:numel(t)

        T  = t(1:u);
        CP = Cp(1:u);

        F = CP;

        if(numel(T) == 1)
            M = 0;
        else
            M = trapz(T,F);
        end

        Cv(u) = ktrans .* M + vp * Cp(u);

    end

    Cv = Cv';

end
