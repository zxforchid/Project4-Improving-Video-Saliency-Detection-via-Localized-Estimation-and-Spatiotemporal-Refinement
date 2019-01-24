function SALS = integrateSals(initSals,forwardSals,backwardSals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ں� initSal forewardSal backwardSal ����������ͼ
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
    tmpsal = normalizeSal(tmpsal);% ��߶�ƽ�������µ����ؼ�������ͼ
%     tmpsal = graphCut_Refine(frames{1,ff},tmpsal); 
%     tmpsal = normalizeSal(guidedfilter(tmpsal,tmpsal,6,0.1));
    
    SALS{1,ff} = tmpsal;
    
    clear tmpsal tmpInit tmpFore tmpBack
end

clear initSals forwardSals backwardSals frames
end