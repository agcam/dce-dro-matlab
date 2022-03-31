%{

    SCRIPT TO CONSTRUCT A DIGITAL REFERENCE OBJECT FOR TESTING DCE-MRI ANALYSIS CODE

    Date   : 31-Mar-2022
    Author : A. B. Gill, PhD  [Radiology, University of Cambridge, UK]
    Version: 2.00

    [Written and tested under MATLAB R2019b]

    [Requires: MATLAB Image processing toolbox]

    [Kinetic model code adapted under GNU General Public License from:-

               ROCKETSHIP v1.2, 2016 : Ng et al. ROCKETSHIP: ...
               a flexible and modular software tool for the planning, ...
               processing and analysis of dynamic MRI studies. BMC Med Img
               2015]

%}

function run_construct_digital_phantom()
  
    % -- START SET-UP -----------------------------------------------------

    % Generic name for study/project...
    config.STUDY          = 'EXAMPLES';  

    % Kinetic model to be used...
    config.MODEL          = '2CXM';    %  TM | eTM | TU | 2CXM | PLK (Patlak) | ...

    % A description string for the phantom...
    config.PHANTOM_DESC   = 'examp_001';
      
    % ---------------------------------------------------------------------
    
    config.TEST_FLAG      = false;   % Gives more debug information if set...

    config.WRITE_OUTPUT   = true;    % Disable any writing of files if this is set 'false'...
  
    % ---------------------------------------------------------------------
     
    % Paths to writing location | working location, respectively...

    config.BASE_PATH  = '.\output';
    config.WORK_PATH  = '.\work';

    % Name of phantom...
    config.PHANTOM_ID = [config.MODEL '_' config.PHANTOM_DESC];
  
    % ...and check: 'phantom_config_all_<STUDY>.m'   
    
                % This specifies general study configuration parameters...
                % (See e.g. '.\config\phantom_config_all_examples.m' as an
                % example)

    % ...and write: 'phantom_config_<PHANTOM_ID>.m'  
    
                % This specifies phantom-specific configuration parameters...
                % (see e.g. '.\config\phantom_config_eTM_examp_001.m' as 
                % an example)

    % ...and write: 'model_apply_<MODEL>.m'       
    
                % ... if not already written...
                
                % This specifies how to apply the model, in residue function format...
                % (see e.g. 'model_apply_eTM.m' as an example)
                
                % N.B. If adding a new model implementation, also add relevant code
                % to the switch statements on line 223 of 'run_construct_digital_phantom.m'
                % and on line 16 of 'dce_calc_gd_curves_from_model.m'.

    % Two further comma-separated variable 'spreadsheet' files must be
    % suppled:-
    
    % .\aif\<AIF-FILE>.csv    % Contains 't (seconds), [Gd] (mM)' pairs (as a
                              % blood concentration) to specify the arterial
                              % input function (AIF) curve to use in phantom
                              % generation...
                              % (see e.g. '.\aif\qiba_aif_5-4_zero_offset.csv' as
                              % an example)
                              
    % .\config\<PARAMETER-VALUE-FILE>.csv
    
                              % An input file of kinetic model parameter values 
                              % to be used in phantom generation...
                              % (see e.g. '.\config\param_values_eTM_examp_001.csv' 
                              % as an example)
                              
    % -- END SET-UP -------------------------------------------------------


    % -- DERIVED PARAMETERS IN COMMON --------------------------------------------------
    
    config.BASE_OUT_PATH = fullfile(config.BASE_PATH, config.STUDY);
    
    % Retrieve common configuration parameters...
    addpath('.\config');
    
    % -- STUDY-SPECIFIC ----------------------------------------------------------
    fh = str2func(['phantom_config_all_' lower(config.STUDY)]);
    try
        config = fh(config);
    catch ME
        error([ME.message ' :-> Possibly unsupported study!']);
    end    
    
    % -- PHANTOM-SPECIFIC --------------------------------------------------------
    fh = str2func(['phantom_config_' config.PHANTOM_ID]);
    try
        config = fh(config);
    catch ME
        error([ME.message ' :-> in configuration function!']);
    end
    
    % -- DERIVED GEOMETRY PARAMETERS ---------------------------------------------------
    
    config.X_DIM = config.NUM_COLS * config.BLOCK_EXTENT;
    config.Y_DIM = config.NUM_ROWS * config.BLOCK_EXTENT;
    
    % --------------------------------------------------------------------------
    
    % Input and output maps/series...
    config.IN_MAPS    = config.KIN_VARS;
    config.OUT_SERIES = {'dce','r10','b1','t10'};
   
    % -- END OF CONFIGURATION --------------------------------------------------
    
    % -- SET-UP LOG-FILE -------------------------------------------------------

    config.LOG_FILE = fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID, ...
        ['_log_' char(string(datetime('now'), 'yyyy_MMM_dd_HH_mm_ss')) '.txt']);
    
    if ~exist(fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID), 'dir'), ...
            mkdir(fullfile(config.BASE_OUT_PATH, config.PHANTOM_ID)); end
    if ~exist(config.WORK_PATH, 'dir'), ...
            mkdir(config.WORK_PATH); end
    
    diary(config.LOG_FILE);
    diary('on');
    
    display_config(config);
    
    % -- UIDs FOR OUTPUT -------------------------------------------------------

    config.uid.study = dicomuid();
    config.uid.frame = dicomuid();
    
    % Assign new UIDs for output DICOM series...
    for i = 1:length(config.OUT_SERIES)
        uid.(config.OUT_SERIES{i}) = dicomuid();
    end
    for i = 1:length(config.IN_MAPS)
        uid.(config.IN_MAPS{i}) = dicomuid();
    end
    uid.auc = dicomuid();
    for i = 1:numel(config.FLIP_ANGLES)
        uid.mfa{i} = dicomuid();
    end
  
    % -- MAKE THE PHANTOM ------------------------------------------------------
    
    % Make the phantom, slice by slice...
    for slice = 1:config.NUM_SLICES
        config.SLICE = slice;
        make_digital_phantom_slice(config, uid)
    end
    
    disp('--- Finished making phantom ---');
    
    diary('off');
    
    return

    % -- END -------------------------------------------------------------------
    


    function make_digital_phantom_slice(config, uid)
    % Make one slice of the phantom...
    
        if config.TEST_FLAG
            hf = figure(100);
        end
        
        this_slice = config.SLICE;
        
        % Slice to make...
        config.SLICE_POS = [(config.SLICE_THICKNESS*(this_slice-1)), 0, config.SLICE_THICKNESS];  % This slice, first slice, slice gap

        % Time series in seconds...
        t = (cumsum(ones(config.TIME_PTS, 1)) - 1) * config.DT;

        % Time must be converted to minutes for e.g. Ktrans in '/min'...
        tm = t / 60.0;

        % We have NUM_BLOCKS 'blocks' in a grid defined by the (X_DIM) x (Y_DIM) pixel array...

        % Initialise the simulated [Gd] curves...
        Cv = zeros(config.TIME_PTS, config.NUM_BLOCKS);
        SI = zeros(config.TIME_PTS + config.BLP, config.NUM_BLOCKS);

        lc_in_maps = lower(config.IN_MAPS);

        % Initialise maps showing the 'ground-truth' parameter values...
        for m = 1:length(config.IN_MAPS)
            true_value_map.(lc_in_maps{m}) = zeros(config.Y_DIM, config.X_DIM);
        end

        fprintf('Calculating slice %d signal intensities for image blocks (total %d) ->\n', this_slice, config.NUM_BLOCKS);
        
        nc = config.NUM_COLS; 
        
        be = config.BLOCK_EXTENT;   % ... in pixels
 
        % Read in the AIF, expressed on a fine time-grid of points...
        Cb = dce_read_aif(config.AIF_IN_FILE, t, config.FINE_DT);
 
        % For all blocks in the grid...
        for v = 1:config.NUM_BLOCKS

            c = mod(v-1,nc)+1;         % Column number of block
            r = floor((v-1)/nc)+1;     % Row number of block

            % Assign kinetic model input parameter values...
            switch config.MODEL
                case 'TM'
                    k(:,v) = [config.KTRANS(v, this_slice), config.VE(v, this_slice), config.KEP(v, this_slice)]; %#ok<AGROW>
                case 'eTM'
                    k(:,v) = [config.KTRANS(v, this_slice), config.VE(v, this_slice), config.VP(v, this_slice), config.KEP(v, this_slice)]; %#ok<AGROW>
                case 'TU'
                    k(:,v) = [config.KTRANS(v, this_slice), config.PS(v, this_slice), config.VP(v, this_slice), config.FP(v, this_slice), config.TP(v, this_slice)]; %#ok<AGROW>
                case '2CXM'
                    k(:,v) = [config.KTRANS(v, this_slice), config.VE(v, this_slice), config.VP(v, this_slice), config.FP(v, this_slice), config.PS(v, this_slice), config.TP(v, this_slice)]; %#ok<AGROW>
                case 'PLK'
                    k(:,v) = [config.KTRANS(v, this_slice), config.VP(v, this_slice)]; %#ok<AGROW>
                otherwise
                    error('Unsupported model!');
            end
            
            B1  = config.B1(v, this_slice);
            R10 = config.R10(v, this_slice);
            
            % Run the 'forwards model equation' to calculate [Gd] uptake curves from the model...
            Cv(:,v) = dce_calc_gd_curves_from_model( Cb, config.MODEL, ...
                                                    ( config.FINE_DT / 60.0), ...
                                                      k(:,v), ...
                                                      tm, ...
                                                      config.TIME_PTS, ...
                                                      config.HEMATOCRIT,  ...
                                                      config.NUM_PARAMS, ...
                                                      config.TISSUE_DELAY);
               
            % Calculate auc...this calculation is a bit rough and ready - assumes small DT!
            % ...could be optimised further...
            auc_start_time  = max(1, config.TISSUE_DELAY);  % AIF defined to rise at 0.0 s; tissue curve at 0.0 + TISSUE_DELAY; BLP dealt with later in code... 
            auc_end_time    = auc_start_time + config.AUC_INTERVAL;
            start_pt        = find((t - auc_start_time) >= 0, 1, 'first');
            end_pt          = find((t -   auc_end_time) >= 0, 1, 'first');
            auc             = sum(Cv(start_pt:end_pt,v)) * config.DT;  
            
            % Show these, if testing...
            if config.TEST_FLAG
                
                figure(hf);
                subplot(2,1,1);
                
                Cb_m = put_aif_back_in_tm(config, t, Cb);
                  
                curves_graph_input(tm * 60.0, Cb_m, Cv(:,v));
                
                for cc = 1:size(k,1)
                    text(gca, 0.2, 0.6 - 0.1 * cc, [ lc_in_maps{cc} ' = ' num2str(k(cc,v)) ' ' config.UNITS{cc}], 'Units','normalized');
                end
                
            end

            % Pixels involved in the extent of this square block (Cs:Rs)...
            R = be * (r-1) + 1; C = be * (c-1) + 1;
            Rs = R:R+be-1; Cs = C:C+be-1;

            % Assign this block pixel values (note scale factor to give good
            % image discretization)...
            for m = 1:length(config.IN_MAPS)
                true_value_map.(lc_in_maps{m})(Rs,Cs) = double(k(m,v) *  config.MAP_SF(m));
            end
            true_value_map.auc(Rs,Cs) = double(auc) * 100.0;  % Here, the SF of 100 is hard-wired...

            % Convert the 'tumour' [Gd] to a signal level: add BLP to beginning...
            SI(:,v) = cat(1, config.BASELINE_SI * ones(config.BLP, 1), ...
                                            dce_calc_signal_from_gd( ...
                                                   Cv(:,v), ...
                                                   config.RELAXIVITY, ...
                                                   config.ALPHA, ...
                                                   config.TR, ...
                                                   R10, ...
                                                   B1, ...
                                                   config.BASELINE_SI) ...
                                                   );

            % Show progress...
            if mod(v, config.NUM_BLOCKS/10.0) == 0
                fprintf('   %d%%', v / (config.NUM_BLOCKS/10.0) * 10.0);
            end
            
            if config.TEST_FLAG
                
                % Show signal curve if testing...
                % N.B. We add on base-line points for this viewing...
                
                figure(hf);
                subplot(2,1,2);
              
                curves_graph_input(cat(1, (tm * 60.0), tm(end) * 60.0 + config.DT * cumsum(ones(config.BLP, 1))), SI(:,v));
                
            end

        end

        fprintf('\n');
        
        % Convert the 'blood' [Gd] to a signal level...

        Cb_m = put_aif_back_in_tm(config, t, Cb);  % Put back on time grid in minutes...

        aif_Gd = Cb_m;
        aif_SI(:) = cat(1, config.BASELINE_SI * ones(config.BLP, 1), ...
                        dce_calc_signal_from_gd( ...
                               aif_Gd, ...
                               config.RELAXIVITY, ...
                               config.ALPHA, ...
                               config.TR, ...
                               config.BLOOD_R10, ...
                               config.BLOOD_B1, ...        
                               config.BASELINE_SI));
                               
        % Write a slice of the output phantom...
        dicom_write_phantom(config, uid, config.SCALE_SIGNAL_BY * SI, config.SCALE_SIGNAL_BY * aif_SI, tm * 60.0);

        % Write a slice of each 'ground-truth' map...
        for m = 1:length(config.IN_MAPS)
            dicom_write_map(m, config, ['in_' lc_in_maps{m}], uid.(lc_in_maps{m}), true_value_map.(lc_in_maps{m}));
        end
        dicom_write_map(length(config.IN_MAPS) + 1, config, 'in_auc', uid.auc, true_value_map.auc);
            
    end

    function Cb_m = put_aif_back_in_tm(config, t, Cb)
    % Input AIF on fine time grid in seconds; output AIF on dynamic series
    % time grid (in minutes)...
    
        dt = config.FINE_DT;
        n  = config.TIME_PTS;
        
        N = round(t(end) / dt);
        fine_t = cumsum(ones(N,1) * dt) - dt;
                                                              
        Cb = interp1(fine_t, Cb, t, 'pchip', 'extrap');
        Cb(isnan(Cb) | ~isfinite(Cb)) = 0.0;
        Cb_m = Cb(1:n);
        
    end


    function display_config(p)
    % Display the current configuration parameters...
    
        f = fieldnames(p);
        
        for j = 1:length(f)
            
            val = p.(f{j});
            
            if     ischar(val)
                disp([f{j} ' = ' val]);
            elseif isnumeric(val)
                if size(val, 1) > 1
                    disp([f{j} ': <matrix of values>']);
                else
                    disp([f{j} ' = ' num2str(val)]);
                end
            elseif islogical(val)
                if val
                    disp([f{j} ' = true']);
                else
                    disp([f{j} ' = false']);
                end
            elseif iscell(val)
                disp([f{j} '-->']);
                n = numel(val);
                for m = 1:n
                    newval = val{m};
                    if isnumeric(newval), disp(num2str(newval)); end
                    if ischar(newval), disp(newval); end
                end
            else
                disp('--error--');
            end
        end
        
    end

end  % run_construct_digital_phantom.m








