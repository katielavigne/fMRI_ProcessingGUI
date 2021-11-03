%% DOCUMENTATION

% AUTHORS: Katie Lavigne
% DATE: February 3rd, 2016
% 
% FILE:     smoothing.m
% PURPOSE:  Performs fMRI smoothing through SPM.
% USAGE:    Click on checkbox in fMRI GUI and click Run.
% 
% DESCRIPTION: This script smooths the normalized functional images with 
% a Gaussian kernel. You can input the width of the kernel as an option
% when you click on the checkbox. It will output functional scans with the 
% 's' prefix, which are usually used for analysis. Recommended width is 2-3 x voxel size.

% Note: There are no options for this step. Any non-default parameters are based on the fMRI Preprocessing GUI found at
% cfrifs02/WoodwardLab/Manual/PreprocessingManual/woodwardLab_preprocessingManual_sept17_2014.pdf.


function [count, errors] = smoothing(count, errors, sm)
imgs = {};
	for s = 1: size(sm.subjs,1)
		norundirs = 0;
		subjdir = fullfile(sm.funcdir, sm.subjs(s).name);
		if ~isempty(sm.run)
			runlist = dir(fullfile(subjdir, sm.run));
			if size(runlist, 1) == 0
				warning(['No runs found for ' sm.subjs(s).name ' ' strcat(fcn_name, ' skipped!')])
				errors{size(errors,1)+1,1} = ['No runs found for ' sm.subjs(s).name '. ' strcat(fcn_name, ' skipped!')];
				continue
			end            
		else
			norundirs = 1;
			runlist = 1;
        end
        for r = 1:size(runlist,1)
            if norundirs == 1
                rundir = subjdir;
            else
                rundir = fullfile(subjdir, runlist(r).name);
            end
            if sm.newonly == 1
                if isempty(dir(fullfile(rundir, ['sw*' sm.scan])));
                    imglist = dir(fullfile(rundir, ['w*' sm.scan]));
                    if isempty(imglist)
                        warning(['No normalized scans found for ' sm.subjs(s).name ' ' runlist(r).name '! Subject skipped.'])
                        errors{size(errors,1)+1,1} = ['No normalized scans found for ' sm.subjs(s).name ' ' runlist(r).name '! Subject skipped.'];
                        continue
                    end
                    tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
                    for j = 1:size(imglist,1)
                        tempimgs{j} = fullfile(rundir, [imglist(j).name ',1']); % creates array listing full paths to each image in current run
                    end
                    imgs=[imgs; tempimgs]; % concatenates image array for runs per subject
                else % if output files (swa*.nii) exist
                    continue
                end
            elseif sm.newonly == 0
                imglist = dir(fullfile(rundir, ['w*' sm.scan]));
                if isempty(imglist)
                    warning(['No normalized scans found for ' sm.subjs(s).name ' ' runlist(r).name '! Subject skipped.'])
                    errors{size(errors,1)+1,1} = ['No normalized scans found for ' sm.subjs(s).name ' ' runlist(r).name '! Subject skipped.'];
                    continue
                end
                tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
                for j = 1:size(imglist,1)
                    tempimgs{j} = fullfile(rundir, [imglist(j).name ',1']); % creates array listing full paths to each image in current run
                end
                imgs=[imgs; tempimgs]; % concatenates image array for runs per subject
            end % end subject type if
        end % end run loop
    end % end subj loop



	if ~cellfun('isempty',imgs)
		matlabbatch{1}.spm.spatial.smooth.data = imgs; % image list
		matlabbatch{1}.spm.spatial.smooth.fwhm = sm.kernelsize;
		matlabbatch{1}.spm.spatial.smooth.dtype = 0;
		matlabbatch{1}.spm.spatial.smooth.im = 0;
		matlabbatch{1}.spm.spatial.smooth.prefix = 's';

		savefile = ['smoothing_' date]; % save matlabbatch as smoothing.mat
		save(savefile,'matlabbatch')
		spm_jobman('run',matlabbatch); % run SPM job
		count = 1;
		clear('matlabbatch');
	else
		warning('No normalized scans found. Smoothing skipped!')
	end
end



% function smoothing(sm)
% fcn_name = 'Smoothing';
% errors = {};
% count = 0;
% imgs={};
% 
% for s = 1:size(sm.subjs,1)
%     norundirs = 0;
%     subjdir = fullfile(sm.funcdir, sm.subjs(s).name);
%     if ~isempty(sm.run)
%         runlist = dir(fullfile(subjdir, sm.run));
%         if size(runlist,1) == 0
%             warning(['No runs found for ' sm.subjs(s).name '. Smoothing skipped!'])
%             errors{size(errors,1)+1,1} = ['No runs found for ' sm.subjs(s).name '. Smoothing skipped!'];
%             continue
%         end
%     else
%         norundirs = 1;
%         runlist = 1;
%     end
%     for r = 1:size(runlist,1)
%         if norundirs == 1
%             rundir = subjdir;
%         else
%             rundir = fullfile(subjdir, runlist(r).name);
%         end
%         if sm.newonly == 1
%             if isempty(dir(fullfile(rundir, ['sw*' sm.scan])));
%                 imglist = dir(fullfile(rundir, ['w*' sm.scan]));
%                 tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
%                 for j = 1:size(imglist,1)
%                     tempimgs{j} = fullfile(rundir, [imglist(j).name ',1']); % creates array listing full paths to each image in current run
%                 end
%                 imgs=[imgs; tempimgs]; % concatenates image array for runs per subject
%             else % if output files (swa*.nii) exist
%                 continue
%             end
%         elseif sm.newonly == 0
%             imglist = dir(fullfile(rundir, ['w*' sm.scan]));
%             tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
%             for j = 1:size(imglist,1)
%                 tempimgs{j} = fullfile(rundir, [imglist(j).name ',1']); % creates array listing full paths to each image in current run
%             end
%             imgs=[imgs; tempimgs]; % concatenates image array for runs per subject
%         end % end subject type if
%     end % end run loop
% end % end subject loop
% 
% 
% if ~cellfun('isempty',imgs)
%     matlabbatch{1}.spm.spatial.smooth.data = imgs; % image list
%     matlabbatch{1}.spm.spatial.smooth.fwhm = sm.kernelsize;
%     matlabbatch{1}.spm.spatial.smooth.dtype = 0;
%     matlabbatch{1}.spm.spatial.smooth.im = 0;
%     matlabbatch{1}.spm.spatial.smooth.prefix = 's';
% 
%     savefile = ['smoothing_' date]; % save matlabbatch as smoothing.mat
%     save(savefile,'matlabbatch')
%     spm_jobman('run',matlabbatch); % run SPM job
%     count = 1;
%     clear('matlabbatch');
% else
%     warning(['No normalized scans found for ' sm.subjs(s).name '. Smoothing skipped!'])
% end
% 
% error_check(fcn_name, errors, count);
% 
% end