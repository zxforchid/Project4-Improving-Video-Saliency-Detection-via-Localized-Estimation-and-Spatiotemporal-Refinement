function [model1,model2,salMap] = processEnds2_0_New(frames,Feas,spInfors,initSals,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��֡�� bootstrap ������Ƶ���ˣ� 3 N-2; �ֲ�����Ϊ5�� ����ģ������
% ��������Ԥ����
% 2017.03.10  11:01AM
% ��ֹ����ȫ0������ͼ���޷�ѵ��
% 2017.3.14 8:09AM
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ����zhouzhihua�Ĺ�������ƽ�⣩�������µĳ���
% 2017.03.29 13:32PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% �ռ��ֲ�������Ϣ
NW = 3;
im = cell(1,NW);sal = cell(1,NW);
spdatas = cell(1,NW);feadatas = cell(1,NW);
nn=1;
for tt=(f-1):(f+1)% 2,3,4 ��3Ϊcenter
    im{1,nn}   = frames{1,tt};
    sal{1,nn}  = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end
clear frames initSals spInfors Feas nn

%% �����طָ� & ������ȡ & gt label & ѵ��
% models = cell(1,NW);
% models = cell(1,1);
traindatas = [];
trainlabels = [];
% % conFID = [];
models =[];
for ii=1:NW
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
% %     [labelInfor] = sampleSelection_5w(gt,spInfor,param,ii);
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    if ii==2 % 2
        if sum(trainlabel(:))==0
           tmp_model = [];
        else
           tmp_model = trainNew0504(traindata,trainlabel,param);
        end
        models = [models,tmp_model];
    else % 1 3
        traindatas  = [traindatas;traindata];
        trainlabels = [trainlabels;trainlabel];
        if ii==3
           if sum(trainlabels(:))==0
              tmp_model = [];
           else
              tmp_model = trainNew0504(traindatas,trainlabels,param);
           end
           models = [models,tmp_model];
        end
    end
    
%     traindatas = [traindatas;traindata];
%     trainlabels = [trainlabels;trainlabel];
% %     conFID      = [conFID;ii*ones(size(traindata,1),1)];
    if ii==2 % ��ǰ֡  2,3,4  3Ϊcenter
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel tmp_model
end
clear im sal flow

% % %% ���¹���������ͼ��Ӧ֡������ȫ��ѡȡ����ԭʼ�����ȡ Pconf; 2017.04.11
% % [traindatas1,trainlabels1] = sampleSelection(param.direction, conFID, traindatas, trainlabels, param.PCONF);
% % clear traindatas trainlabels conFID

% %% ѵ��
% if sum(trainlabels(:))==0
%     models = [];    
% else
%     models = trainNew0504(traindatas,trainlabels,param);
% % %     models = baggingTrainRFNew(traindatas,trainlabels, param);
% end
clear traindatas trainlabels

%% ����: testdata _im, _fea, _spinfor
[w,h,~] = size(testdata_im);
salMap = zeros(w,h); 
if ~isempty(models)
    [model1,model2,salMap] = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);    
    salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
    salMap = graphCut_Refine(testdata_im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
    
    model1 = normalizeSal(model1);% ��߶�ƽ�������µ����ؼ�������ͼ
    model1 = graphCut_Refine(testdata_im,model1); 
    model1 = normalizeSal(guidedfilter(model1,model1,6,0.1));
    
    model2 = normalizeSal(model2);% ��߶�ƽ�������µ����ؼ�������ͼ
    model2 = graphCut_Refine(testdata_im,model2); 
    model2 = normalizeSal(guidedfilter(model2,model2,6,0.1));
end

clear models testdata_im testdata_fea models testdata_spinfor

end

