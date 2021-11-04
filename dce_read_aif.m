

function [AIF, retval] = dce_read_aif(aif_in_file, t, dt)
% Get the AIF from a file and interpolate to fit time series...

    retval = 1;
        
    N = round(t(end) / dt);
    fine_t = cumsum(ones(N,1) * dt) - dt;
    
    [aif_t, Cb, ok] = read_aif_file(aif_in_file, false);
    if ok < 0, retval = -1; return; end
    
    % Interpolate AIF...
    AIF = interp1(aif_t, Cb, fine_t);
    AIF(isnan(AIF)) = 0.0;
    
end

% Read an AIF from file...
function [t, aif, retval] = read_aif_file(aif_in_file, SD_IN_FILE)

    retval = 1;

    t = []; aif = []; 
    
    % Open the input file for reading; check; read header; and close
    fid = fopen(aif_in_file, 'r');
    if fid == -1
        disp(['ERROR: Error opening data file ' aif_in_file]);
        retval = -1;
        return;
    end
    
    [~, ~, fext] = fileparts(aif_in_file);
    
    if     strcmp(fext, '.csv')
        s_format = '%f, %f';
    elseif strcmp(fext, '.txt')
        s_format = '%f %f';
    end
    
    if ~SD_IN_FILE
        data = textscan(fid, s_format, 'HeaderLines',1);  
    else
        % Can add code to handle this if required...
        error('Unknown AIF file format!');
    end
    
    fclose(fid);
    
    t   = data{1,1};
    aif = data{1,2};
    
end



