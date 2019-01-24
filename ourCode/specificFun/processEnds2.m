function [salMap] = processEnds2(Flows,initSals,frames,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 3 N-3; �ֲ�����Ϊ5
% ��������Ԥ����
% 2017.03.01
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% �ռ��ֲ�������Ϣ
NW = 5;
im = cell(1,NW);sal = cell(1,NW);flow = cell(1,NW);
nn=1;
for ff=(f-2):(f+2)
    im{1,nn}   = frames{1,ff};
    sal{1,nn}  = initSals{1,ff};
    flow{1,nn} = Flows{1,ff};
    nn = nn+1;
end
clear frames initSals Flows nn

% �����طָ� & ������ȡ & gt label & ѵ��
models = cell(1,NW);
for ii=1:NW
    spInfor = multiscaleSLIC(im{1,ii},param.spnumbers);
    feadata = featureExtract0(im{1,ii}, flow{1,ii}, spInfor);

    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
    
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    tmodel = baggingTrainRF1(traindata, trainlabel, param);
    models{1,ii} = tmodel;
    
    if ii==3 % ��ǰ֡  1,2,3,4,5  3Ϊcenter
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel
end
clear im sal flow

% ����: testdata _im, _fea, _spinfor
salMap = 0;
for ii=1:length(models)
    tmpModel = models{1,ii};
    tmpSal = baggingTestRF(testdata_im, testdata_fea, tmpModel, testdata_spinfor);
    salMap = salMap + tmpSal;
    clear tmpSal tmpModel
end
salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
salMap = graphCut_Refine(testdata_im,salMap); 
salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));

clear models
end

