function [initSals] = obtainInitSal1(frame_names,saliencyMapPath,frames)
% 获取初始显著性图2, 单模型提升
% 注意：原始 sal 的后缀是 .png
% 2017.03.10 10:11AM
% 
initSals = cell(1,length(frame_names)-1);
for f = 1:(length(frame_names)-1) 
     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'.png']);
     tmpInitSal = normalizeSal(tmpInitSal);
     
     tmpInitSal = graphCut_Refine(frames{1,f},tmpInitSal); 
     tmpInitSal = normalizeSal(tmpInitSal);
    
     initSals{1,f} = tmpInitSal;
     clear tmpInitSal
end
clear frame_names saliencyMapPath frames

end