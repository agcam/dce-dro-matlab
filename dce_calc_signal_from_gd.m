

function S_true = dce_calc_signal_from_gd(Gd, r, a_deg, TR, R10, B1, base_S)
% Convert [Gd] in tissue to signal intensity...

    % Flip-angle recorded in DICOM header is multiplied by B1 value in DCE
    % to give actual flip-angle in analysis program.
    a_act = a_deg * ( B1 / 100.0 );
   
    % Convert flip angle to radians
    a = (a_act / 360.0) * 2 * pi;
    
    sin_a = sin(a);
    cos_a = cos(a);
    
    R10 = R10 / 1e6;    % I.e. now in ms(-1)
    
    % Standard equation...
    R1 = (r * 1e-3) * Gd + R10;   % 'r' is the relaxivity value for the tissue/contrast agent
    
    % Standard gradient echo equation, vectorized...
    S = sin_a * ( 1 - exp(-TR * R1) ) ./ ( 1 - cos_a * exp(-TR * R1) );
    
    % Scale factor derived from baseline signal...
    S0 = ( sin_a * (1 - exp(-TR*R10)) / ( 1 - cos_a * exp(-TR*R10) ) );
    
    % Signal level to build phantom with...
    S_true = ( ( (S - S0) / S0 ) * base_S) + base_S;
    
end