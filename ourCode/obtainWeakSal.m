function weakSal = obtainWeakSal(INITSALS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 计算平均显著性图， weakSal；即对于当前帧，各模型相加
% 2017.03.10 13:55PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% initialize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
frameNum = length(INITSALS{1,1});
weakSal = cell(1,frameNum);
SAL = INITSALS{1,1};
[w,h] = size(SAL{1,1});clear SAL
for kk=1:frameNum
    weakSal{1,kk} = zeros(w,h);
end
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
modelNum = length(INITSALS);
for mm = 1:modelNum
    tmpSAL = INITSALS{1,mm};
    frameNum = length(tmpSAL);
    for ff=1:frameNum
        weakSal{1,ff} = weakSal{1,ff} + tmpSAL{1,ff};
    end
    clear tmpSAL
end
% clear INITSALS

%% normalize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
for cc=1:frameNum
    weakSal{1,cc} = normalizeSal(weakSal{1,cc});
end

clear INITSALS
end