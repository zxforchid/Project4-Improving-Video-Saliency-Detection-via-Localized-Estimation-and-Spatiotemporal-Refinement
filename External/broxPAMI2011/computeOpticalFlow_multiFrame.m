
function [flow,totalTimeTaken] = computeOpticalFlow_multiFrame(frames,opticalflow_path )    
   
    if( ~exist( opticalflow_path, 'dir' ) )
        mkdir( opticalflow_path );
        addpath(genpath(opticalflow_path));
    end
    
    
    fprintf('computeOpticalFlow: Processing\n');
%   filename = fullfile( opticalflow_path, 'LDOF_opticalFlow_multi_double' );
    filename1 = fullfile( opticalflow_path, 'LDOF_opticalFlow_multi' );
    if( exist( filename1, 'file' ) )
        % Shot already processed, skip
        fprintf('computeOpticalFlow: Data processed, skipping...\n');
        return;
    else               
        [flow,totalTimeTaken]=computeBroxLDOF_multiFrame(frames);         
        save( filename1, 'flow' );
        fprintf( 'compute MultiFrame OpticalFlow: finished processing\n');
        computeOpticalFlow(frames,opticalflow_path);
        fprintf( 'compute pairWise OpticalFlow: finished processing\n');
    end
      
%       filename1 = fullfile( opticalflow_path, 'LDOF_opticalFlow_multi.mat' );
%       [flow,totalTimeTaken]=computeBroxLDOF_multiFrame(frames); 
%       save( filename1, 'flow' );
%       fprintf( 'compute MultiFrame OpticalFlow: finished processing\n');
%       computeOpticalFlow(frames,opticalflow_path);
%       fprintf( 'compute pairWise OpticalFlow: finished processing\n');
    
end
