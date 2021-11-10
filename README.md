# dce-dro-matlab

CAM-DCE-DRO v 1.0  2021

(c) Andrew Gill, Martin Graves
All rights reserved

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Contains MATLAB source code and example configuration files to generate
digital reference objects in DICOM format for testing dynamic-contrast
enhanced MRI (DCE-MRI) kinetic-model analysis software packages.

MATLAB version:

Developed and tested in MATLAB 2019a
Required toolboxes: Image processing


To execute: 'run_construct_digital_phantom.m'

Set-up and configuration:-

In 'run_construct_digital_phantom.m' :-
  
    % -- START SET-UP -----------------------------------------------------

    config.STUDY          = 'EXAMPLES';  % Generic name for study/project...
    
    config.TEST_FLAG      = true;   % Gives more debug information if set...

    config.WRITE_OUTPUT   = true;   % Disable any writing of files if this is set 'false'...
   
    % Paths to writing location | input location, respectively...

    config.BASE_PATH  = '.\output';
    config.WORK_PATH  = '.\work';

    % Name your phantom: suggest 'model + an ID'...
    config.PHANTOM_ID     = 'TM_examp_001_01';
  
    % Kinetic model to be used...
    config.MODEL          = 'TM';    %  TM | eTM | TU | 2CXM | PLK (Patlak) | ...

    % ...and check: 'phantom_config_all_<STUDY>.m'   
    
                % This specifies general study configuration parameters...
                % (See e.g. '.\config\phantom_config_all_examples.m' as an
                % example)

    % ...and write: 'phantom_config_<PHANTOM_ID>.m'  
    
                % This specifies phantom-specific configuration parameters...
                % (see e.g. '.\config\phantom_config_TM_examp_001_01.m' as 
                % an example)

    % ...and write: 'model_apply_<MODEL>.m'       
     
                % ... if not already written...
                
                % This specifies how to apply the model, in residue function format...
                % (see e.g. 'model_apply_TM.m' as an example)
             
                % N.B. If adding a new model implementation, also add relevant code
                % to the switch statements on line 216 of 'run_construct_digital_phantom.m'
                % and on line 16 of 'dce_calc_gd_curves_from_model.m'.   
                
    % Two further comma-separated variable spreadsheet files must be
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
                              % (see e.g. '.\config\param_values_TM_examp_01.csv' 
                              % as an example)
                              
    % -- END SET-UP -------------------------------------------------------


Scripts supplied:-

    .\aif ......................................... See notes above
    .\config ...................................... See notes above
    config_read_parameter_values.m ................ Read in the kinetic model parameter values to define the phantom
    curves_graph_input.m .......................... Display useful curve plots for debugging
    dce_calc_gd_curves_from_model.m ............... Applies the relevant kinetic model in the 'forwards direction' to calculate [Gd] from kinetic model indices
    dce_calc_signal_from_gd.m ..................... Calculates the MR signal from the [Gd] curves, using the standard spoiled gradient echo equation
    dce_read_aif.m ................................ Read the AIF file
    dicom_get_base_dyn_header.m ................... Form a skeletal DICOM header for the output files (N.B. DICOM conformance cannot always be guaranteed)
    dicom_write_map.m ............................. Output the kinetic model indices as maps
    dicom_write_phantom.m ......................... Output the DRO as a 4-D phantom, B1 maps, T10 and R10 maps and MFA images which can be used to generate the T10 maps
    image_add_noise.m ............................. Rudimentary function to add discretionary noise (in image domain) to output images
    run_construct_digital_phantom.m ............... Main script controlling phantom generation

    model_apply_<MODEL>.m ......................... See notes above. 
                                                    TM, eTM, Patlak, TU, 2CXM supplied: implemented largely as in ROCKETSHIP:-
                                                    See:   ROCKETSHIP v1.2, 2016 : Ng et al. ROCKETSHIP: ...
                                                           a flexible and modular software tool for the planning, ...
                                                           processing and analysis of dynamic MRI studies. BMC Med Img
                                                           2015] 
 

NOTE regarding QIBA DRO:-


The QIBA DCE DROs at https://sites.duke.edu/dblab/qibacontent/ (from which in particular
the 'qiba_aif_5-4_zero_offset.csv' file was derived) are provided under the following
original terms, copied here:-


Terms of Agreement:

Copyright 2009 by Duke University. All rights reserved.Permission to copy, use, and modify this
data and accompanying documentation for educational and research purposes is hereby granted, 
without fee and without a signed licensing agreement, provided that the above copyright notice, 
this paragraph and the following paragraph appears in all copies including derivatives of the data. 
The copyright holder is free to make upgraded or improved versions of the data, provided that they
are made readily available to others on these same terms without fee or any other charge. 
Contact the copyright holder at barbo013@mc.duke.edu for commercial licensing opportunities.

IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
INCIDENTAL, OR CONSEQUENTIAL DAMAGES, OF ANY KIND WHATSOEVER, ARISING OUT OF THE USE OF THIS 
DATA AND ITS DOCUMENTATION, EVEN IF HE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
THE COPYRIGHT HOLDER SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE DATA AND
ACCOMPANYING DOCUMENTATION IS PROVIDED “AS IS”. THE COPYRIGHT HOLDER HAS NO OBLIGATION TO 
PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS