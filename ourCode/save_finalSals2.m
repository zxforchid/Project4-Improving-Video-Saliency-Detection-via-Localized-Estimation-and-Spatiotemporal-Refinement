function save_finalSals2(initSals,frame_names,saliencyMapPath)
% ±£¥Ê≥ı ºœ‘÷¯–‘Õº
% 2017.03.26 21:20PM
frameNum = length(initSals);
for ii=1:frameNum
    tmpSal = initSals{1,ii};
    tmpSal = uint8(255*tmpSal);
    imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_final2.png']) 
    clear tmpSal
end

clear initSals frame_names saliencyMapPath
end