function [salMap,tmodel] = processEnds(flow,sal,im,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 单帧的 bootstrap 处理视频两端： 1 N-1
% 返回自身预测结果 & 得到的模型
% 2017.03.01
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% 多尺度分割
spInfor = multiscaleSLIC(im,param.spnumbers);
                       
% 提取特征
feadata = featureExtract0(im, flow, spInfor);

% sal --- GT
threshold = graythresh(sal);
gt = im2bw(sal,threshold);

% 获取标签
labelInfor = labelExtract1(gt,spInfor,param.OB_ths);

% 获取训练样本
[traindata,trainlabel] = obtainTraindata(labelInfor, feadata);

% 训练获取模型
tmodel = baggingTrainRF1(traindata, trainlabel, param);

% 测试
salMap = baggingTestRF(im, feadata, tmodel, spInfor);

clear spInfor feadata gt traindata trainlabel
clear flow sal im param
end