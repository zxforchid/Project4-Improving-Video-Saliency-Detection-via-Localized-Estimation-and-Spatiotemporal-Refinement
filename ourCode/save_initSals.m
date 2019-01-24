function save_initSals(initSals,frame_names,saliencyMapPath)
% ±£¥Ê≥ı ºœ‘÷¯–‘Õº
% 2017.03.10 9:26AM
frameNum = length(initSals);
for ii=1:frameNum
    tmpSal = initSals{1,ii};
    tmpSal = uint8(255*tmpSal);
    imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_init.png']) 
    clear tmpSal
%     tmpFore = forwardSals{1,ii};
%     tmpFore = uint8(255*tmpFore);
%     imwrite(tmpFore,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_foreward.png']) 
%     
%     tmpBack = backwardSals{1,ii};
%     tmpBack = uint8(255*tmpBack);
%     imwrite(tmpBack,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_backward.png']) 
end

clear initSals frame_names saliencyMapPath
end