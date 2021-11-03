function preprocess_run(run_struct, handles)
	%Runs the selected processes
        
    if run_struct.slicetiming == 1
		run_struct.numslices = handles.numslices;
		run_struct.TR = handles.TR;
		run_struct.scorder= handles.scorder;
		run_struct.refslice = handles.refslice;
		if ~exist([pwd filesep 'SliceTiming'], 'dir') %make sure there are no directories called 'SliceTiming' on path that are not wanted
			mkdir SliceTiming
		end
		cd SliceTiming
		%slicetiming(run_struct)
		run_process(run_struct, 'Slice_Timing');
		cd ..
	end

	if run_struct.realign== 1
		if ~exist([pwd filesep 'Realignment'], 'dir')
			mkdir Realignment
		end
		cd Realignment
		%realignment(run_struct)
		run_process(run_struct, 'Realignment');
		cd ..
	end

	if run_struct.coreg== 1
		if ~exist([pwd filesep 'Coregistration'], 'dir')
			mkdir Coregistration
		end
		cd Coregistration
		%coregistration(run_struct)
		run_process(run_struct, 'Coregistration');
		cd ..
    end

	if run_struct.norm == 1
		run_struct.voxelsize = handles.voxelsize;
		if ~exist([pwd filesep 'Normalization'], 'dir')
			mkdir Normalization
		end
		cd Normalization
		%normalization(run_struct)
		run_process(run_struct, 'Normalization');
		cd ..
	end    

	if run_struct.smooth == 1
		
		run_struct.kernelsize = handles.kernelsize;
		if ~exist([pwd filesep 'Smoothing'], 'dir')
			mkdir Smoothing
		end
		cd Smoothing
		%smoothing(run_struct)
		run_process(run_struct, 'Smoothing');
		cd ..
    end
end

function run_process(run_struct, fcn_name)
	errors={};
	count = 0;
    for s = 1: size(run_struct.subjs,1)
		norundirs = 0;
		subjdir = fullfile(run_struct.funcdir, run_struct.subjs(s).name);
		if ~isempty(run_struct.run)
			runlist = dir(fullfile(subjdir, run_struct.run));
			if size(runlist, 1) == 0
				warning(['No runs found for ' run_struct.subjs(s).name ' ' strcat(fcn_name, ' skipped!')])
				errors{size(errors,1)+1,1} = ['No runs found for ' run_struct.subjs(s).name '. ' strcat(fcn_name, ' skipped!')];
				continue
			end            
		else
			norundirs = 1;
			runlist = 1;
        end
        switch(fcn_name) 
			case 'Slice_Timing'
				[count, errors] = slicetiming(runlist, norundirs, subjdir, count, errors, s, run_struct);
			case 'Realignment'
				[count, errors] = realignment(runlist, norundirs, subjdir, count, errors, s, run_struct);
			case 'Coregistration'
				[count, errors] = coregistration(runlist, norundirs, subjdir, count, errors, s, run_struct);
			case 'Normalization' 
				[count, errors] = normalization(runlist, norundirs, subjdir, count, errors, s, run_struct);
        end
    end
    
    switch(fcn_name) 
		case 'Smoothing'
			[count, errors] = smoothing(count, errors, run_struct);	
    end
	
error_check(fcn_name, errors, count);

	
end

