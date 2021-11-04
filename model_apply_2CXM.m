


function Cv = model_apply_2CXM(k, Cp, t)
% Apply the two-compartment exchange model (2CXM)...
% Implementation (adapted slightly) from ROCKETSHIP code

    % N.B. Time unit is 'min' here throughout...
   
    Ktrans = k(1);
    ve     = k(2);
    vp     = k(3);
    fp     = k(4);
 
    if Ktrans >= fp
        PS = 10^8; % A large value, helps with Inf and NaN errors
    else
        PS = Ktrans * fp /(fp - Ktrans);
    end
    
    E = PS /(PS + fp);
    e = ve /(vp + ve);
    
    tau_plus  = (E-E*e+e)/(2*E)*(1+sqrt(1-(4*E*e*(1-E)*(1-e))/(E-E*e+e)^2));
    tau_minus = (E-E*e+e)/(2*E)*(1-sqrt(1-(4*E*e*(1-E)*(1-e))/(E-E*e+e)^2));
    
    k_plus  = fp / ((vp + ve) * tau_minus);
    k_minus = fp / ((vp + ve) * tau_plus );
    
    F_plus  =  1 * fp * (tau_plus  - 1) / (tau_plus - tau_minus);
    F_minus = -1 * fp * (tau_minus - 1) / (tau_plus - tau_minus);

    % Pre-allocate for speed
    Cv = zeros(1,numel(t));
    
    for u = 1:numel(t)

        T  = t(1:u);
        CP = Cp(1:u);

        F = CP .* ( F_plus * exp(-k_plus * (T(end)-T) ) + F_minus * exp(-k_minus * (T(end)-T) ) );

        if(numel(T) == 1)
            Cv(u) = 0;
        else
            Cv(u) = trapz(T,F);
        end

        if isnan(Cv(u))
            Cv(u) = 0;
        end
        
    end
    
    Cv = Cv';

end

