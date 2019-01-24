function SALS = obtainFBSal_SMI_BB(forwardSals,backwardSals,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 融合 initSal forewardSal backwardSal 三种显著性图
% 2017.03.01 21:18PM
% 用于前后向显著性图的融合
% 2017.03.24  21:33PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    tmpFore = forwardSals{1,ff};
    tmpBack = backwardSals{1,ff};
    SALS = normalizeSal(tmpFore + tmpBack);% 多尺度平均意义下的像素级显著性图

    clear tmpFore tmpBack


clear  forwardSals backwardSals ff
end