function checkHM(chk)

disp('Checking Head Movement ...')

final_max={'SubjectID', 'MaxTrX', 'MaxTrY', 'MaxTrZ', 'MaxRtPitch', 'MaxRtRoll', 'MaxRtYaw'};
s_info=cell(1,7);
max_s=cell(1,7);
max_check=[];
j=1;

    for s = 1:size(chk.subjs,1) % start subject loop
        j=j+1;
        norundirs = 0;
        subjdir=fullfile(chk.funcdir, chk.subjs(s).name); % subject directory
        if ~isempty(chk.run)
            runlist = dir(fullfile(subjdir, chk.run));
            if size(runlist, 1) == 0
                warning(['No runs found for ' chk.subjs(s).name '. Check HM skipped!'])
                continue
            end            
        else
            norundirs = 1;
            runlist = 1;
        end
        for r = 1:size(runlist,1) % start run loop
            if norundirs == 1
                rundir = subjdir;
            else
                rundir = fullfile(subjdir, runlist(r).name);
            end

            if ~isempty(dir(fullfile(rundir, 'rp*.txt')))
               rp_file_name = dir(fullfile(rundir, 'rp*.txt'));
               contents = load(fullfile(rundir, rp_file_name.name));      

                s_info(1,1) = {[chk.subjs(s).name, '_run', num2str(r)]};
                final_max=[final_max; s_info];

                max_s = max(abs(contents));
                max_s(1,4)=(max_s(1,4)*180)/pi;
                max_s(1,5)=(max_s(1,5)*180)/pi;
                max_s(1,6)=(max_s(1,6)*180)/pi;

                max_check=[max_check; max_s];
                final_max(j,2:end)=num2cell(max_s);

                if r ~= size(runlist,1)
                    j=j+1;
                end
            else
                if r ~= size(runlist,1)
                    j=j-1;
                end
            end
        end
    end
    
    ds=cell2dataset(final_max); % cell2dataset requires statistics toolbox!
    export(ds,'file', 'HMvalues.csv', 'delimiter', ',');
    disp('Done! Please see HMvalues.csv')
end