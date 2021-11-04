

function dicom_write_map(count, config, map_type, uid_maps, map_im)
% Write DICOM output files for a map type (e.g. KTRANS, VE etc...)

    if ~config.WRITE_OUTPUT, return; end
    
    % Sample header from a master file...
    hd = dicom_get_base_dyn_header(config); 
       
    if ~isfolder(fullfile(config.MAP_OUT_PATH, map_type)), mkdir(fullfile(config.MAP_OUT_PATH, map_type)); end
        
    % Save with a new UID 
    hd.SeriesInstanceUID = uid_maps;     
    hd.SeriesDescription = map_type;
    hd.SeriesNumber      = config.MAP_SERIES_NUM_START_AT + count - 1;
 
    hd.SmallestImagePixelValue = min(uint16(map_im(:)));
    hd.LargestImagePixelValue  = max(uint16(map_im(:)));
 
    fname = [num2str(config.SLICE, '%04d') '.dcm'];  % Construct a file-name eg '0012.dcm'...
    
    % Each DRO map has a zeroed area at bottom of y-axis corresponding to
    % the AIF input area in the dynamic image set...
    im = cat(1, map_im, zeros(config.Y_AIF, config.X_DIM));
  
    % Write the DICOM file...
    fprintf('Writing %-9s DICOM file (for slice %d)\n', map_type, config.SLICE); 
    
    warning off;  
    dicomwrite(uint16(im), fullfile(config.MAP_OUT_PATH, map_type, fname), hd);  % Write the DICOM file...
    warning on; 
      
end