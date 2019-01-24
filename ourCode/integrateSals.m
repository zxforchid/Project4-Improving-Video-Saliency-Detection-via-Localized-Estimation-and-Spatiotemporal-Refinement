function SALS = integrateSals(initSals,forwardSals,backwardSals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 融合 initSal forewardSal backwardSal 三种显著性图
% 2017.03.01 21:18PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameNum = length(initSals);
SALS = cell(1,frameNum);
for ff=1:frameNum
    tmpInit = initSals{1,ff};
    tmpFore = forwardSals{1,ff};
    tmpBack = backwardSals{1,ff};
    
%     tmpsal = tmpInit + tmpFore + tmpBack;% 2017.03.24 17:01PM
    tmpsal = 0.2*tmpInit + 0.4*tmpFore + 0.4*tmpBack;
    tmpsal = normalizeSal(tmpsal);% 多尺度平均意义下的像素级显著性图
%     tmpsal = graphCut_Refine(frames{1,ff},tmpsal); 
%     tmpsal = normalizeSal(guidedfilter(tmpsal,tmpsal,6,0.1));
    
    SALS{1,ff} = tmpsal;
    
    clear tmpsal tmpInit tmpFore tmpBack
end

clear initSals forwardSals backwardSals frames
end