% function [salMap,tmodel] = processEnds_0(im,feadata,spInfor,sal,param)
function [salMap] = processEnds_0(im,feadata,spInfor,sal,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 1 N-1, ģ������
% ��������Ԥ���� & �õ���ģ��
% 2017.03.10 10:43AM
% ��ֹ����ȫ0������ͼ���޷�ѵ��
% 2017.3.14 8:09AM
% ����zhouzhihua�Ĺ�������ƽ�⣩�������µĳ���
% 2017.03.29 13:32PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
% sal --- GT
threshold = graythresh(sal);
gt = im2bw(sal,threshold);
clear threshold

if sum(gt(:))==0 % ȫ��
salMap = zeros(size(gt,1),size(gt,2));    
% tmodel = [];
else
% ��ȡ��ǩ
labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
clear gt

% ��ȡѵ������
[traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
clear labelInfor

% ѵ����ȡģ��
tmodel = baggingTrainRFNew(traindata, trainlabel, param);
clear traindata trainlabel
% ����
salMap = baggingTestRFNew(im, feadata, tmodel, spInfor);

% postprocessing
salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
salMap = graphCut_Refine(im,salMap); 
salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear feadata spInfor sal param im
end