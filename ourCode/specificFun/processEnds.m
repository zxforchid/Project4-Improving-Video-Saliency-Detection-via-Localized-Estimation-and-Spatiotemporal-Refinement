function [salMap,tmodel] = processEnds(flow,sal,im,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 1 N-1
% ��������Ԥ���� & �õ���ģ��
% 2017.03.01
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% ��߶ȷָ�
spInfor = multiscaleSLIC(im,param.spnumbers);
                       
% ��ȡ����
feadata = featureExtract0(im, flow, spInfor);

% sal --- GT
threshold = graythresh(sal);
gt = im2bw(sal,threshold);

% ��ȡ��ǩ
labelInfor = labelExtract1(gt,spInfor,param.OB_ths);

% ��ȡѵ������
[traindata,trainlabel] = obtainTraindata(labelInfor, feadata);

% ѵ����ȡģ��
tmodel = baggingTrainRF1(traindata, trainlabel, param);

% ����
salMap = baggingTestRF(im, feadata, tmodel, spInfor);

clear spInfor feadata gt traindata trainlabel
clear flow sal im param
end