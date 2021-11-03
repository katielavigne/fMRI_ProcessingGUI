% %% DOCUMENTATION
% 
% % AUTHORS: Katie Lavigne
% % DATE: February 4th, 2016
% % 
% % FILE:     slicetiming.m
% % PURPOSE:  Performs correction for fMRI slice timing acquisition through SPM.
% % USAGE:    Click on checkbox in fMRI GUI and click Run.
% % 
% % DESCRIPTION: This script corrects fMRI functional images for slice timing 
% % acquisition by subject and run. When you click on the checkbox, you will
% % need to input the scanning parameters. These can be found in the task protocol 
% % dump (ask the MRI techs for it) or less easily in the PAR files. The script outputs
% % slice-timing corrected functional scans with the prefix 'a'.
% 
% % Note: Any non-default parameters are based on the fMRI Preprocessing GUI found at
% % cfrifs02/WoodwardLab/Manual/PreprocessingManual/woodwardLab_preprocessingManual_sept17_2014.pdf.

function [count, errors] = slicetiming(runlist, norundirs, subjdir, count, errors, s,  st)
	for r = 1:size(runlist,1)
				if norundirs == 1
					rundir = subjdir;
				else
					rundir = fullfile(subjdir, runlist(r).name);
				end
				if st.newonly == 1
					if isempty(dir(fullfile(rundir, ['a' st.scan])))
						imglist = dir(fullfile(rundir, st.scan));
						imgs = cell(size(imglist,1),1);
						for j = 1:size(imglist, 1)
							imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
						end
					else
						continue
					end           
				elseif st.newonly == 0
					imglist = dir(fullfile(rundir, st.scan));
					imgs = cell(size(imglist,1),1);
					for j = 1:size(imglist, 1)
						imgs{j} = fullfile(rundir, [imglist(j).name, ',1']);
					end
				end

				if ~cellfun('isempty',imgs)
					matlabbatch{1}.spm.temporal.st.scans = {imgs}; % image list

					matlabbatch{1}.spm.temporal.st.nslices = st.numslices; % number of slices
					matlabbatch{1}.spm.temporal.st.tr = st.TR; % TR
					matlabbatch{1}.spm.temporal.st.ta = matlabbatch{1}.spm.temporal.st.tr-(matlabbatch{1}.spm.temporal.st.tr/matlabbatch{1}.spm.temporal.st.nslices); % TE
					matlabbatch{1}.spm.temporal.st.so = st.scorder; % scan order
					matlabbatch{1}.spm.temporal.st.refslice = st.refslice; % reference slice
					matlabbatch{1}.spm.temporal.st.prefix = 'a'; % prefix

					savefile = ['slicetiming_', st.subjs(s).name, '_run', num2str(r)]; % save matlabbatch as slicetiming_(subject)_(run).mat
					save(savefile,'matlabbatch')
					spm_jobman('run',matlabbatch); % run SPM job
					count = count + 1;
					clear('matlabbatch');
				else
					warning(['No data found for ' st.subjs(s).name ' run' num2str(r) '. Slice Timing Correction skipped!'])
					errors{size(errors,1)+1,1} = ['No data found for ' st.subjs(s).name ' run' num2str(r) '. Slice Timing Correction skipped!'];
				end
	end
end

% %function slicetiming(st)
% 	errors={};
% 	count = 0;
% 	fcn_name = 'Slice_Timing';
% 
% 	for s = 1: size(st.subjs,1)
% 		norundirs = 0;
% 		subjdir = fullfile(st.funcdir, st.subjs(s).name);
% 		if ~isempty(st.run)
% 			runlist = dir(fullfile(subjdir, st.run));
% 			if size(runlist, 1) == 0
% 				warning(['No runs found for ' st.subjs(s).name '. Slice Timing Correction skipped!'])
% 				errors{size(errors,1)+1,1} = ['No runs found for ' st.subjs(s).name '. Slice Timing Correction skipped!'];
% 				continue
% 			end            
% 		else
% 			norundirs = 1;
% 			runlist = 1;
% 		end
% % 		for r = 1:size(runlist,1)
% 				if norundirs == 1
% 					rundir = subjdir;
% 				else
% 					rundir = fullfile(subjdir, runlist(r).name);
% 				end
% 				if st.newonly == 1
% 					if isempty(dir(fullfile(rundir, ['a' st.scan])))
% 						imglist = dir(fullfile(rundir, st.scan));
% 						imgs = cell(size(imglist,1),1);
% 						for j = 1:size(imglist, 1)
% 							imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
% 						end
% 					else
% 						continue
% 					end           
% 				elseif st.newonly == 0
% 					imglist = dir(fullfile(rundir, st.scan));
% 					imgs = cell(size(imglist,1),1);
% 					for j = 1:size(imglist, 1)
% 						imgs{j} = fullfile(rundir, [imglist(j).name, ',1']);
% 					end
% 				end
% 
% 				if ~cellfun('isempty',imgs)
% 					matlabbatch{1}.spm.temporal.st.scans = {imgs}; % image list
% 
% 					matlabbatch{1}.spm.temporal.st.nslices = st.numslices; % number of slices
% 					matlabbatch{1}.spm.temporal.st.tr = st.TR; % TR
% 					matlabbatch{1}.spm.temporal.st.ta = matlabbatch{1}.spm.temporal.st.tr-(matlabbatch{1}.spm.temporal.st.tr/matlabbatch{1}.spm.temporal.st.nslices); % TE
% 					matlabbatch{1}.spm.temporal.st.so = st.scorder; % scan order
% 					matlabbatch{1}.spm.temporal.st.refslice = st.refslice; % reference slice
% 					matlabbatch{1}.spm.temporal.st.prefix = 'a'; % prefix
% 
% 					savefile = ['slicetiming_', st.subjs(s).name, '_run', num2str(r)]; % save matlabbatch as slicetiming_(subject)_(run).mat
% 					save(savefile,'matlabbatch')
% 					spm_jobman('run',matlabbatch); % run SPM job
% 					count = count + 1;
% 					clear('matlabbatch');
% 				else
% 					warning(['No data found for ' st.subjs(s).name ' run' num2str(r) '. Slice Timing Correction skipped!'])
% 					errors{size(errors,1)+1,1} = ['No data found for ' st.subjs(s).name ' run' num2str(r) '. Slice Timing Correction skipped!'];
% 				end
% 	end
% % 	end
% error_check(fcn_name, errors, count);
% 
% 	
% end
% %