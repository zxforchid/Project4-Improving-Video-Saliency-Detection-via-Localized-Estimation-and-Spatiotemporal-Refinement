function SAL = obtainFBSal_MMI(INITSALS_F,INITSALS_B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 计算平均显著性图， SAL
% 2017.03.10 13:55PM
% 用于前后向显著性图的融合
% 2017.03.24  21:33PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% initialize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
MODELSAL = INITSALS_F{1,1};
[w,h] = size(MODELSAL{1,1});
clear MODELSAL

SAL = cell(1,length(INITSALS_F{1,1}));
for kk=1:length(INITSALS_F{1,1})
    SAL{1,kk} = zeros(w,h);
end
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
modelNum = length(INITSALS_F);
for ii=1:modelNum
    tmpSALF = INITSALS_F{1,ii};
    tmpSALB = INITSALS_B{1,ii};
    
    for jj=1:length(INITSALS_F{1,ii})
        
        SAL{1,jj} = SAL{1,jj} + tmpSALF{1,jj} + tmpSALB{1,jj};
    end
    clear tmpSALF tmpSALB
end
% clear INITSALS

%% normalize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
for cc=1:length(INITSALS_F{1,1})
    SAL{1,cc} = normalizeSal(SAL{1,cc});
end
clear INITSALS_F INITSALS_B
end