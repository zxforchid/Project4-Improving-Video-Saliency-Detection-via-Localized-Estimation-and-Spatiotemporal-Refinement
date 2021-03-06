% function [salMap,tmodel] = processEnds_0(im,feadata,spInfor,sal,param)
function [salMap] = PE0(im,feadata,spInfor,sal,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 单帧的 bootstrap 处理视频两端： 1 N-1, 模型提升
% 返回自身预测结果 & 得到的模型
% 2017.03.10 10:43AM
% 防止出现全0显著性图，无法训练
% 2017.3.14 8:09AM
% 采用ELM / Undersampling 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% sal --- GT
threshold = graythresh(sal);
gt = im2bw(sal,threshold);
clear threshold

if sum(gt(:))==0 % 全黑
salMap = zeros(size(gt,1),size(gt,2));    
% tmodel = [];
else
% 获取标签
labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
clear gt

% 获取训练样本
[traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
clear labelInfor

% 对非平衡样本之多数类进行下采样（zhou zhihua的工作）






% 训练获取模型
tmodel = baggingTrainRF1(traindata, trainlabel, param);
clear traindata trainlabel

% 测试
salMap = baggingTestRF(im, feadata, tmodel, spInfor);

% postprocessing
salMap = normalizeSal(salMap);% 多尺度平均意义下的像素级显著性图
salMap = graphCut_Refine(im,salMap); 
salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end
clear feadata spInfor sal param 

end