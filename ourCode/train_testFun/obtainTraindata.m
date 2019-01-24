function [trainData,trainLabel] = obtainTraindata(labelInfor, feadata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 由 labelInfor 推知训练样本 
% labelInfor 各尺度下各区域的标签: 100 无对象； 50 模糊样本； 1 正样本； 0 负样本
% feadata 各尺度下各区域的特征：各尺度所有区域以此排列
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