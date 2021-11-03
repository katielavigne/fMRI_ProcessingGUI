%% DOCUMENTATION
% AUTHOR: Katie Lavigne (lavigne.k@gmail.com)
% DATE: November 3rd, 2016
% 
% FILE:     preprocessfMRI.m
% PURPOSE:  Performs SPM fMRI processing through GUI.
% USAGE:    Type preprocessfMRI in command window.
% 
% DESCRIPTION:  This script will open the fMRI Processing GUI and SPM.
% 
% REQUIREMENTS:
%   1) Folders and filenames cannot contain spaces
%       - Useful linux command line scripts for removing spaces from filenames
%           1.  find [path to parent directory] -depth -name "* *" -execdir rename 's/ /_/g' "{}" \;
%               (Use rename -f to force rename and overwrite files if necessary)
%           2.  IFS="\n"
%               for file in s*/*; 
%               do 
%                   mv "$file" "${file//[[:space:]]}";
%               done
%
%   2) Subject IDs in folders and filenames must be consistent (including case)
%       - Useful linux command for renaming files
%           -   find [path to parent directory] -depth -iname "*wildcard*"
%           | while read filename; do mv ${filename} ${filename}(changes)
%               e.g., find /data4/EEG/MCT -depth -iname "*s76*" | while
%               read filename; do mv ${filename} ${filename//s76/S076}; done
%               (will replace all s76 and S76 with S076)
%
%   3) Folder structure should be as follows: 
%           - Functional directory 
%             - Subject
%               - Run
%                 - Scan
%           - Structural directory
%             - Subject
%               - Scan
% 
%             OR (NOT TESTED!)
%             - Subject
%               - Functional run folder
%                 - Functional scan files
%               - Structural scan files
%
%   4) Subject IDs, Runs and Scans looked for are determined by user-defined, case-sensitive, wildcards (in data setup), so make sure they are entered properly based on the folder names!
%       -   e.g., If folder name is 'Run1', run wildcard 'run*' will not work (use 'Run*')!; Same with 'BADE' vs 'bade' etc.
%
%   5) The T1 Prefix in datasetup refers to the filename of the structural scan up to
%   the subject ID (so for a filename of 'WOODWARD_OTT_3DT1_H001a_8_1.nii',
%   the prefix should be exactly 'WOODWARD_OTT_3DT1_'. The code adds the
%   subject ID to this prefix and looks for files that correspond for each
%   subject. So the prefix has to be consistent across all subjects. If you
%   are not using structural scans for co-registration, this can be left
%   blank.

function preprocessfMRI()

clear
clc

% FIX PATH
    if ~exist('CPCA') == 0
        disp('Removing CPCA folders from path...')
        cpca_path = fileparts(which('cpca'));
        rmdir(genpath(cpca_path))
        clear classes
    end
    
    try
        spm fMRI
    catch
        disp('SPM fMRI not found. Please select SPM directory.')
        SPMpath = uigetdir(pwd, 'Select SPM Directory');
        addpath(genpath(SPMpath))
        spm fMRI
    end
    
    disp('Warning: Do not close the SPM Graphics window if you want to save the .ps files during processing.')
    
    set(0,'DefaultUicontrolBackgroundColor', [.94 .94 .94])
    fMRIGUI
end
