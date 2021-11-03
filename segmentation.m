%% DOCUMENTATION

% AUTHORS: Katie Lavigne
% DATE: November 9th, 2016
% 
% FILE:     segmentation.m
% PURPOSE:  Performs MRI segmentation through SPM.
% USAGE:    Click on button in fMRI GUI under Structural Data Setup.
% 
% DESCRIPTION: This script segments the T1 (structural) images into grey
% matter, white matter and cerebrospinal fluid. It also creates a *seg_sn.mat
% file to be used during normalization.

% Note: There are no options for this step. Any non-default parameters are based on the fMRI Preprocessing GUI found at
% cfrifs02/WoodwardLab/Manual/PreprocessingManual/woodwardLab_preprocessingManual_sept17_2014.pdf.


function segmentation(seg)
fcn_name = 'Segmentation';
errors = {};
count = 0;
T1img=[];

spmfiles = fullfile(seg.spmdir, '/tpm/TPM.nii');

for s = 1:size(seg.T1subjs,1) % start subject loop
    if seg.segmentnew == 1
        if isempty(dir(fullfile(seg.structdir, seg.T1subjs(s).name, ['m' seg.t1prefix2 seg.t1prefix seg.T1subjs(s).name '*' seg.t1suffix seg.t1ext])));
            temp = dir(fullfile(seg.structdir, seg.T1subjs(s).name, [seg.t1prefix2 seg.t1prefix seg.T1subjs(s).name '*' seg.t1suffix seg.t1ext]));
            if size(temp,1) == 0
                warning(['No T1 image found for ' seg.T1subjs(s).name '. Segmentation skipped!'])
                errors{size(errors,1)+1,1} = ['No T1 image found for ' seg.T1subjs(s).name '. Segmentation skipped!'];
            elseif size(temp,1) > 1
                warning(['Multiple T1 images found for ' seg.T1subjs(s).name '. Segmentation skipped!'])
                errors{size(errors,1)+1,1} = ['Multiple T1 images found for ' seg.T1subjs(s).name '. Segmentation skipped!'];
                continue
            else
                T1img = fullfile(seg.structdir, seg.T1subjs(s).name, temp.name);
            end
        else
            continue
        end
    elseif seg.segmentnew == 0
        temp = dir(fullfile(seg.structdir, seg.T1subjs(s).name, [seg.t1prefix2 seg.t1prefix seg.T1subjs(s).name '*' seg.t1suffix seg.t1ext]));
        if size(temp,1) == 0
            warning(['No T1 image found for ' seg.T1subjs(s).name '. Segmentation skipped!'])
            errors{size(errors,1)+1,1} = ['No T1 image found for ' seg.T1subjs(s).name '. Segmentation skipped!'];
            continue
        elseif size(temp,1) > 1
            warning(['Multiple T1 images found for ' seg.T1subjs(s).name '. Segmentation skipped!'])
            errors{size(errors,1)+1,1} = ['Multiple T1 images found for ' seg.T1subjs(s).name '. Segmentation skipped!'];
            continue
        else
            T1img = fullfile(seg.structdir, seg.T1subjs(s).name, temp.name);
        end
    end
    if (~isempty(T1img)), % if T1img exists
        [~, file_name, ~] = fileparts(T1img);
        if (~isempty(file_name)), % if file exists
            matlabbatch{1}.spm.spatial.preproc.data = {T1img}; % T1 image path
            matlabbatch{1}.spm.spatial.preproc.output.GM = [0 1 1]; % Grey Matter = Native + Unmodulated Normalized
            matlabbatch{1}.spm.spatial.preproc.output.WM = [0 1 1]; % White Matter = Native + Unmodulated Normalized
            matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 1 1]; % CSF = Native + Unmodulated Normalized
            matlabbatch{1}.spm.spatial.preproc.output.biascor = 1; % SPM default parameters starting here
            matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
            matlabbatch{1}.spm.spatial.preproc.opts.tpm = spmfiles; % SPM files based on spm directory input
            matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2
                                                         2
                                                         2
                                                         4];
            matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
            matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
            matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
            matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
            matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
            matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
            matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};

            savefile = ['segmentation_', seg.T1subjs(s).name]; % save matlabbatch as segmentation_(subject).mat
            save(savefile,'matlabbatch')
            spm_jobman('run',matlabbatch); % run SPM job
            count = count + 1;
            clear('matlabbatch');
        else
            warning(['No T1 image found for ' seg.T1subjs(s).name '. Segmentation skipped!'])
            errors{size(errors,1)+1,1} = ['No T1 image found for ' seg.T1subjs(s).name '. Segmentation skipped!'];
        end
    end
end % end subject loop


error_check(fcn_name, errors, count);

end