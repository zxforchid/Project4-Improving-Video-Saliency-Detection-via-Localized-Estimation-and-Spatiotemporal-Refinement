function [trainData,trainLabel] = sampleSelection(direction, conFID, traindatas, trainlabels, PCONF)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 样本选择
% direction 'F' 'B'
% conFID 样本对应的帧标号  1,2，3  or  1,2,3,4,5
% traindatas/trainlabels 训练数据
% PCONF 最原始样本选取比例
% 
% 2017.04.11 21:19PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameNum = length(unique(conFID));
currID = frameNum/2 + 0.5;

%% 1 收集 newindexs & initindexs
NewIndexs = []; InitIndexs = [];
switch direction
    case 'F' % 前向
    % 1 收集更新后样本(全部)
    for ii=1:(currID-1)
        [index,xx] = find(conFID==ii);
        NewIndexs = [NewIndexs;index];
        clear index xx
    end

    % 2 收集最原始样本(PCONF)
   for jj=currID:frameNum
        [index,xx] = find(conFID==jj);
        InitIndexs = [InitIndexs;index];
        clear index xx
    end
    
    case 'B' % 后向
    % 1 收集更新后样本(全部)
    for ii=(currID+1):frameNum 
        [index,xx] = find(conFID==ii);
        NewIndexs = [NewIndexs;index];
        clear index xx
    end

    % 2 收集最原始样本(PCONF)
    for jj=1:currID
        [index,xx] = find(conFID==jj);
        InitIndexs = [InitIndexs;index];
        clear index xx
    end

end

%% 2 提取数据
% 1 更新的显著性图对应的样本（全部）
NewData  = traindatas(NewIndexs,:);
NewLabel = trainlabels(NewIndexs,:);
clear NewIndexs

% 2 最原始显著性图对应的样本 （PCONF） 
InitTraindatas  = traindatas(InitIndexs,:);
InitTrainlabels = trainlabels(InitIndexs,:);
clear InitIndexs

% 后去正负样本
trainPos = InitTraindatas(InitTrainlabels==1,:);
trainNeg = InitTraindatas(InitTrainlabels==0,:);
poscount = sum(InitTrainlabels==1);
negcount = sum(InitTrainlabels==0);
trainPos = trainPos(randperm(poscount),:);
trainNeg = trainNeg(randperm(negcount),:);
clear InitTraindatas InitTrainlabels 

poscount1 = round(PCONF*poscount);
negcount1 = round(PCONF*negcount);
trainPos1 = trainPos(1:poscount1,:);
trainNeg1 = trainNeg(1:negcount1,:);
clear trainPos trainNeg poscount negcount 

InitData  = [trainPos1;trainNeg1];
InitLabel = [ones(poscount1,1);zeros(negcount1,1)];
clear poscount1 negcount1 trainPos1 trainNeg1

% 3 合并
trainData = [NewData;InitData];
trainLabel = [NewLabel;InitLabel];
clear NewData InitData NewLabel InitLabel

clear direction conFID traindatas trainlabels
end