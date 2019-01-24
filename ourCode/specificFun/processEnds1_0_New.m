function [salMap] = processEnds1_0_New(frames,Feas,spInfors,initSals,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 2, N-1; �ֲ�����Ϊ3,  ����ģ������
% initSals  2~n-1
% ��������Ԥ����
% 2017.03.10  10:53AM
% ��ֹ����ȫ0������ͼ���޷�ѵ��
% 2017.3.14 8:09AM
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ����zhouzhihua�Ĺ�������ƽ�⣩�������µĳ���
% 2017.03.29 13:32PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% �ռ��ֲ�������Ϣ
im = cell(1,3);sal = cell(1,3);
spdatas = cell(1,3);feadatas = cell(1,3);
nn=1;
for tt=(f-1):(f+1)
    im{1,nn}       = frames{1,tt};
    sal{1,nn}      = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end
clear frames initSals spInfors Feas nn

%% �����طָ� & ������ȡ & gt label & ѵ��
% models = cell(1,3);
% models = cell(1,1);
traindatas = [];
trainlabels = [];
% % conFID = [];% ������֮֡��־��1 ǰ��֡��2����ǰ֡��3�����֡�� 2017.04.11
for ii=1:3
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
    [labelInfor] = sampleSelection_3w(gt,spInfor,param,ii);
% %     labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    traindatas = [traindatas;traindata];
    trainlabels = [trainlabels;trainlabel];
% %     conFID      = [conFID;ii*ones(size(traindata,1),1)];
    if ii==2 % ��ǰ֡
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel

end
clear im sal flow

% %% ���¹���������ͼ��Ӧ֡������ȫ��ѡȡ����ԭʼ�����ȡ Pconf; 2017.04.11
% % param.direction  'F' & 'B', conFID traindatas trainlabels
% [traindatas1,trainlabels1] = sampleSelection(param.direction, conFID, traindatas, trainlabels, param.PCONF);
% clear traindatas trainlabels conFID

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

end

