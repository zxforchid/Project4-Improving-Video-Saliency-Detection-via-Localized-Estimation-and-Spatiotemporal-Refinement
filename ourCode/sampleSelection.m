function [trainData,trainLabel] = sampleSelection(direction, conFID, traindatas, trainlabels, PCONF)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����ѡ��
% direction 'F' 'B'
% conFID ������Ӧ��֡���  1,2��3  or  1,2,3,4,5
% traindatas/trainlabels ѵ������
% PCONF ��ԭʼ����ѡȡ����
% 
% 2017.04.11 21:19PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frameNum = length(unique(conFID));
currID = frameNum/2 + 0.5;

%% 1 �ռ� newindexs & initindexs
NewIndexs = []; InitIndexs = [];
switch direction
    case 'F' % ǰ��
    % 1 �ռ����º�����(ȫ��)
    for ii=1:(currID-1)
        [index,xx] = find(conFID==ii);
        NewIndexs = [NewIndexs;index];
        clear index xx
    end

    % 2 �ռ���ԭʼ����(PCONF)
   for jj=currID:frameNum
        [index,xx] = find(conFID==jj);
        InitIndexs = [InitIndexs;index];
        clear index xx
    end
    
    case 'B' % ����
    % 1 �ռ����º�����(ȫ��)
    for ii=(currID+1):frameNum 
        [index,xx] = find(conFID==ii);
        NewIndexs = [NewIndexs;index];
        clear index xx
    end

    % 2 �ռ���ԭʼ����(PCONF)
    for jj=1:currID
        [index,xx] = find(conFID==jj);
        InitIndexs = [InitIndexs;index];
        clear index xx
    end

end

%% 2 ��ȡ����
% 1 ���µ�������ͼ��Ӧ��������ȫ����
NewData  = traindatas(NewIndexs,:);
NewLabel = trainlabels(NewIndexs,:);
clear NewIndexs

% 2 ��ԭʼ������ͼ��Ӧ������ ��PCONF�� 
InitTraindatas  = traindatas(InitIndexs,:);
InitTrainlabels = trainlabels(InitIndexs,:);
clear InitIndexs

% ��ȥ��������
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

% 3 �ϲ�
trainData = [NewData;InitData];
trainLabel = [NewLabel;InitLabel];
clear NewData InitData NewLabel InitLabel

clear direction conFID traindatas trainlabels
end