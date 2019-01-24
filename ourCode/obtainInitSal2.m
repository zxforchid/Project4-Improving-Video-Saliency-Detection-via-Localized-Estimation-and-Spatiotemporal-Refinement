function [initSals,initSals_GP] = obtainInitSal2(frame_names,saliencyMapPath,frames)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 获取初始显著性图2, 多模型融合，统一采用 2~N-1帧图像
% 根据采用的彩色图像的名称提取 initSal
% 注意：原始 sal 的后缀是 .png
% 2017.03.10 10:11AM
% 增加原始初始的显著性图 & GP后的显著性图
% 2017.03.24 22:19PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initSals = cell(1,length(frame_names));
initSals_GP = cell(1,length(frame_names));
for f = 1:length(frame_names) 
     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'.png']);
     tmpInitSal = tmpInitSal(:,:,1);
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals{1,f} = tmpInitSal;
     
     tmpInitSal = graphCut_Refine(frames{1,f},tmpInitSal); 
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals_GP{1,f} = tmpInitSal;
     clear tmpInitSal
end
clear frame_names saliencyMapPath frames

end