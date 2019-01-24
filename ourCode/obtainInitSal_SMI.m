function [initSals] = obtainInitSal_SMI(frames,frame_names,frameRecords, saliencyMapPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 获取初始显著性图2, 多模型融合，统一采用 2~N-1帧图像
% 根据采用的彩色图像的名称提取 initSal
% 注意：原始 sal 的后缀是 .png
% 2017.03.10 10:11AM
% 增加原始初始的显著性图 & GP后的显著性图
% 2017.03.24 22:19PM
% 用于SMI的对应原模型的初始显著性图
% 2017.04.06  20:26PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initSals = cell(1,length(frame_names));
% initSals_GP = cell(1,length(frame_names));
for f = 1:length(frame_names) 
     frameRecord = frameRecords{1,f};
     h = frameRecord(1);w = frameRecord(2);
     top = frameRecord(3);
     bot = frameRecord(4);
     left = frameRecord(5);
     right = frameRecord(6);
     partialH = bot - top + 1;
     partialW = right - left + 1;

     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'.png']);
     tmpInitSal = tmpInitSal(:,:,1);
     
     if partialH ~= h || partialW ~= w % 截取中心部分
        tmpInitSal = tmpInitSal(top:bot, left:right);
     end
     
     tmpInitSal = normalizeSal(tmpInitSal);
     tmpInitSal = graphCut_Refine(frames{1,f},tmpInitSal); 
%      tmpInitSal = normalizeSal(guidedfilter(tmpInitSal,tmpInitSal,6,0.1));
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals{1,f} = tmpInitSal;
     clear tmpInitSal h w top bot left right
end
clear frame_names saliencyMapPath frames

end