% function [salMap,tmodel] = processEnds_0(im,feadata,spInfor,sal,param)
% function [salMap] = processEnds_0(im,feadata,spInfor,sal,param)
function [salMap] = processEnds_0_New1(im,feadata,spInfor,INITSALS,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 1 N-1, ģ������
% ��������Ԥ���� & �õ���ģ��
% 2017.03.10 10:43AM
% ��ֹ����ȫ0������ͼ���޷�ѵ��
% 2017.3.14 8:09AM
% co-sampe ����ʽ�����ڶ�ģ�͵��ں�
% INITSALS ��ʼ������ͼ  1*4 / 1*frameNum
% f ֡��ID
% 2017.3.24 20:17PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%% ��ȡ��ǰ֡��������ͼ����Ӧ�ڶ�ģ��;����ȡѵ������
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
    
    % ��ȡ��ǩ
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
    clear gt

    % ��ȡѵ������
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    clear labelInfor

    traindatas = [traindatas;traindata];
    trainlabels = [trainlabels;trainlabel];
    clear trainlabel traindata
end
clear INITSALS

%% ѵ��
if sum(trainlabels(:))==0
    models = [];    
else
    models = baggingTrainRFNew(traindatas, trainlabels, param);
end
clear traindatas trainlabels 

%% ����: testdata _im, _fea, _spinfor
[w,h,~] = size(im);
salMap = zeros(w,h); 
if ~isempty(models)
    salMap = baggingTestRFNew(im, feadata, models, spInfor);    
    salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
    salMap = graphCut_Refine(im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear models im feadata models testdata_spinfor

end