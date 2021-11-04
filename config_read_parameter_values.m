


function values = config_read_parameter_values(this_param, IN_FILE, config)
% Read in all the kinetic model parameter values required for constructing this phantom...

    T = readtable(IN_FILE);
    
    n = height(T);
    
    if ~(n == (config.NUM_BLOCKS * config.NUM_SLICES))
        error(['Input table should have ' num2str(config.NUM_ROWS) ' x ' num2str(config.NUM_COLS) ' x ' num2str(config.NUM_SLICES) ' = ' ...
            num2str(config.NUM_ROWS * config.NUM_COLS * config.NUM_SLICES) ' rows!']);
    end
    
    this_param = lower(this_param);
 
    values = zeros(config.NUM_ROWS * config.NUM_COLS, config.NUM_SLICES);
    
    for s = 1:config.NUM_SLICES

        try
            values(:, s) = T{(T{:,'slice'} == s), this_param};
        catch
            error(['Error reading ''' this_param ''' from input file, slice ' num2str(s) '!']);
        end
      
    end
    
end
