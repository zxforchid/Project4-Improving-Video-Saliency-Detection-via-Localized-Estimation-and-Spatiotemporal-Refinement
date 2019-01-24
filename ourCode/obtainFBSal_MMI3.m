function SALS = obtainFBSal_MMI3(INITSALS_F,INITSALS_B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 计算平均显著性图， SAL
% 2017.03.10 13:55PM
% 用于前后向显著性图的融合
% 2017.03.24  21:33PM
% 用于各模型分别相加,即每一个模型下进行融合
% 2017.03.28 9:49AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% initialize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% MODELSAL = INITSALS_F{1,1};
% [w,h] = size(MODELSAL{1,1});
% clear MODELSAL

% % % modelNum = length(INITSALS_F);
% % % SALS = cell(1,modelNum);
% for mm=1:modelNum
%     frameNum = length(INITSALS_F{1,mm});
%     tmpModelSal = cell(1,frameNum);
%     for ff=1:frameNum
%         tmpModelSal{1,ff} = zeros(w,h);
%     end
%     SALS{1,mm} = tmpModelSal;
%     clear tmpModelSal
% end
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
modelNum = length(INITSALS_F);
SALS = cell(1,modelNum);
for mm=1:modelNum
    tmpSALF = INITSALS_F{1,mm};
    tmpSALB = INITSALS_B{1,mm};
    frameNum = length(INITSALS_F{1,mm});
    tmpModelSal = cell(1,frameNum);
    
    for ff=1:frameNum
         GGG = tmpSALF{1,ff} + tmpSALB{1,ff};
         tmpModelSal{1,ff} = normalizeSal(GGG);
         clear GGG
    end
    clear tmpSALF tmpSALB
    
    SALS{1,mm} = tmpModelSal;% 更新SALS对应于当前模型的显著性图
    clear tmpModelSal
end
% clear INITSALS

% %% normalize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% for cc=1:length(INITSALS_F{1,1})
%     SALS{1,cc} = normalizeSal(SALS{1,cc});
% end
clear INITSALS_F INITSALS_B
end