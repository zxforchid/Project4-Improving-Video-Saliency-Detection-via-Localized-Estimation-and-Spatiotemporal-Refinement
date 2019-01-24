function GGG = obtainWeakSal_New(INITSALS,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 计算平均显著性图， weakSal；即对于当前帧，各模型相加
% 2017.03.10 13:55PM
% 仅第 f 帧相加，方便保存,返回的第 ff 帧的前后向之和的结果
% 2017.04.03 14:11 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
modelNum = length(INITSALS);
GGG = zeros(size(INITSALS{1,1}{1,1}));
for mm = 1:modelNum
    tmpSAL = INITSALS{1,mm};
    GGG = GGG + tmpSAL{1,ff};
    clear tmpSAL
end

GGG = normalizeSal(GGG);

clear INITSALS
end