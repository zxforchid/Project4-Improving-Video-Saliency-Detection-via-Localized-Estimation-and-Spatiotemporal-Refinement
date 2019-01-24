function save_finalSals3_New(initSals,frame_names,saliencyMapPath,iter)
% 保存初始显著性图
% 2017.03.26 21:20PM
% 迭代的保存
% 2017.03.27 20:45PM
% 迭代保存结果3
% 2017.03.28 10:20AM
% 
frameNum = length(initSals);
for ii=1:frameNum
    tmpSal = initSals{1,ii};
    tmpSal = uint8(255*tmpSal);
    imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_iter',num2str(iter),'_final3.png']) 
    clear tmpSal
end

clear initSals frame_names saliencyMapPath
end