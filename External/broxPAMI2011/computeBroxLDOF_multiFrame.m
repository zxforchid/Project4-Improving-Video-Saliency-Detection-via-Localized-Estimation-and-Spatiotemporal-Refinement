
function [flow,totalTimeTaken] = computeBroxLDOF_multiFrame(frames)
    
    numOfFrames=length(frames);
    
    flow = cell(1,numOfFrames-1);     

    totalTimeTaken = 0;
    temporalWindows=5;
    for frame_it=1:numOfFrames-1            
        tic
        fprintf('computeBroxPAMI2011Flow: Computing optical flow of pair: %i of %i...\n', ...
                frame_it, numOfFrames-1 );
        currImage =double(frames{1,frame_it});
        [h,w,~]=size(currImage);
        H=zeros(h,w);
        W=zeros(h,w); 
        if(frame_it+temporalWindows)>numOfFrames  
            temporalWindows=numOfFrames-frame_it;     
        end
        
        for i=1:temporalWindows
                nextImage =double(frames{1,frame_it+i});
                flowframe= mex_LDOF( currImage, nextImage);  
                W= flowframe( :, :, 2 )+W;  %    V
                H= flowframe( :, :, 1 )+H;  %    H    
                clear nextImage
        end
         
        flow{ frame_it }( :, :, 1 )=int16(H/temporalWindows);
        flow{ frame_it }( :, :, 2 )=int16(W/temporalWindows); 
        
        timeTaken = toc;
        totalTimeTaken = totalTimeTaken + timeTaken;
        
        clear currImage W H
    end
     fprintf( 'computeBroxPAMI2011Flow: Total time taken: %.2f sec\n', ...
            totalTimeTaken );
     fprintf( 'computeBroxPAMI2011Flow: Average time taken per frame: %.2f sec\n', ...
            totalTimeTaken /( numOfFrames-1) ); 
     
   clear frames     
end
