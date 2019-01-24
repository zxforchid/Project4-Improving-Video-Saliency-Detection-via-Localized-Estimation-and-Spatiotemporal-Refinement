function [salMap] = processEnds1_0_New1(frames,Feas,spInfors,INITSALS,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 2, N-1; �ֲ�����Ϊ3,  ����ģ������
% initSals  2~n-1
% ��������Ԥ����
% 2017.03.10  10:53AM
% ��ֹ����ȫ0������ͼ���޷�ѵ��
% 2017.3.14 8:09AM
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% co-sampe ����ʽ�����ڶ�ģ�͵��ں�
% INITSALS ��ʼ������ͼ  1*4 / 1*frameNum
% f ֡��ID
% 2017.3.24 20:17PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% �ռ��ֲ�������Ϣ
im = cell(1,3);
spdatas = cell(1,3);
feadatas = cell(1,3);
nn=1;
for tt=(f-1):(f+1)
    im{1,nn}       = frames{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end
clear frames spInfors Feas

testdata_im = im{1,2};
testdata_fea = feadatas{1,2};
testdata_spinfor = spdatas{1,2};
        
%% ��ȡ��ǰ֡��������ͼ����Ӧ�ڶ�ģ��;����ȡѵ������
modelNum = length(INITSALS);
traindatas = [];
trainlabels = [];

for mm=1:modelNum
initSals = INITSALS{1,mm};

% �ռ�ĳһģ�͵ĳ�ʼ������ͼ
sal = cell(1,3);nn=1;
for tt=(f-1):(f+1)
    sal{1,nn} = initSals{1,tt};
    nn = nn+1;
end
clear initSals

% �ռ�����
for ii=1:3
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    traindatas = [traindatas;traindata];
    trainlabels = [trainlabels;trainlabel];
    clear spInfor feadata gt labelInfor traindata trainlabel 
end
    
end

%% ѵ��
if sum(trainlabels(:))==0
    models = [];    
else
    models = baggingTrainRFNew(traindatas, trainlabels, param);
end
clear traindatas trainlabels 

%% ����: testdata _im, _fea, _spinfor
[w,h,~] = size(testdata_im);
salMap = zeros(w,h); 
if ~isempty(models)
    salMap = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);    
    salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
    salMap = graphCut_Refine(testdata_im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear models testdata_im testdata_fea models testdata_spinfor

%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% %% ѵ��
% models = cell(1,1);
% if sum(trainlabels(:))==0
%     models{1,1} = [];    
% else
%     models{1,1} = baggingTrainRF1(traindatas, trainlabels, param);
% end
% clear traindatas trainlabels 
% 
% %% ����
% % salMap = zeros(size(testdata_im,1),size(testdata_im,2));    
% [w,h,~] = size(testdata_im);
% salMap = zeros(w,h);
% for ii=1:length(models)
%     tmpModel = models{1,ii};
%     if isempty(tmpModel)
%         tmpSal = zeros(w,h);
%     else
%         tmpSal = baggingTestRF(testdata_im, testdata_fea, tmpModel, testdata_spinfor);
%     end
%     salMap = salMap + tmpSal;
%     clear tmpSal tmpModel
% end
% salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
% salMap = graphCut_Refine(testdata_im,salMap); 
% salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));

% clear models testdata_im testdata_fea testdata_spinfor


end

