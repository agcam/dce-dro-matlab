
function hd = dicom_get_base_dyn_header(config)

    % Changes to generic header - not exhaustively checked (works for MIStar, Rocketship and
    % MATLAB analysis)...
 
    % ------------------------------------------------
    dicomwrite(zeros(128), fullfile(config.WORK_PATH, 'tmp_0001.dcm'), 'ObjectType','MR Image Storage');
    
    hd = dicominfo(fullfile(config.WORK_PATH, 'tmp_0001.dcm'));

    hd.ImagePositionPatient(1)= 0;
    hd.ImagePositionPatient(2)= 0;
    
    hd.FrameOfReferenceUID = config.uid.frame;
    hd.StudyInstanceUID    = config.uid.study;

    % ------------------------------------------------
    
    %hd = dicominfo(fullfile(config.WORK_PATH, config.HEADER_DYN));
 
    hd.PatientName.FamilyName = config.PHANTOM_ID;
    hd.PatientID              = config.PHANTOM_ID;
    
    hd.InstanceNumber         = config.SLICE;
    
    hd.RepetitionTime         = config.TR;
    hd.FlipAngle              = config.ALPHA;
    
    hd.SliceLocation          = config.SLICE_POS(1);
    hd.FirstScanLocation      = config.SLICE_POS(2);
    hd.SpacingBetweenSlices   = config.SLICE_POS(3);
    hd.PixelSpacing           = config.PIXEL_DIMS;
    
    hd.SliceThickness         = config.SLICE_POS(3);
    
    hd.ImagePositionPatient(3)= config.SLICE_POS(1);
    
    hd.ImageOrientationPatient = [1;0;0;0;1;0];
    
    hd.ImagesInAcquisition    = config.NUM_SLICES;
       
    % For MIStar...
    hd.AcquisitionNumber = 1;
    hd.SpecificCharacterSet = 'ISO_IR 100';

    hd.ContentDate     = '20210101';
    hd.StudyDate       = '20210101';
    hd.AcquisitionDate = '20210101';
    hd.SeriesDate      = '20210101';
    
    hd.StudyTime       = '083000.000';
    hd.SeriesTime      = '083000.000';
    hd.AcquisitionTime = '090000.000';
    hd.ContentTime     = '100000.000';
    
    hd.ImagingFrequency      = '127.777054';
    hd.ImagedNucleus         = '1H';
    hd.MagneticFieldStrength = 3;
    hd.PatientPosition = 'HFS';
    % end for mistar
    
    hd.TriggerTime = 0.0;
    
    hd.EchoTime = config.TE;
       
    hd.Rows    = config.X_DIM;
    hd.Columns = config.Y_DIM + config.Y_AIF;
    hd.Width   = hd.Rows;
    hd.Height  = hd.Columns;

    hd.MRAcquisitionType       = '3D';
    hd.VariableFlipAngleFlag   = 'N';
    
    hd.NumberOfAverages        = 1;
    hd.PercentSampling         = 100;
    hd.PercentPhaseFieldOfView = 100;
    %hd.ReconstructionDiameter  = 100;
    hd.AcquisitionMatrix       = [config.Y_DIM + config.Y_AIF;0;0;config.X_DIM];
    
    hd.NumberOfTemporalPositions = 1; 
    
    hd.SmallestImagePixelValue = 0;
    hd.LargestImagePixelValue  = 1000;
    hd.WindowCenter            = 500;
    hd.WindowWidth             = 500;
    
    hd.StudyID = '';
    
end
