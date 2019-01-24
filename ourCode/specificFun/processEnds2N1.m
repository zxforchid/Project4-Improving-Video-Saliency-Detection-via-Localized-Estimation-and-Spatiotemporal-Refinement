function [salMap] = processEnds2N1(frames,Feas,spInfors,initSals,param,f)
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
% 处理第2、N-1帧：processEnds2N1
% 2017.04.21 7:48AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% 收集局部窗口信息
NW = 3;
im = cell(1,NW);sal = cell(1,NW);
spdatas = cell(1,NW);feadatas = cell(1,NW);
nn=1;
%% f=2 倒序，方便后面确定中心帧！！！ nn=3时，为中心帧
if f==2 % 1,<2>,3
for tt=3:(-1):1  % 3， <2>， 1
    im{1,nn}   = frames{1,tt};
    sal{1,nn}  = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end
    
end

if f==(length(frames)-1)% N-2,<N-1>,N
for tt=(f-1):(f+1) % N-2, <N-1>, N
    im{1,nn}   = frames{1,tt};
    sal{1,nn}  = initSals{1,tt};
    spdatas{1,nn}  = spInfors{1,tt};
    feadatas{1,nn} = Feas{1,tt};
    nn = nn+1;
end  
    
end
% for tt=(f-2):(f+2)% 1,2,3,4,5 ；3为center
%     im{1,nn}   = frames{1,tt};
%     sal{1,nn}  = initSals{1,tt};
%     spdatas{1,nn}  = spInfors{1,tt};
%     feadatas{1,nn} = Feas{1,tt};
%     nn = nn+1;
% end
clear initSals spInfors Feas nn

%% 超像素分割 & 特征提取 & gt label & 训练
traindatas = [];
trainlabels = [];
frameNum = length(frames); clear frames
param.frameNum = frameNum;% 视频帧数
models = [];
for ii=1:NW
    spInfor = spdatas{1,ii};
    feadata = feadatas{1,ii};
    
    threshold = graythresh(sal{1,ii});
    gt = im2bw(sal{1,ii},threshold);
% %     [labelInfor] = sampleSelection2N1(gt,spInfor,param,ii,f);
%     [labelInfor] = sampleSelection_3w(gt,spInfor,param,ii);
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
    
    if ii==2 % nn=2时，为中心帧位置  3,2,1  N-2,N-1,N
        testdata_im = im{1,ii};
        testdata_fea = feadata;
        testdata_spinfor = spInfor;
    end
    clear spInfor feadata gt labelInfor traindata trainlabel tmodel tmp_model
end
clear im sal flow

% % %% 更新过的显著性图对应帧的样本全部选取，最原始的则仅取 Pconf; 2017.04.11
% % [traindatas1,trainlabels1] = sampleSelection(param.direction, conFID, traindatas, trainlabels, param.PCONF);
% % clear traindatas trainlabels conFID

% %% 训练
% if sum(trainlabels(:))==0
%     models = [];    
% else
%     models = trainNew0504(traindatas,trainlabels,param);
% % %     models = baggingTrainRFNew(traindatas,trainlabels, param);
% end
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

