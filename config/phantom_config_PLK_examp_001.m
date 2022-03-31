


function config = phantom_config_PLK_examp_001(config)

    % Kinetic variables to be reported from model...
    config.VARIABLES     = {'ktrans','vp'};
    config.EXTRA_MAPS    = {};
    
    % Lump these together...
    config.KIN_VARS      = cat(2, config.VARIABLES, config.EXTRA_MAPS);

    % Number of kinetic variables...
    config.NUM_PARAMS    = length(config.KIN_VARS);
  
    % Geometry of phantom...
    config.NUM_COLS      = 6;
    config.NUM_ROWS      = 6;
    config.NUM_SLICES    = 2;

    % The file containing the input kinetic variable values and B1, T10
    % values...
    config.PARAM_IN_FILE = '.\config\param_values_PLK_examp_001.csv';

    config.NUM_BLOCKS    = config.NUM_ROWS * config.NUM_COLS;

    % DCE indices to start with...
    config.KTRANS        = config_read_parameter_values(config.KIN_VARS{1}, config.PARAM_IN_FILE, config); 
    config.VP            = config_read_parameter_values(config.KIN_VARS{2}, config.PARAM_IN_FILE, config); 

    % Scale factors for output maps [ktrans, vp]...
    config.MAP_SF        = [1000.0, 10000.0];

    % Units of variables...
    config.UNITS         = {'/min', ''};
    
    config.B1_MAP        = true;    

    % R10 and B1 in different ROIs...
    config.T10           = config_read_parameter_values('T10', config.PARAM_IN_FILE, config); 
    config.R10           = 1e6 ./ config.T10;  
    
    if config.B1_MAP
        config.B1        = config_read_parameter_values('B1',  config.PARAM_IN_FILE, config); 
    else
        config.B1        = repmat(100, config.NUM_BLOCKS, config.NUM_SLICES);
    end

end
            