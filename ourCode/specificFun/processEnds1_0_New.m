function [salMap] = processEnds1_0_New(frames,Feas,spInfors,initSals,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 单帧的 bootstrap 处理视频两端： 2, N-1; 局部窗口为3,  用于模型提升
% initSals  2~n-1
% 返回自身预测结果
% 2017.03.10  10:53AM
% 防止出现全0显著性图，无法训练
% 2017.3.14 8:09AM
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 引入zhouzhihua的工作（非平衡），采用新的程序
% 2017.03.29 13:32PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% 收集局部窗口信息
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

%% 超像素分割 & 特征提取 & gt label & 训练
% models = cell(1,3);
% models = cell(1,1);
traindatas = [];
trainlabels = [];
% % conFID = [];% 窗口内帧之标志：1 前半帧；2，当前帧；3，后半帧。 2017.04.11
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
    if ii==2 % 当前帧
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel

end
clear im sal flow

% %% 更新过的显著性图对应帧的样本全部选取，最原始的则仅取 Pconf; 2017.04.11
% % param.direction  'F' & 'B', conFID traindatas trainlabels
% [traindatas1,trainlabels1] = sampleSelection(param.direction, conFID, traindatas, trainlabels, param.PCONF);
% clear traindatas trainlabels conFID

%% 训练
if sum(trainlabels(:))==0
    models = [];    
else
    models = baggingTrainRFNew(traindatas, trainlabels, param);
end
clear traindatas trainlabels 

%% 测试: testdata _im, _fea, _spinfor
[w,h,~] = size(testdata_im);
salMap = zeros(w,h); 
if ~isempty(models)
    salMap = baggingTestRFNew(testdata_im, testdata_fea, models, testdata_spinfor);    
    salMap = normalizeSal(salMap);% 多尺度平均意义下的像素级显著性图
    salMap = graphCut_Refine(testdata_im,salMap); 
    salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));
end

clear models testdata_im testdata_fea models testdata_spinfor

end

