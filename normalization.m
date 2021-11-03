%% DOCUMENTATION

% AUTHORS: Katie Lavigne
% DATE: February 3rd, 2016
% 
% FILE:     normalization.m
% PURPOSE:  Performs fMRI normalization through SPM.
% USAGE:    Click on checkbox in fMRI GUI and click Run.
% 
% DESCRIPTION: This script normalizes the functional scans to the T1 template
% OR normalizes the functional scans to the EPI template (if it cannot find
% a structural image). When you click on the checkbox, you can input the 
% desired voxel size (must be in specific format: 2 2 2 or 3 3 3 etc). 
% It will output functional images with the prefix 'w', which are used in the next step.

% Note: Any non-default parameters are based on the fMRI Preprocessing GUI found at
% cfrifs02/WoodwardLab/Manual/PreprocessingManual/woodwardLab_preprocessingManual_sept17_2014.pdf.


function [count, errors] = normalization(runlist, norundirs, subjdir, count, errors, s, norm)
dirnorm = 0;
all_runs = {};
	for r = 1:size(runlist,1)
			if norundirs == 1
				rundir = subjdir;
			else
				rundir = fullfile(subjdir, runlist(r).name);
			end
			if norm.newonly == 1
				if isempty(dir(fullfile(rundir, ['w*' norm.scan])));
					imglist = dir(fullfile(rundir, ['a' norm.scan]));
					if size(imglist,1) == 0
						imglist = dir(fullfile(rundir, norm.scan));
					end
					tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
					for j = 1:size(imglist,1)
						tempimgs{j} = fullfile(rundir, [imglist(j).name, ',1']); % creates array listing full paths to each image in current run
					end
					imgs{r} = tempimgs;  %#ok<*SAGROW>
				else % if output files (wa*.nii) exist
					continue
				end
			elseif norm.newonly == 0
				imglist = dir(fullfile(rundir, ['a' norm.scan]));
				if size(imglist,1) == 0
					imglist = dir(fullfile(rundir, norm.scan));
				end
				tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
				for j = 1:size(imglist,1)
					tempimgs{j} = fullfile(rundir, [imglist(j).name, ',1']); % creates array listing full paths to each image in current run
				end
				imgs{r} = tempimgs;  %#ok<*SAGROW>
			end % end subject type if

			temp = dir(fullfile(norm.structdir, norm.subjs(s).name, [norm.t1prefix2 norm.t1prefix norm.subjs(s).name '*' norm.t1suffix '_seg_sn.mat']));
			if size(temp,1) == 0
				warning(['No T1 image found for ' norm.subjs(s).name '. Direct Normalization will be performed!'])
				dirnorm = 1;
				T1img = '';
			elseif size(temp,1) > 1
				warning(['Multiple T1 images found for ' norm.subjs(s).name '. Normalization skipped!'])
				errors{size(errors,1)+1,1} = ['Multiple T1 images found for ' norm.subjs(s).name '. Normalization skipped!'];
				continue
			else
				T1img = fullfile(norm.structdir, norm.subjs(s).name, temp.name);
			end

			[~, file_name, ~] = fileparts(T1img);

			if ~cellfun('isempty',imgs)
				if (isempty(file_name) || dirnorm == 1), % if T1img does not exist
					meanimg = fullfile(rundir, ['mean' imglist(1).name ',1']);
					epi=fullfile(norm.spmdir,'templates', 'EPI.nii,1');

					matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {meanimg};
					matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
					matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = imgs{r};
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {epi};
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
					matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
					matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
					matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -70
																				 78 76 85];
					matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
					matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
					matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
					matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

					savefile = ['dir-normalization_', norm.subjs(s).name,'_run', num2str(r)]; % save matlabbatch as dir-normalization_(subject)_(run).mat
					save(savefile,'matlabbatch')
					spm_jobman('run',matlabbatch); % run SPM job
					count = count + 1;
					clear('matlabbatch');
				   continue;
				end
				all_runs = [all_runs; imgs{r}]; %#ok<AGROW>
				if (r == size(runlist, 1))
					matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {T1img}; % T1 seg sn
					matlabbatch{1}.spm.spatial.normalise.write.subj.resample = all_runs; % image list
					matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0; % default SPM parameters unless specified
					matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -70 % bounding box extended to include cerebellum (-70)
																			  78 76 85];
					matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2]; % Voxel sizes = 2x2x2
					matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
					matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
					matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';

					savefile = ['ind-normalization_', norm.subjs(s).name]; % save matlabbatch as ind-normalization_(subject).mat
					save(savefile,'matlabbatch')
					spm_jobman('run',matlabbatch); % run SPM job
					count = count + 1;
					clear('matlabbatch');
				end
			else
				warning(['No scans found for ' norm.subjs(s).name '. Normalization skipped!'])
			end
		end % end run loop
end

% function normalization(norm)
% fcn_name = 'Normalization';
% errors = {};
% count = 0;
% 
% for s = 1:size(norm.subjs,1)
%     dirnorm = 0;
%     all_runs = {};
%     norundirs = 0;
%     subjdir = fullfile(norm.funcdir, norm.subjs(s).name);
%     if ~isempty(norm.run)
%         runlist = dir(fullfile(subjdir, norm.run));
%         if size(runlist, 1) == 0
%             warning(['No runs found for ' norm.subjs(s).name '. Normalization skipped!'])
%             errors{size(errors,1)+1,1} = ['No runs found for ' norm.subjs(s).name '. Normalization skipped!'];
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
%         if norm.newonly == 1
%             if isempty(dir(fullfile(rundir, ['w*' norm.scan])));
%                 imglist = dir(fullfile(rundir, ['a' norm.scan]));
%                 if size(imglist,1) == 0
%                     imglist = dir(fullfile(rundir, norm.scan));
%                 end
%                 tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
%                 for j = 1:size(imglist,1)
%                     tempimgs{j} = fullfile(rundir, [imglist(j).name, ',1']); % creates array listing full paths to each image in current run
%                 end
%                 imgs{r} = tempimgs;  %#ok<*SAGROW>
%             else % if output files (wa*.nii) exist
%                 continue
%             end
%         elseif norm.newonly == 0
%             imglist = dir(fullfile(rundir, ['a' norm.scan]));
%             if size(imglist,1) == 0
%                 imglist = dir(fullfile(rundir, norm.scan));
%             end
%             tempimgs=cell(size(imglist,1),1); % creates cell array size of number images
%             for j = 1:size(imglist,1)
%                 tempimgs{j} = fullfile(rundir, [imglist(j).name, ',1']); % creates array listing full paths to each image in current run
%             end
%             imgs{r} = tempimgs;  %#ok<*SAGROW>
%         end % end subject type if
%         
%         temp = dir(fullfile(norm.structdir, norm.subjs(s).name, [norm.t1prefix2 norm.t1prefix norm.subjs(s).name '*' norm.t1suffix '_seg_sn.mat']));
%         if size(temp,1) == 0
%             warning(['No T1 image found for ' norm.subjs(s).name '. Direct Normalization will be performed!'])
%             dirnorm = 1;
%             T1img = '';
%         elseif size(temp,1) > 1
%             warning(['Multiple T1 images found for ' norm.subjs(s).name '. Normalization skipped!'])
%             errors{size(errors,1)+1,1} = ['Multiple T1 images found for ' norm.subjs(s).name '. Normalization skipped!'];
%             continue
%         else
%             T1img = fullfile(norm.structdir, norm.subjs(s).name, temp.name);
%         end
%    
%         [~, file_name, ~] = fileparts(T1img);
%     
%         if ~cellfun('isempty',imgs)
%             if (isempty(file_name) || dirnorm == 1), % if T1img does not exist
%                 meanimg = fullfile(rundir, ['mean' imglist(1).name ',1']);
%                 epi=fullfile(norm.spmdir,'templates', 'EPI.nii,1');
% 
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {meanimg};
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = imgs{r};
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {epi};
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -70
%                                                                              78 76 85];
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [2 2 2];
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
%                 matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';
% 
%                 savefile = ['dir-normalization_', norm.subjs(s).name,'_run', num2str(r)]; % save matlabbatch as dir-normalization_(subject)_(run).mat
%                 save(savefile,'matlabbatch')
%                 spm_jobman('run',matlabbatch); % run SPM job
%                 count = count + 1;
%                 clear('matlabbatch');
%                continue;
%             end
%             all_runs = [all_runs; imgs{r}]; %#ok<AGROW>
%             if (r == size(runlist, 1))
%                 matlabbatch{1}.spm.spatial.normalise.write.subj.matname = {T1img}; % T1 seg sn
%                 matlabbatch{1}.spm.spatial.normalise.write.subj.resample = all_runs; % image list
%                 matlabbatch{1}.spm.spatial.normalise.write.roptions.preserve = 0; % default SPM parameters unless specified
%                 matlabbatch{1}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -70 % bounding box extended to include cerebellum (-70)
%                                                                           78 76 85];
%                 matlabbatch{1}.spm.spatial.normalise.write.roptions.vox = [2 2 2]; % Voxel sizes = 2x2x2
%                 matlabbatch{1}.spm.spatial.normalise.write.roptions.interp = 1;
%                 matlabbatch{1}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
%                 matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix = 'w';
% 
%                 savefile = ['ind-normalization_', norm.subjs(s).name]; % save matlabbatch as ind-normalization_(subject).mat
%                 save(savefile,'matlabbatch')
%                 spm_jobman('run',matlabbatch); % run SPM job
%                 count = count + 1;
%                 clear('matlabbatch');
%             end
%         else
%             warning(['No scans found for ' norm.subjs(s).name '. Normalization skipped!'])
%         end
%     end % end run loop
% end
% error_check(fcn_name, errors, count);

%Send email when complete
%myaddress = '';
%mypassword = '';

%setpref('Internet','E_mail',myaddress);
%setpref('Internet','SMTP_Server','smtp.gmail.com');
%setpref('Internet','SMTP_Username',myaddress);
%setpref('Internet','SMTP_Password',mypassword);

%props = java.lang.System.getProperties;
%props.setProperty('mail.smtp.auth','true');
%props.setProperty('mail.smtp.socketFactory.class', ...
%                  'javax.net.ssl.SSLSocketFactory');
%props.setProperty('mail.smtp.socketFactory.port','465');

%sendmail(myaddress, 'SPM Normalization Complete', 'Normalization has completed running!');

%end