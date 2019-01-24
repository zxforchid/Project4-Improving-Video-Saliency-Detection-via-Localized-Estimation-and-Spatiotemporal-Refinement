function [salMap] = processEnds1N(frames,Feas,spInfors,initSals,param,f)
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
% �����1��N֡
% 2017.04.20 22:27PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% �ռ��ֲ�������Ϣ
NW = 2;
im = cell(1,NW);sal = cell(1,NW);
spdatas = cell(1,NW);feadatas = cell(1,NW);
nn=1;
%% f=1 ���򣬷������ȷ������֡������
if f==1 % 2,1
for tt=2:(-1):1
    im{1,nn}   = frames{1,tt};
    sal{1,nn}  = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end
    
end

if f==length(frames)% N-1,N
for tt=(f-1):f
    im{1,nn}   = frames{1,tt};
    sal{1,nn}  = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end  
    
end
clear initSals spInfors Feas nn

%% �����طָ� & ������ȡ & gt label & ѵ��
traindatas = [];
trainlabels = [];
frameNum = length(frames);clear frames
param.frameNum = frameNum;% ��Ƶ֡��
models = [];
for ii=NW:(-1):1%1:NW
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
% %     [labelInfor] = sampleSelection1N(gt,spInfor,param,ii,f);
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    
    if sum(trainlabel(:))==0
        tmp_model = [];
    else
        tmp_model = trainNew0504(traindata,trainlabel,param);
    end
    models = [models,tmp_model];
    
%     traindatas = [traindatas;traindata];
%     trainlabels = [trainlabels;trainlabel];
    if ii==2 % ��ǰ֡  2,1/N-1,N�� 1 & N �Ǵ�������; ������֡�Ǵ�������
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel tmp_model
end
clear im sal flow


% % %% ѵ��
% % if sum(trainlabels(:))==0
% %     models = [];    
% % else
% %     models = trainNew0504(traindatas,trainlabels,param);
% % %     models = baggingTrainRFNew(traindatas,trainlabels, param);
% % end
clear traindatas trainlabels

%% ����: testdata _im, _fea, _spinfor
[w,h,~] = size(testdata_im);
salMap = zeros(w,h); 
if ~isempty(models)
     [~,~,salMap] = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);   
%     salMap = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);    
    salMap = normalizeSal(salMap);% ��߶�ƽ�������µ����ؼ�������ͼ
    salMap = graphCut_Refine(testdata_im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear models testdata_im testdata_fea models testdata_spinfor

end



