
function [flow,totalTimeTaken] = computeBroxLDOF(frames)
    
    numOfFrames=length(frames);
    
    flow = cell(1,numOfFrames-1);     

    totalTimeTaken = 0;

    
    
    for frame_it=1:numOfFrames-1
        tic
        currImage =double(frames{1,frame_it});
        nextImage =double(frames{1,frame_it+1});         
         
        fprintf('computeBroxPAMI2011Flow: Computing optical flow of pair: %i of %i...\n ', ...
                frame_it, numOfFrames-1 );
        flowframe= mex_LDOF( currImage, nextImage);  
        flow{ frame_it }( :, :, 1 ) =int16(flowframe( :, :, 2 ));  %horizational
        flow{ frame_it }( :, :, 2 ) =int16( flowframe( :, :, 1 ));  %vertial
          
        timeTaken = toc;
        totalTimeTaken = totalTimeTaken + timeTaken;
        
        clear currImage nextImage flowframe
        
    end
      fprintf( 'computeBroxPAMI2011Flow: Total time taken: %.2f sec\n', ...
            totalTimeTaken );
        fprintf( 'computeBroxPAMI2011Flow: Average time taken per frame: %.2f sec\n', ...
            totalTimeTaken /( numOfFrames-1) ); 
    
    clear frames
end
