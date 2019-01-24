function saveSals(SALS,forwardSals,backwardSals,frame_names,saliencyMapPath)
% ±£¥Ê◊Ó÷’œ‘÷¯–‘Õº
frameNum = length(SALS);
for ii=1:frameNum
    tmpSal = SALS{1,ii};
    tmpSal = uint8(255*tmpSal);
    imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_final.png']) 
    
    tmpFore = forwardSals{1,ii};
    tmpFore = uint8(255*tmpFore);
    imwrite(tmpFore,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_foreward.png']) 
    
    tmpBack = backwardSals{1,ii};
    tmpBack = uint8(255*tmpBack);
    imwrite(tmpBack,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_backward.png']) 
end

clear SALS forwardSals backwardSals frame_names saliencyMapPath
end