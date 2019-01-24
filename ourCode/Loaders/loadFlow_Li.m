% Function to load the stored optical flow based on some given method
% option :LDOF_opticalFlow_multi.mat
%         LDOF_opticalFlow_multi_double
function result = loadFlow_Li(opticalflow_path )

    %file = fullfile(opticalflow_path,'LDOF_opticalFlow_multi.mat');
    file = fullfile(opticalflow_path);
    if( exist( file, 'file' ) )
        result = load( file );

    else
        warning( '%s not found\n', file );
        result = [];
    end

end
