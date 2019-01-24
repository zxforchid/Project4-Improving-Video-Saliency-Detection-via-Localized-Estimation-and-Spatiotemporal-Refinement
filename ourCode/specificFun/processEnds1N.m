function [salMap] = processEnds1N(frames,Feas,spInfors,initSals,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 单帧的 bootstrap 处理视频两端： 3 N-2; 局部窗口为5， 用于模型提升
% 返回自身预测结果
% 2017.03.10  11:01AM
% 防止出现全0显著性图，无法训练
% 2017.3.14 8:09AM
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 引入zhouzhihua的工作（非平衡），采用新的程序
% 2017.03.29 13:32PM
% 处理第1、N帧
% 2017.04.20 22:27PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% 收集局部窗口信息
NW = 2;
im = cell(1,NW);sal = cell(1,NW);
spdatas = cell(1,NW);feadatas = cell(1,NW);
nn=1;
%% f=1 倒序，方便后面确定中心帧！！！
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

%% 超像素分割 & 特征提取 & gt label & 训练
traindatas = [];
trainlabels = [];
frameNum = length(frames);clear frames
param.frameNum = frameNum;% 视频帧数
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
    if ii==2 % 当前帧  2,1/N-1,N； 1 & N 是窗口中心; 即第三帧是窗口中心
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel tmp_model
end
clear im sal flow


% % %% 训练
% % if sum(trainlabels(:))==0
% %     models = [];    
% % else
% %     models = trainNew0504(traindatas,trainlabels,param);
% % %     models = baggingTrainRFNew(traindatas,trainlabels, param);
% % end
clear traindatas trainlabels

%% 测试: testdata _im, _fea, _spinfor
[w,h,~] = size(testdata_im);
salMap = zeros(w,h); 
if ~isempty(models)
     [~,~,salMap] = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);   
%     salMap = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);    
    salMap = normalizeSal(salMap);% 多尺度平均意义下的像素级显著性图
    salMap = graphCut_Refine(testdata_im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear models testdata_im testdata_fea models testdata_spinfor

end



