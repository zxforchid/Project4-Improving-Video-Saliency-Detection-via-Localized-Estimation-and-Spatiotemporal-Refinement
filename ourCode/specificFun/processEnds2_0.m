function [salMap] = processEnds2_0(frames,Feas,spInfors,initSals,param,f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 单帧的 bootstrap 处理视频两端： 3 N-2; 局部窗口为5， 用于模型提升
% 返回自身预测结果
% 2017.03.10  11:01AM
% 防止出现全0显著性图，无法训练
% 2017.3.14 8:09AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 收集局部窗口信息
NW = 5;
im = cell(1,NW);sal = cell(1,NW);
spdatas = cell(1,NW);feadatas = cell(1,NW);
nn=1;
for tt=(f-2):(f+2)% 1,2,3,4,5 ；3为center
    im{1,nn}   = frames{1,tt};
    sal{1,nn}  = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end
clear frames initSals spInfors Feas nn

% 超像素分割 & 特征提取 & gt label & 训练
models = cell(1,NW);
for ii=1:NW
%     spInfor = multiscaleSLIC(im{1,ii},param.spnumbers);
%     feadata = featureExtract0(im{1,ii}, flow{1,ii}, spInfor);
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
    if sum(gt(:))==0 % 全黑
    models{1,ii} = [];   
    else
    labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
    [traindata,trainlabel] = obtainTraindata(labelInfor, feadata);
    tmodel = baggingTrainRF1(traindata, trainlabel, param);
    models{1,ii} = tmodel;
    end
    if ii==3 % 当前帧  1,2,3,4,5  3为center
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel
end
clear im sal flow

% 测试: testdata _im, _fea, _spinfor
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
salMap = normalizeSal(salMap);% 多尺度平均意义下的像素级显著性图
salMap = graphCut_Refine(testdata_im,salMap); 
salMap = normalizeSal(guidedfilter(salMap,salMap,6,0.1));

clear models
end

