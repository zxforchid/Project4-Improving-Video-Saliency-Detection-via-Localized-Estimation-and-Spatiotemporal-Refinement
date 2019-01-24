function save_Sals_New(initSals,frame_names,frameRecords, saliencyMapPath,suffix)
% ±£¥Ê≥ı ºœ‘÷¯–‘Õº
% 
fill_value = 0;
frameNum = length(initSals);
for ii=1:frameNum
     frameRecord = frameRecords{1,ii};
     h = frameRecord(1);w = frameRecord(2);
     top = frameRecord(3);
     bot = frameRecord(4);
     left = frameRecord(5);
     right = frameRecord(6);
     partialH = bot - top + 1;
     partialW = right - left + 1;
     
     
    tmpSal = normalizeSal(initSals{1,ii});
%     tmpSal = uint8(255*tmpSal);
    
    if partialH ~= h || partialW ~= w
       feaImg = ones(h, w) * fill_value;
       feaImg(top:bot, left:right) = tmpSal;
       feaImg = uint8(255*feaImg);
       imwrite(feaImg,[saliencyMapPath,frame_names{1,ii}(1:end-4),suffix]) 
    else
       tmpSal = uint8(255*tmpSal);
       imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),suffix]) 
    end
    
%     imwrite(tmpFore,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_foreward.png']) 
% %     imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),suffix]) 
    clear tmpSal
end

clear initSals frame_names saliencyMapPath suffix
end