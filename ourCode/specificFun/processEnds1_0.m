function [salMap] = processEnds1_0(frames,Feas,spInfors,initSals,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 2, N-1; �ֲ�����Ϊ3,  ����ģ������
% initSals  2~n-1
% ��������Ԥ����
% 2017.03.10  10:53AM
% ��ֹ����ȫ0������ͼ���޷�ѵ��
% 2017.3.14 8:09AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% �ռ��ֲ�������Ϣ
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

% �����طָ� & ������ȡ & gt label & ѵ��
models = cell(1,3);
for ii=1:3
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
    if sum(gt(:))==0 % ȫ��
    models{1,ii} = [];    
    else
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    tmodel = baggingTrainRF1(traindata, trainlabel, param);
    models{1,ii} = tmodel;
    end
    if ii==2 % ��ǰ֡
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel

end
clear im sal flow

% ����: testdata _im, _fea, _spinfor
% [w,h,~] = size(testdata_im);
% salMap = zeros(w,h);
salMap = zeros(size(testdata_im,1),size(testdata_im,2));    
for ii=1:length(models)
    tmpModel = models{1,ii};
    if isempty(tmpModel)
        tmpSal = zeros(w,h);
    else
        tmpSal = baggingTestRF(testdata_im, testdata_fea, tmpModel, testdata_spinfor);
    end
    salMap = salMap + tmpSal;
    clear tmpSal tmpModel
end
salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
salMap = graphCut_Refine(testdata_im,salMap); 
salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));

clear models

end

