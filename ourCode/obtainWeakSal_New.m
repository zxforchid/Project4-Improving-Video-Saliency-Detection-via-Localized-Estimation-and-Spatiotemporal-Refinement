function GGG = obtainWeakSal_New(INITSALS,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% ����ƽ��������ͼ�� weakSal�������ڵ�ǰ֡����ģ�����
% 2017.03.10 13:55PM
% ���� f ֡��ӣ����㱣��,���صĵ� ff ֡��ǰ����֮�͵Ľ��
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