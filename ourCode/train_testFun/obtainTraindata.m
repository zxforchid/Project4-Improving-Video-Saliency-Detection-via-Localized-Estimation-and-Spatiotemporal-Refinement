function [trainData,trainLabel] = obtainTraindata(labelInfor, feadata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �� labelInfor ��֪ѵ������ 
% labelInfor ���߶��¸�����ı�ǩ: 100 �޶��� 50 ģ�������� 1 �������� 0 ������
% feadata ���߶��¸���������������߶����������Դ�����
% trainData
% trainLabel
% 2017.02.28  16:43PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scaleNum = length(labelInfor);
trainP = [];
trainN = [];
for ss=1:scaleNum
    ISOBJ = labelInfor{ss,1};
    indexP = find(ISOBJ==1);
    indexN = find(ISOBJ==0);
    tmpFea = feadata{1,ss};
    
    trainP = [trainP; tmpFea(indexP,:)]; 
    trainN = [trainN; tmpFea(indexN,:)];
    
    clear tmpFea ISOBJ indexP indexN
end
trainData = [trainP;trainN]; 
trainLabel = [ones(size(trainP,1),1);zeros(size(trainN,1),1)];
clear trainP trainN
clear labelInfor feadata

end