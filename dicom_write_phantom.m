

function dicom_write_phantom(config, uid, SI, aif_SI, t)
% Write signal intensities as DICOM virtual phantom...

    this_slice = config.SLICE;

    % Calculate ROI masks for all the blocks in the grid...
    nc = config.NUM_COLS;
    be = config.BLOCK_EXTENT;
    roi_mask = zeros(config.Y_DIM + config.Y_AIF, config.X_DIM, config.NUM_BLOCKS);
    for v = 1:config.NUM_BLOCKS
        R = be * (floor((v-1)/nc)) + 1; C = be * (mod(v-1,nc)) + 1;
        Rs = R:R+be-1; Cs = C:C+be-1;
        roi_mask(Rs,Cs,v) = 1;
    end
    
    % Sample header from a master folder...
    H_base = dicom_get_base_dyn_header(config); 
    
    H_dyn = H_base;
    H_R10 = H_base;
    H_T10 = H_base;
    H_MFA = H_base;
    H_B1  = H_base;
    
    % Initialise, adding area for recording AIF signal intensities at top
    % of y-axis...
    im = zeros(config.Y_DIM + config.Y_AIF, config.X_DIM, config.TIME_PTS);

    % The AIF area mask is from Y_DIM to Y_DIM + Y_AIF along the y-axis...
    aif_mask = im;
    aif_mask(config.Y_DIM+1:config.Y_DIM + config.Y_AIF, :, :) = 1;
    
    % Image is modulated by the calculated signal intensities...
    for i = 1:config.TIME_PTS
        
        for n = 1:config.NUM_BLOCKS

             im(:,:,i) = im(:,:,i) + roi_mask(:,:,n) * SI(i,n);
             
        end
        
        % Add AIF region at bottom...
        im(:,:,i) = im(:,:,i) + aif_mask(:,:,i) * aif_SI(i);
        
        % Add noise to image...
        if config.NOISE_LEVEL > 0
            im(:,:,i) = image_add_noise(im(:,:,i), config.NOISE_LEVEL);
        end
        
    end

    % If we want DICOM files out (and we most likely do)...
    if config.WRITE_OUTPUT

        if ~isfolder(config.OUT_PATH_DYN), mkdir(config.OUT_PATH_DYN); end
        
        % Construct the virtual phantom...
        
        fprintf('Writing DCE DICOM files (%d time-points for slice %d) ->\n', config.TIME_PTS, config.SLICE);

        % Header...
        hd = H_dyn;  

        % Get a new UID 
        hd.SeriesInstanceUID = uid.dce; 

        % 'im' is the image volume...
        for i = 1:config.TIME_PTS
            
           im_number = ((i-1) * config.NUM_SLICES) + config.SLICE;
           
           switch config.TIMING_FIELD
               case 'TriggerTime'
                   hd.ScanOptions = 'CG';
                   hd.TriggerTime = t(i) * 1000;
               case 'AcquisitionTime'
                   hd.AcquisitionTime = t_s_to_timing_string(t(i), hd.SeriesTime);
               otherwise
                   % Can add code here to extend capabilities to suit...
                   error(['Timing field ''' config.TIMING_FIELD ''' not supported!']);
           end
           
           hd.NumberOfTemporalPositions  = config.TIME_PTS;
           
           % <added> 08-Mar-2022
           hd.TemporalPositionIdentifier = i;
           hd.TemporalResolution         = config.DT;
           % <end>
           
           I = im(:,:,i);
           
           hd.SmallestImagePixelValue = min(uint16(I(:)));
           hd.LargestImagePixelValue  = max(uint16(I(:)));
           
           hd.ImagesInAcquisition     = config.NUM_SLICES * config.TIME_PTS;
           hd.SeriesDescription       = 'Dynamic series';
           hd.ProtocolName            = 'Dynamic acq';
           hd.SeriesNumber            = config.SERIES_NUM_START_AT;
           
           hd.ImageType               = 'ORIGINAL/PRIMARY/OTHER';
           hd.StudyDescription        = 'dynamic';
           hd.PixelBandwidth          = 350;
           hd.InPlanePhaseEncodingDirection = 'ROW';
           hd.NumberOfPhaseEncodingStetps   = config.X_DIM;
            
           hd.InstanceNumber          = im_number;
    
           fname = [num2str(im_number, '%05d') '.dcm'];  % Construct a file-name eg '00012.dcm'...
           
           % Write the DICOM file...
           warning off;  
           dicomwrite(uint16(abs(im(:,:,i))), fullfile(config.OUT_PATH_DYN, fname), hd); 
           warning on; 
           
           if mod(i, floor(config.TIME_PTS/10)) == 0
               fprintf('   %d%%', i / floor(config.TIME_PTS/10) * 10);
           end
           
        end
        
        fprintf('\n');
        
        % Crop ROI masks now to not include AIF region...
        roi_mask = roi_mask(1:config.Y_DIM, 1:config.X_DIM, :);
              
        % Write the R10 map DICOM file...
        if ~isfolder(config.OUT_PATH_R10), mkdir(config.OUT_PATH_R10); end
      
        hd = H_R10;
  
        hd.SeriesInstanceUID = uid.r10;
        hd.SeriesNumber      = config.SERIES_NUM_START_AT + 1;
        hd.SeriesDescription = 'R1_map_B1_corrected';
        hd.ProtocolName      = 'R1';
    
        R10_OUT_FILE = fullfile(config.OUT_PATH_R10, [num2str(config.SLICE, '%04d') '.dcm']);
        r1_map = zeros(config.Y_DIM, config.X_DIM);
       
        for n = 1:config.NUM_BLOCKS 
        
            r1_map = r1_map + (double(config.R10(n, this_slice)) * double(roi_mask(:,:,n))); %r1_mask));
            
        end
        
        r1_map = cat(1, r1_map, ones(config.Y_AIF, config.X_DIM) * config.BLOOD_R10);
        
        hd.SmallestImagePixelValue = min(uint16(r1_map(:)));
        hd.LargestImagePixelValue  = max(uint16(r1_map(:)));

        fprintf('Writing %-9s DICOM file (for slice %d)\n', 'R10', config.SLICE); 

        dicomwrite(uint16(r1_map), R10_OUT_FILE, hd);
        
        
        % Write the T10 map DICOM file...
        if ~isfolder(config.OUT_PATH_T10), mkdir(config.OUT_PATH_T10); end
        
        hd = H_T10;
        
        hd.SeriesInstanceUID = uid.t10;       
        hd.SeriesDescription = 'T1_map_B1_corrected';
        hd.ProtocolName      = 'T1';
        hd.SeriesNumber      = config.SERIES_NUM_START_AT + 2;
                
        T10_OUT_FILE = fullfile(config.OUT_PATH_T10, [num2str(config.SLICE, '%04d') '.dcm']);
        t1_map = zeros(config.Y_DIM, config.X_DIM);
        
        for n = 1:config.NUM_BLOCKS 
        
            t1_map = t1_map + ( (1.0e6 / double(config.R10(n, this_slice))) * double(roi_mask(:,:,n)));
            
        end
        
        t1_map = cat(1, t1_map, ones(config.Y_AIF, config.X_DIM) * 1e6 / config.BLOOD_R10);
          
        hd.SmallestImagePixelValue = min(uint16(t1_map(:)));
        hd.LargestImagePixelValue  = max(uint16(t1_map(:)));

        fprintf('Writing %-9s DICOM file (for slice %d)\n', 'T10', config.SLICE); 

        dicomwrite(uint16(t1_map), T10_OUT_FILE, hd);
                
        % Write the MFA DICOM files...     

        for ia = 1:numel(config.FLIP_ANGLES)
           
            hd = H_MFA;
            
            hd.SeriesInstanceUID = uid.mfa{ia};       
            hd.SeriesDescription = 'MFA'; 
            hd.ProtocolName      = 'MFA';

            hd.SeriesNumber      = config.SERIES_NUM_START_AT + 3 + ia -1;

            a = config.FLIP_ANGLES(ia);
            hd.FlipAngle = a;
        
            OUT_PATH_MFA = [config.OUT_PATH_MFA '_' num2str(a)];
            MFA_OUT_FILE = fullfile(OUT_PATH_MFA, [num2str(config.SLICE, '%04d') '.dcm']);
            
            if ~exist(OUT_PATH_MFA, 'dir'), mkdir(OUT_PATH_MFA); end
            
            mfa = zeros(config.Y_DIM, config.X_DIM);
      
            for n = 1:config.NUM_BLOCKS
                
                B1  = double(config.B1(n, this_slice));
                R10 = double(config.R10(n, this_slice));
                            
                E10 = exp(-config.TR / (1.0e6 / R10));
                            
                actual_a = a * (B1 / 100.0);   % MULTIPLY is definitely correct! (Confirmed empirically...)
                
                % SPGR equation...
                mfa = mfa + ( config.MFA_SF ...
                    * sind(actual_a) * (1 - E10) ...
                    / (1 - cosd(actual_a) * E10) ) ...
                    * double(roi_mask(:,:,n));
            end
            
            % For AIF area...
            E10 = exp(-config.TR / (1.0e6 / config.BLOOD_R10));

            % SPGR equation...
            mfa_blood = config.MFA_SF * sind(a) * (1 - E10) ...
                                      / (1 - cosd(a) * E10);
                        
            mfa = cat(1, mfa, ones(config.Y_AIF, config.X_DIM) * mfa_blood);
            
            hd.SmallestImagePixelValue = min(uint16(mfa(:)));
            hd.LargestImagePixelValue  = max(uint16(mfa(:)));

            fprintf('Writing %-9s DICOM file (for slice %d)\n', ['MFA' num2str(a,'%02d')], config.SLICE); 
 
            dicomwrite(uint16(mfa), MFA_OUT_FILE, hd);
            
        end
        
        
        % Write the B1 map DICOM file...
        if ~isfolder(config.OUT_PATH_B1), mkdir(config.OUT_PATH_B1); end
            
        hd = H_B1;
        
        hd.SeriesInstanceUID = uid.b1;       
        hd.SeriesDescription = 'B1 maps';
        hd.ProtocolName      = 'B1';
        hd.SeriesNumber      = config.SERIES_NUM_START_AT + 3 + numel(config.FLIP_ANGLES);
        
        % These additional header settings often required 
        % - again not an exhaustive list...
        
        hd.MRAcquisitionType    = '2D';
        hd.RepetitionTime       = 30;
        hd.NumberOfAverages     = 2;
        hd.EchoTrainLength      = 1;
      
        B1_OUT_FILE = fullfile(config.OUT_PATH_B1, [num2str(config.SLICE, '%04d') '.dcm']);
        b1_map = zeros(config.Y_DIM, config.X_DIM);
        
        for n = 1:config.NUM_BLOCKS 
          
            b1_map = b1_map + (double(config.B1(n, this_slice)) * double(roi_mask(:,:,n))); 
            
        end
        
        % Add AIF area...
        b1_map = cat(1, b1_map, ones(config.Y_AIF, config.X_DIM) * config.BLOOD_B1); 
        
        hd.SmallestImagePixelValue = min(uint16(b1_map(:)));
        hd.LargestImagePixelValue  = max(uint16(b1_map(:)));
  
        hd.WindowCenter            = 100;
        hd.WindowWidth             =  10;

        fprintf('Writing %-9s DICOM file (for slice %d)\n', 'B1', config.SLICE); 

        dicomwrite(uint16(b1_map), B1_OUT_FILE, hd);
        
    end

    function new_t = t_s_to_timing_string(t, start_time)
    % Add a number of seconds (t) to a start-time string (HHmmss.SSS) and output the result as a string in same format...
    
        add_minutes = 30; % Arbitrary number of minutes to add to 'ref_time' (typically the 'SeriesTime')...

        start_t = datetime(start_time, 'InputFormat','HHmmss.SSS');
        new_t = start_t + minutes(add_minutes) + seconds(t);
        new_t_str = string(new_t, 'HHmmss.SSS');
        new_t = char(new_t_str);
        
    end
    
end
