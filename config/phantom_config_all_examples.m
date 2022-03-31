


function config = phantom_config_all_examples(config)

    config.DT            = 0.5;      % Time resolution of dynamics series (s)

    config.HEMATOCRIT    = 0.45;     % Assumed hematocrit...

    % Output paths to write DRO data to...
    config.OUT_PATH_DYN  = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID, 'DCE_dynamic_series');
    config.OUT_PATH_T10  = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID, 'T1_maps_B1_corrected');
    config.OUT_PATH_MFA  = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID, 'MFA');    
    config.OUT_PATH_R10  = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID, 'R1_maps_B1_corrected');
    config.OUT_PATH_B1   = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID, 'B1_maps');

    config.MAP_OUT_PATH  = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID);

    config.SERIES_NUM_START_AT     = 20;
    config.MAP_SERIES_NUM_START_AT = 40;
    
    config.FLIP_ANGLES   = [3, 6, 9, 15, 24, 35]; % MFA flip-angle set (degrees)

    % Scale up signal to avoid discretisation errors...
    config.SCALE_SIGNAL_BY = 5.0; 

    % Configuration of phantom...
    config.DURATION      = 325;      % Seconds

    config.FINE_DT       = 0.5;      % Time resolution (interval in seconds) for calculating convolutions
    config.TIME_PTS      = round(config.DURATION / config.DT);
    config.BLP           = 10;       % Number of base-line points to put in curves (measured in DT intervals) 

    config.TISSUE_DELAY  = 0.0;      % Tissue enhancement curve onset (seconds) relative to AIF onset...! (BLP are added additionally to beginning of AIF and Cv.)
    config.DOSE          = 0.1;      % Dose of contrast agent : typically 0.1 mM/kg
    config.RELAXIVITY    = 4.5;      % Blood plasma relaxivity [/(mM) /s] for the Gd preparation used...
    config.ALPHA         = 25.0;     % Dynamic series nominal flip-angle (degrees)
    config.TR            = 5.0;      % TR of dynamic series to be written (ms)
    config.TE            = 2.5;      % TE of dynamic series (N.B. Not used in conversion to [Gd], but written to DICOM headers.)
    config.BASELINE_SI   = 1000.0 / config.SCALE_SIGNAL_BY;   
                                     % Estimated baseline signal FOR TUMOUR: exact value isn't critical...
                                     % ...set at approx. the signal level recorded by a similar real sequence (and then divide by the scale factor) 
                                     
    config.BLOCK_EXTENT  = 10;       % Each square block in the resulting phantom has this dimension (in pixels)

    config.PIXEL_DIMS    = [1.0, 1.0]; % mm

    config.SLICE_THICKNESS = 10.0;   % (mm)

    config.MFA_SF        = 1e5;      % Scale MFA signal intensities by this: doesn't affect T1 map. Typically set to 1e5 for good range of signals.
    config.NOISE_LEVEL   = 0;        % S.D. of noise level to add : an 'absolute' noise signal intensity level

    config.TIMING_FIELD  = 'AcquisitionTime';     
                                     % 'TriggerTime' | 'AcquisitionTime'
                                     
    config.AUC_INTERVAL  = 90.0;     % In seconds e.g. set to 90 seconds for 'iaugc90' 
   
    config.Y_AIF         = 20;       % Height in pixels of AIF region appended to lower extent of dynamic images
    config.BLOOD_T10     = 1664.0;   % Value at 3 T from Lu H et al. Magn Reson Med. 2004 Sep;52(3):679-82. doi: 10.1002/mrm.20178. PMID: 15334591.
    config.BLOOD_R10     = 1e6 / config.BLOOD_T10; 
                                     % Fixed value at 3 T: used to convert blood curve to signal... [1.0E+6 / ms] :
                                     
    config.BLOOD_B1      = 100.0;
    config.AIF_IN_FILE   = '.\aif\qiba_aif_5-4_zero_offset.csv';  % ! AIF rise should begin at t = 0.0 in the AIF file !...
                                                                  % ! AIF should be recorded as a blood concentration (not a plasma concentration)
                                                                  
    
end
            