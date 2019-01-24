function SALS = obtainFBSal_SMI(forwardSals,backwardSals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 融合 initSal forewardSal backwardSal 三种显著性图
% 2017.03.01 21:18PM
% 用于前后向显著性图的融合
% 2017.03.24  21:33PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameNum = length(forwardSals);
SALS = cell(1,frameNum);
for ff=1:frameNum
%     tmpInit = initSals{1,ff};
    tmpFore = forwardSals{1,ff};
    tmpBack = backwardSals{1,ff};
    
    tmpsal = tmpFore + tmpBack;
%     tmpsal = tmpInit + tmpFore + tmpBack;% 2017.03.24 17:01PM
%     tmpsal = 0.2*tmpInit + 0.4*tmpFore + 0.4*tmpBack;
    tmpsal = normalizeSal(tmpsal);% 多尺度平均意义下的像素级显著性图
    
    SALS{1,ff} = tmpsal;
    
    clear tmpsal tmpInit tmpFore tmpBack
end

clear initSals forwardSals backwardSals frames
end