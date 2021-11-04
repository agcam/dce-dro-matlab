


function Cv = dce_calc_gd_curves_from_model(Cb, model, dt, k, t, n, Hct, ~, tissue_delay_secs)
% Calculate the tissue [Gd] curve from the model and the AIF...

    % Both 't' and 'dt' enter here as 'min'...

    % Do the convolutions on a finer time grid for accuracy...
    N = round(t(end) / dt);
 
    fine_t = cumsum(ones(N,1) * dt) - dt;
   
    Cp = Cb / (1 - Hct);  % Hematocrit correction...
      
    switch model
        case 'eTM'
            Cv = model_apply_eTM(k, Cp, fine_t);
        case {'TM','qTM'}
            Cv = model_apply_TM(k, Cp, fine_t);
        case 'TU'
            Cv = model_apply_TU(k, Cp, fine_t);
        case '2CXM'
            Cv = model_apply_2CXM(k, Cp, fine_t);
        case 'PLK'
            Cv = model_apply_Patlak(k, Cp, fine_t);
        otherwise
            error('Unsupported model!');
    end
  
    % Add onset time (relative to AIF onset)...
    Cv = shiftCbyTime(fine_t * 60.0, Cv, tissue_delay_secs);
        
    % Put back onto original time grid...
    Cv = interp1(fine_t, Cv, t, 'pchip', 'extrap');
    Cv(isnan(Cv) | ~isfinite(Cv)) = 0.0;
    Cv = Cv(1:n);
  
end


function Cnew = shiftCbyTime(t, C, by_time)
% Shift a curve left or right by specified number of seconds...

    n = length(t);
    Cnew = zeros(n,1);
    
    % Notice that we can't just shift array up and down because 'dt' is
    % potentially a variable interval. So, we interpolate new AIF at time 't'
    % from old AIF(t)...
    
    for i = 1:n
        new_t = t(i) - by_time;
        if new_t < 0
            Cnew(i) = C(1);
        elseif new_t > t(n)
            Cnew(i) = C(n);
        else
            Cnew(i) = interp1(t, C, new_t, 'pchip');
        end        
    end
    
end

