% function [initSals,forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
% function [initSals] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [initSals,forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
% function [forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 前向处理: 
% frames     各帧之图像信息
% spInfors   分割信息
% Feas       区域特征
% initSals   初始显著性图  
% 注意： 输入的信息名字、数量均是一一对应的！！！
% forwardSal 前向预测的结果
% 2017.03.10 10:41AM
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 引入zhouzhihua的工作（非平衡），采用新的程序
% 2017.03.29 13:32PM
% 并行，对于更新后的显著性图，放宽其阈值
% 2017.04.17  22:15
% copyright by xiaofei zhou, shanghai university
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
forwardSal = cell(1,length(frames));
param.direction = 'F';
for f = 1:length(frames)  
    f
    % NW=1
    if f==1 || f==length(frames)
        [tmpSal] = processEnds1N(frames,Feas,spInfors,initSals,param,f);
%         [tmpSal] = processEnds1N(frames{1,f},Feas{1,f},spInfors{1,f},initSals{1,f},param);
    end
          
    % NW=3
    if f==2 || f==(length(frames)-1) 
        [tmpSal] = processEnds2N1(frames,Feas,spInfors,initSals,param,f);
%         [tmpSal] = processEnds2N1(frames,Feas,spInfors,initSals,param,f);
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-2) 
        [model1,model2,tmpSal] = processEnds2_0_New(frames,Feas,spInfors,initSals,param,f);
    end
    
%     forwardSal{1,f} = tmpSal;
    tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal,frames{1,f},param.weights);% 用strong + weak的结果来进行更新
    tmpSal1 = SOPFun(Feas{1,f},spInfors{1,f},tmpSal1);   
    
    tmpSal1 = graphCut_Refine(frames{1,f},tmpSal1); % 更新用 2017.05.05
    tmpSal1 = normalizeSal(guidedfilter(tmpSal1,tmpSal1,6,0.1));
    
    forwardSal{1,f} = tmpSal;% 输出保存 strong 结果，2017.05.07 10:34AM
    initSals{1,f} = tmpSal1;% 输出保存、更新最终的结果
    
% %     tmpSal1 = normalizeSal(SOPFun(Feas{1,f},spInfors{1,f},tmpSal1) + tmpSal1);    
% %     initSals{1,f}   = tmpSal1;
    
% % %     forwardSal{1,f}   = tmpSal1;% 保存用 2017.05.05
% %     sal = graphCut_Refine(frames{1,f},tmpSal1); % 更新用 2017.05.05
% %     sal = normalizeSal(guidedfilter(sal,sal,6,0.1));
% %     initSals{1,f}   = sal;% 对应的第一帧的显著性图要改变，为后续服务          
    clear tmpSal tmpSal1 sal
    
    %% clear 一些用过的输入  initSals & initSalsF
    if f<=(length(frames)-1) && f>=2% 2~N-1 
       frames{1,f-1} = [];
       spInfors{1,f-1} = [];
    end
       
    if f==length(frames)% N
        frames{1,f-1} = [];
        spInfors{1,f-1} = [];
        frames{1,f} = [];
        spInfors{1,f} = [];
    end
end
clear frames spInfors Feas param
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = SOPFun(feadata,spInfor,tmpSal1)
scaleNum = length(spInfor);
[height,width,dims]  = size(tmpSal1);
result = 0;
for ss = 1:scaleNum
    adjcMatrix = spInfor{ss,1}.adjcMatrix;
    colDistM   = spInfor{ss,1}.colDistM;
    bdIds      = spInfor{ss,1}.bdIds;
    pixelList  = spInfor{ss,1}.pixelList;
    
    tempFea = feadata{1,ss};
    motionFea = double(tempFea(:,7:8));
    motionDistM = GetDistanceMatrix(motionFea);
    clear tmpFea
    
    
    FGWEIGHT = GetMeanColor(tmpSal1, pixelList);
    
    % APP
    [clipVal, geoSigma, neiSigmaAPP] = EstimateDynamicParas(adjcMatrix, colDistM);
    [bgProb, bdCon, bgWeightAPP] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    clear clipVal geoSigma bgProb bdCon
    
    % motion
    [clipVal, geoSigma, neiSigmaMOTION] = EstimateDynamicParas(adjcMatrix, motionDistM);
    [bgProb, bdCon, bgWeightMOTION] = EstimateBgProb(motionDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    clear clipVal geoSigma bgProb bdCon
    
    bgWeight = bgWeightAPP + bgWeightMOTION;
    bgWeight = normalizeSal(bgWeight);
    SalValue = SaliencyOptimizationNew(adjcMatrix, bdIds, motionDistM, colDistM, neiSigmaMOTION,neiSigmaAPP, bgWeight, FGWEIGHT);
    
    clear neiSigmaMOTION neiSigmaAPP bgWeightAPP bgWeightMOTION
    clear bgProb bdCon bgWeight
    
    [SalValue_Img, ~] = CreateImageFromSPs(SalValue, pixelList, height, width, true);
    result  = result + SalValue_Img;
    
    clear adjcMatrix colDistM bdIds pixelList FGWEIGHT 
    clear clipVal geoSigma neiSigma
    clear bgProb bdCon bgWeight SalValue SalValue_Img
end

result  = result + tmpSal1;
result = normalizeSal(result);
    
clear spInfor tmpSal1
end