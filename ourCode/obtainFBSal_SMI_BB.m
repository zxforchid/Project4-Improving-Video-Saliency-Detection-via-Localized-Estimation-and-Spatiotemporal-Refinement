function SALS = obtainFBSal_SMI_BB(forwardSals,backwardSals,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ں� initSal forewardSal backwardSal ����������ͼ
% 2017.03.01 21:18PM
% ����ǰ����������ͼ���ں�
% 2017.03.24  21:33PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    tmpFore = forwardSals{1,ff};
    tmpBack = backwardSals{1,ff};
    SALS = normalizeSal(tmpFore + tmpBack);% ��߶�ƽ�������µ����ؼ�������ͼ

    clear tmpFore tmpBack


clear  forwardSals backwardSals ff
end