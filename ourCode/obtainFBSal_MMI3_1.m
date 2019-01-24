function GGG = obtainFBSal_MMI3_1(INITSALS_F,INITSALS_B,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 计算平均显著性图， SAL
% 2017.03.10 13:55PM
% 用于前后向显著性图的融合
% 2017.03.24  21:33PM
% 用于各模型分别相加,即每一个模型下进行融合
% 2017.03.28 9:49AM
% 仅第 f 帧相加，方便保存
% GGG 返回的第 ff 帧的前后向之和的结果
% 2017.04.03 14:11 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
modelNum = length(INITSALS_F);
% SALS = cell(1,modelNum);
GGG = zeros(size(INITSALS_F{1,1}{1,1}));
for mm=1:modelNum
    tmpSALF = INITSALS_F{1,mm};
    tmpSALB = INITSALS_B{1,mm};

    GGG = GGG + tmpSALF{1,ff} + tmpSALB{1,ff};
%     tmpModelSal = normalizeSal(GGG);
    
%     clear GGG
    clear tmpSALF tmpSALB
    
%     SALS{1,mm} = tmpModelSal;% 更新SALS对应于当前模型的显著性图
%     clear tmpModelSal
end
% clear INITSALS
GGG = normalizeSal(GGG);

% %% normalize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% for cc=1:length(INITSALS_F{1,1})
%     SALS{1,cc} = normalizeSal(SALS{1,cc});
% end
clear INITSALS_F INITSALS_B
end