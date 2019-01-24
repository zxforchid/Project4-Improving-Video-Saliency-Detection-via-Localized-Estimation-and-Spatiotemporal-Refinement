function GGG = obtainFBSal_MMI3_1(INITSALS_F,INITSALS_B,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% ����ƽ��������ͼ�� SAL
% 2017.03.10 13:55PM
% ����ǰ����������ͼ���ں�
% 2017.03.24  21:33PM
% ���ڸ�ģ�ͷֱ����,��ÿһ��ģ���½����ں�
% 2017.03.28 9:49AM
% ���� f ֡��ӣ����㱣��
% GGG ���صĵ� ff ֡��ǰ����֮�͵Ľ��
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
    
%     SALS{1,mm} = tmpModelSal;% ����SALS��Ӧ�ڵ�ǰģ�͵�������ͼ
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