%% DOCUMENTATION

% AUTHORS: Katie Lavigne
% DATE: November 9th, 2016
% 
% FILE:     coregistration.m
% PURPOSE:  Performs fMRI coregistration through SPM.
% USAGE:    Click on checkbox in fMRI GUI and click Run.
% 
% DESCRIPTION: This script coregisters the mean functional image to the subject's 
% T1 (structural) image. If there is no accompanying T1 image, the subject will be skipped.


function [count, errors] = coregistration(runlist, norundirs, subjdir, count, errors, s,  cor)
	for r = 1:size(runlist,1)
			if norundirs == 1
				rundir = subjdir;
			else
				rundir = fullfile(subjdir, runlist(r).name);
			end
			if cor.newonly == 1
				if isempty(dir(fullfile(cor.structdir, cor.subjs(s).name, [cor.t1prefix2 cor.t1prefix cor.subjs(s).name '*' cor.t1suffix '_seg_sn.mat']))) % Looks for segmentation file since coregistration doesn't create any files.
					imglist = dir(fullfile(rundir, ['a' cor.scan]));
					if size(imglist,1) == 0
						imglist = dir(fullfile(rundir, cor.scan));
						warning(['No slice timing corrected files found for ' cor.subjs(s).name '. Used raw files!'])
						errors{size(errors,1)+1,1} = ['No slice timing corrected files found for ' cor.subjs(s).name '. Used raw files!'];
					end
					imgs = cell(size(imglist,1),1);
					for j = 1:size(imglist,1)
						imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
					end
				else
					continue
				end
			elseif cor.newonly == 0
				imglist = dir(fullfile(rundir, ['a' cor.scan]));
				if size(imglist,1) == 0
					imglist = dir(fullfile(rundir, cor.scan));
				end
				imgs = cell(size(imglist,1),1);
				for j = 1:size(imglist,1)
					imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
				end
			end
			if ~cellfun('isempty',imgs)
				meanimg = fullfile(rundir, ['mean' imglist(1).name ',1']);

				temp = dir(fullfile(cor.structdir, cor.subjs(s).name, [cor.t1prefix2 cor.t1prefix cor.subjs(s).name '*' cor.t1suffix cor.t1ext]));
				if size(temp,1) == 0
					disp(['No T1 image found for ' cor.subjs(s).name '. Coregistration skipped!'])
					errors{size(errors,1)+1,1} = ['No T1 image found for ' cor.subjs(s).name '. Coregistration skipped!'];
					continue
				elseif size(temp,1) > 1
					warning(['Multiple T1 images found for ' cor.subjs(s).name '. Coregistration skipped!'])
					errors{size(errors,1)+1,1} = ['Multiple T1 images found for ' cor.subjs(s).name '. Coregistration skipped!'];
					continue
				else
					T1img = fullfile(cor.structdir, cor.subjs(s).name, temp.name);
				end

				[~, file_name, ~] = fileparts(T1img);

				if (~isempty(file_name)), % if T1 image exists
					matlabbatch{1}.spm.spatial.coreg.estimate.ref = {T1img}; % T1 image path
					matlabbatch{1}.spm.spatial.coreg.estimate.source = {meanimg}; % mean image path
					matlabbatch{1}.spm.spatial.coreg.estimate.other = imgs; % functional images paths

					matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi'; % SPM default parameters
					matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
					matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
					matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

					savefile = ['coregistration_', cor.subjs(s).name, '_run', num2str(r)]; % save matlabbatch as coregistration_(subject)_(run).mat
					save(savefile,'matlabbatch')
					spm_jobman('run',matlabbatch); % run SPM job
					count = count + 1;
					clear('matlabbatch');
				else
					warning(['No T1 image found for ' cor.subjs(s).name '. Coregistration skipped!'])
				end
			end
	end % end run loop
end


% 
% function coregistration(cor)
% fcn_name= 'Coregistration';
% errors = {};
% count = 0;
% 
% for s = 1:size(cor.subjs,1) % start subject loop
%     norundirs = 0;
%     subjdir = fullfile (cor.funcdir, cor.subjs(s).name);
%     if ~isempty(cor.run)
%         runlist = dir(fullfile(subjdir, cor.run));
%         if size(runlist, 1) == 0
%             warning(['No runs found for ' cor.subjs(s).name '. Coregistration skipped!'])
%             errors{size(errors,1)+1,1} = ['No runs found for ' cor.subjs(s).name '. Coregistration skipped!'];
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
%         if cor.newonly == 1
%             if isempty(dir(fullfile(cor.structdir, cor.subjs(s).name, [cor.t1prefix2 cor.t1prefix1 cor.subjs(s).name '*' cor.t1suffix '_seg_sn.mat']))) % Looks for segmentation file since coregistration doesn't create any files.
%                 imglist = dir(fullfile(rundir, ['a' cor.scan]));
%                 if size(imglist,1) == 0
%                     imglist = dir(fullfile(rundir, cor.scan));
%                     warning(['No slice timing corrected files found for ' cor.subjs(s).name '. Used raw files!'])
%                     errors{size(errors,1)+1,1} = ['No slice timing corrected files found for ' cor.subjs(s).name '. Used raw files!'];
%                 end
%                 imgs = cell(size(imglist,1),1);
%                 for j = 1:size(imglist,1)
%                     imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
%                 end
%             else
%                 continue
%             end
%         elseif cor.newonly == 0
%             imglist = dir(fullfile(rundir, ['a' cor.scan]));
%             if size(imglist,1) == 0
%                 imglist = dir(fullfile(rundir, cor.scan));
%             end
%             imgs = cell(size(imglist,1),1);
%             for j = 1:size(imglist,1)
%                 imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
%             end
%         end
%         if ~cellfun('isempty',imgs)
%             meanimg = fullfile(rundir, ['mean' imglist(1).name ',1']);
%             
%             temp = dir(fullfile(cor.structdir, cor.subjs(s).name, [cor.t1prefix2 cor.t1prefix1 cor.subjs(s).name '*' cor.t1suffix cor.t1ext]));
%             if size(temp,1) == 0
%                 disp(['No T1 image found for ' cor.subjs(s).name '. Coregistration skipped!'])
%                 errors{size(errors,1)+1,1} = ['No T1 image found for ' cor.subjs(s).name '. Coregistration skipped!'];
%                 continue
%             elseif size(temp,1) > 1
%                 warning(['Multiple T1 images found for ' cor.subjs(s).name '. Coregistration skipped!'])
%                 errors{size(errors,1)+1,1} = ['Multiple T1 images found for ' cor.subjs(s).name '. Coregistration skipped!'];
%                 continue
%             else
%                 T1img = fullfile(cor.structdir, cor.subjs(s).name, temp.name);
%             end
% 
%             [~, file_name, ~] = fileparts(T1img);
% 
%             if (~isempty(file_name)), % if T1 image exists
%                 matlabbatch{1}.spm.spatial.coreg.estimate.ref = {T1img}; % T1 image path
%                 matlabbatch{1}.spm.spatial.coreg.estimate.source = {meanimg}; % mean image path
%                 matlabbatch{1}.spm.spatial.coreg.estimate.other = imgs; % functional images paths
% 
%                 matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi'; % SPM default parameters
%                 matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
%                 matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
%                 matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% 
%                 savefile = ['coregistration_', cor.subjs(s).name, '_run', num2str(r)]; % save matlabbatch as coregistration_(subject)_(run).mat
%                 save(savefile,'matlabbatch')
%                 spm_jobman('run',matlabbatch); % run SPM job
%                 count = count + 1;
%                 clear('matlabbatch');
%             else
%                 warning(['No T1 image found for ' cor.subjs(s).name '. Coregistration skipped!'])
%             end
%         end
%     end % end run loop
% end % end subject loop
% 
% error_check(fcn_name, errors, count);
% 
% end