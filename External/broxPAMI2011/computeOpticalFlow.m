
function  computeOpticalFlow(frames,opticalflow_path )    
   
  
    filename = fullfile( opticalflow_path, 'LDOF_opticalFlow_pairwise.mat' );
    
    if( exist( filename, 'file' ) )
        % Shot already processed, skip
        fprintf('computeOpticalFlow: Data processed, skipping...\n' );
        return;
    else               
        [flow,totalTimeTaken]=computeBroxLDOF(frames);
         
        save( filename, 'flow' );
    end
    
    fprintf( 'computeOpticalFlow:  finished processing\n');
    clear frames 
    
end
