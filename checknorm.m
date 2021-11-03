function checknorm(chk)

    T1template = fullfile(chk.spmdir, 'templates', 'T1.nii');

    for s = 1:size(chk.subjs,1) % start subject loop
        T1img = dir(fullfile(chk.structdir, chk.subjs(s).name, [chk.t1prefix2 chk.t1prefix chk.subjs(s).name '*' chk.t1suffix chk.t1ext]));
        if isempty(T1img)
            T1img = '';
            T1caption = '';
        else
            T1caption = [chk.subjs(s).name, ' T1 Image'];
            T1img = fullfile(chk.structdir, chk.subjs(s).name, T1img.name);
        end
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
        fimgs = [];
        fcaptions = [];
        for r = 1:size(runlist,1) % start run loop
            if norundirs == 1
                rundir = subjdir;
            else
                rundir = fullfile(subjdir, runlist(r).name);
            end

            temp = dir(fullfile(rundir, 'w*150.nii'));
            if isempty(temp)
                continue
            end
            fimgs = strvcat(fimgs, fullfile(rundir,temp.name));
            fcaptions = strvcat(fcaptions, [chk.subjs(s).name, ' Run ' num2str(r)]);
        end
        images=strvcat(T1template, T1img , fimgs);
        captions = strvcat('SPM T1 Template', T1caption, fcaptions);
        spm_check_registration(images, captions)
        h = spm_figure('GetWin', 'Graphics');
        waitfor(h)
    end
end