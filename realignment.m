%% DOCUMENTATION

% AUTHORS: Katie Lavigne
% DATE: February 3rd, 2016
% 
% FILE:     realignment.m
% PURPOSE:  Performs fMRI realignment through SPM.
% USAGE:    Click on checkbox in fMRI GUI and click Run.
% 
% DESCRIPTION: This script realigns the functional images and outputs a 
% mean image (prefix 'r') and a realignment parameters text file (rp*.txt).

% Note: There are no options for this step. Any non-default parameters are based on the fMRI Preprocessing GUI found at
% cfrifs02/WoodwardLab/Manual/PreprocessingManual/woodwardLab_preprocessingManual_sept17_2014.pdf.
% 
function [count, errors] = realignment(runlist, norundirs, subjdir, count, errors, s, rlgn)
	
    l = 1;

    for r = 1:size(runlist,1)
        if norundirs == 1
            rundir = subjdir;
        else
            rundir = fullfile(subjdir, runlist(r).name);
        end
        if rlgn.newonly == 1
            if isempty(dir(fullfile(rundir, ['meana' rlgn.scan])))
                imglist = dir(fullfile(rundir, ['a' rlgn.scan]));
                if size(imglist,1) == 0
                    imglist = dir(fullfile(rundir, rlgn.scan));
                end
                imgs = cell(size(imglist,1),1);
                for j = 1:size(imglist, 1)
                    imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
                end
            else
                continue
            end                
        elseif rlgn.newonly == 0
            imglist = dir(fullfile(rundir, ['a' rlgn.scan]));
            if size(imglist,1) == 0
                imglist = dir(fullfile(rundir, rlgn.scan));
            end
            imgs = cell(size(imglist,1),1);
            for j = 1:size(imglist, 1)
                imgs{j} = fullfile(rundir, [imglist(j).name, ',1']);
            end
        end

        if ~cellfun('isempty',imgs)
            matlabbatch{1}.spm.spatial.realign.estwrite.data = {imgs}; % image list

            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9; % SPM default parameters unless specified
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1]; % mean image only
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
            matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

            savefile = ['realignment_', rlgn.subjs(s).name, '_run', num2str(r)]; % save matlabbatch as realignment_(subject)_(run).mat
            save(savefile,'matlabbatch')
            spm_jobman('run',matlabbatch); % run SPM job
            flag = getappdata(0, 'flag');
            if (flag == 1)
                 warning_dir.(matlab.lang.makeValidName(num2str(l))) = rundir;
                 l = l +1;
            end
           count = count + 1;
           clear('matlabbatch');
        else
            warning(['No data found for ' rlgn.subjs(s).name ' run' num2str(r) '. Realignment skipped!'])
            errors{size(errors,1)+1,1} = ['No data found for ' rlgn.subjs(s).name ' run' num2str(r) '. Realignment skipped!'];
        end
    end

    if exist('warning_dir','var')
        save warning_dir warning_dir
    end

end
% function realignment(rlgn)
% fcn_name = 'Realignment';
% l = 1;
% errors = {};
% count = 0;
% 
% for s = 1: size(rlgn.subjs,1)
%     norundirs = 0;
%     subjdir = fullfile(rlgn.funcdir, rlgn.subjs(s).name);
%     if ~isempty(rlgn.run)
%         runlist = dir(fullfile(subjdir, rlgn.run));
%         if size(runlist, 1) == 0
%             warning(['No runs found for ' rlgn.subjs(s).name '. Realignment skipped!'])
%             errors{size(errors,1)+1,1} = ['No runs found for ' rlgn.subjs(s).name '. Realignment skipped!'];
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
%         if rlgn.newonly == 1
%             if isempty(dir(fullfile(rundir, ['meana' rlgn.scan])))
%                 imglist = dir(fullfile(rundir, ['a' rlgn.scan]));
%                 if size(imglist,1) == 0
%                     imglist = dir(fullfile(rundir, rlgn.scan));
%                 end
%                 imgs = cell(size(imglist,1),1);
%                 for j = 1:size(imglist, 1)
%                     imgs{j} = fullfile(rundir, [imglist(j).name ',1']);
%                 end
%             else
%                 continue
%             end                
%         elseif rlgn.newonly == 0
%             imglist = dir(fullfile(rundir, ['a' rlgn.scan]));
%             if size(imglist,1) == 0
%                 imglist = dir(fullfile(rundir, rlgn.scan));
%             end
%             imgs = cell(size(imglist,1),1);
%             for j = 1:size(imglist, 1)
%                 imgs{j} = fullfile(rundir, [imglist(j).name, ',1']);
%             end
%         end
%         
%         if ~cellfun('isempty',imgs)
%             matlabbatch{1}.spm.spatial.realign.estwrite.data = {imgs}; % image list
% 
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9; % SPM default parameters unless specified
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
%             matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
%             matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1]; % mean image only
%             matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
%             matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
%             matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
%             matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
%       
%             savefile = ['realignment_', rlgn.subjs(s).name, '_run', num2str(r)]; % save matlabbatch as realignment_(subject)_(run).mat
%             save(savefile,'matlabbatch')
%             spm_jobman('run',matlabbatch); % run SPM job
%             flag = getappdata(0, 'flag');
%             if (flag == 1)
%                  warning_dir.(matlab.lang.makeValidName(num2str(l))) = rundir;
%                  l = l +1;
%             end
%            count = count + 1;
%            clear('matlabbatch');
%         else
%             warning(['No data found for ' rlgn.subjs(s).name ' run' num2str(r) '. Realignment skipped!'])
%             errors{size(errors,1)+1,1} = ['No data found for ' rlgn.subjs(s).name ' run' num2str(r) '. Realignment skipped!'];
%         end
%     end
% end
% 
% if exist('warning_dir','var')
%     save warning_dir warning_dir
% end
% 
% error_check(fcn_name, errors, count);
% 
% end