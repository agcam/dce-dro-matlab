


function Cv = model_apply_TU(k, Cp, t)
% Apply the tissue-uptake model (TU)...
% Implementation (adapted slightly) from ROCKETSHIP code

    % N.B. Time unit is 'min' here throughout...
    
    Ktrans = k(1); PS = k(2); vp = k(3);

    Fp = (Ktrans * PS) / (PS - Ktrans);
    Tp = vp / (Fp + PS);

    Cv = zeros(1, numel(t));
    
    N = numel(t);
    
    if (PS - Ktrans) <= 0, return; end
    
    for u = 1:N

        T  = t(1:u);
        CP = Cp(1:u);

        F = CP .* ( ...
                    Fp     .*      exp(-(T(end)-T)./Tp) ...
                  + Ktrans .* (1 - exp(-(T(end)-T)./Tp))...
                   );

        if(numel(T) == 1)
            M = 0;
        else
            M = trapz(T,F); 
        end

        Cv(u) = M;
        
    end
    
    Cv = Cv';

end

