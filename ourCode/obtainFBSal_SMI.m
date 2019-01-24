function SALS = obtainFBSal_SMI(forwardSals,backwardSals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ں� initSal forewardSal backwardSal ����������ͼ
% 2017.03.01 21:18PM
% ����ǰ����������ͼ���ں�
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
    tmpsal = normalizeSal(tmpsal);% ��߶�ƽ�������µ����ؼ�������ͼ
    
    SALS{1,ff} = tmpsal;
    
    clear tmpsal tmpInit tmpFore tmpBack
end

clear initSals forwardSals backwardSals frames
end