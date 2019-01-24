% function [salMap,tmodel] = processEnds_0(im,feadata,spInfor,sal,param)
% function [salMap] = processEnds_0(im,feadata,spInfor,sal,param)
function [salMap] = processEnds_0_New1(im,feadata,spInfor,INITSALS,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 单帧的 bootstrap 处理视频两端： 1 N-1, 模型提升
% 返回自身预测结果 & 得到的模型
% 2017.03.10 10:43AM
% 防止出现全0显著性图，无法训练
% 2017.3.14 8:09AM
% co-sampe 的形式，用于多模型的融合
% INITSALS 初始显著性图  1*4 / 1*frameNum
% f 帧的ID
% 2017.3.24 20:17PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%% 获取当前帧的显著性图，对应于多模型;并获取训练数据
modelNum = length(INITSALS);
traindatas = [];
trainlabels = [];
for mm=1:modelNum
    initSals = INITSALS{1,mm};
    sal = initSals{1,f};
    clear initSals
    
    % sal --- GT
    threshold = graythresh(sal);
    gt = im2bw(sal,threshold);
    clear threshold
    
    % 获取标签
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
    clear gt

    % 获取训练样本
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    clear labelInfor

    traindatas = [traindatas;traindata];
    trainlabels = [trainlabels;trainlabel];
    clear trainlabel traindata
end
clear INITSALS

%% 训练
if sum(trainlabels(:))==0
    models = [];    
else
    models = baggingTrainRFNew(traindatas, trainlabels, param);
end
clear traindatas trainlabels 

%% 测试: testdata _im, _fea, _spinfor
[w,h,~] = size(im);
salMap = zeros(w,h); 
if ~isempty(models)
    salMap = baggingTestRFNew(im, feadata, models, spInfor);    
    salMap = normalizeSal(salMap);% 多尺度平均意义下的像素级显著性图
    salMap = graphCut_Refine(im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear models im feadata models testdata_spinfor

end