function error_check(fcn_name, error_list, count )

%Determines if there are any errors to report
	if count <1 
		warning(upper(strcat(fcn_name, ' did not run because no (new) subjects were found!')))
	end
	
	if ~isempty(error_list)
		fid2=fopen(strcat(fcn_name, '_errors.txt'), 'wt');
		for k = 1: size(error_list,1)
			fprintf(fid2,'%s\r\n',error_list{k,:});
		end
		fclose(fid2);
	end


end

