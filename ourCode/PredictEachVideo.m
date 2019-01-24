function PredictEachVideo(param, frame_names,videoFea,videoIm,videoSpinor, ...
                     trainData,videoIDS,tmodelss,tmodel,saliencyMapPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��������ѵ���õ���model & ѵ�����и�model���в���
% videoFea  1*֡�� cell, videoIm/videoSpinor����
% trainData  ������Ƶ��֮֡���򼯺Ͼ���
% 2017.03.06
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainData = single(trainData);
%% 0 ��ȡ��ǰ��Ƶ��������������֡���г߶��µ���������
videoFeaMatrix = [];
for ii=1:length(videoFea)
    tmpFea1 = videoFea{1,ii};% ÿһ֡
    for jj=1:length(tmpFea1)
        tmpFea2 = tmpFea1{1,jj}; % ���߶�
        videoFeaMatrix = [videoFeaMatrix;tmpFea2];
        clear tmpFea2
    end
    clear tmpFea1
end
videoFeaMatrix = single(videoFeaMatrix);

% ���·���model
[n1,n2] = size(tmodelss);
videoModels = cell(1,n2);
for ii=1:n2 % n2Ϊѵ�����е���Ƶ��Ŀ
    tmpmodels = cell(n1,1);
    for jj=1:n1 % ÿ����Ƶѵ���õ���model
        tmpmodels{jj,1} = tmodelss{jj,ii};
    end
    videoModels{1,ii} = tmpmodels;
    clear tmpmodels
end
clear tmodelss
%% 1. ��ѵ������Ѱ������ videos 
numVideo = unique(videoIDS);
values = [];
for cc=1:length(numVideo)
    indexs = find(videoIDS==cc);% �� ii ����Ƶ
    tmpVideoData = trainData(indexs,:);
    tmpVideoData = single(tmpVideoData);
    clear index
    
    DD = videoFeaMatrix*(tmpVideoData');% Nte*Ntr 
    DD = single(sqrt(DD));
    clear tmpVideoData
    
    tmpValue = sum((min(DD')'));
    clear DD
    
    values = [values;tmpValue];
    clear tmpValue
    
%     % ��ǰ��Ƶ������һ��Ƶ�ľ��루�������Ӧ��С���룩
%     for dd=1:size(videoFeaMatrix,1)
%         diff = repmat(videoFeaMatrix(dd,:),size(tmpVideoData,1),1) - tmpVideoData;
%         diff = sum((diff.^2),2);
%         diffs = [diffs;min(diff)];
%         clear diff
%     end
%     values = [values;sum(diffs)];% ��������ľ���֮��,��Ϊ����Ƶ֮��ľ���
        
%     clear tmpVideoData indexs
end
% �������У�x ֵ value�� y(1)ֵ index, ��ʾ������С�߶�Ӧ����Ƶ
[x,y] = sort(values);
clear trainData videoIDS values

%% 2 ���õ�ǰ��Ƶ��Ӧ��������Ƶ�� model ����Ԥ�� &&&&&&&&&&&&&&&&&&&&
Sals = cell(1,param.topN + 1);
for kk=1:param.topN
    tmpIndex = y(kk);
    tmpModel = videoModels{1,tmpIndex};
    Sals{1,kk} = prediction(videoIm,videoFea,videoSpinor,tmpModel);
    clear tmpIndex tmpModel
end
clear videoModels
%% 3 ��������֮ model ����Ԥ�� &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Sals{1,param.topN + 1} = prediction(videoIm,videoFea,videoSpinor,tmodel);
clear tmodel videoIm videoFea videoSpinor
 
%% 4 fusion
integrateSals(Sals,frame_names,saliencyMapPath);
clear frame_names saliencyMapPath Sals

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 ��������һģ�ͶԵ�ǰ��Ƶ����Ԥ��
function result = prediction(videoIm,videoFea,videoSpinor,tmodel)
result = cell(1,length(videoIm));
for ii=1:length(videoIm)
    tmpIm = videoIm{1,ii};
    tmpfeadata = videoFea{1,ii};
    tmpSPinfor = videoSpinor{1,ii};
    result{1,ii} = baggingTestRF(tmpIm, tmpfeadata, tmodel, tmpSPinfor);
    clear tmpIm tmpfeadata tmpSPinfor
end

clear videoIm videoFea videoSpinor tmodel
end

% 2 �ںϲ�ͬ��Դ��������ͼ,��������
function integrateSals(Sals,frame_names,saliencyMapPath)
% 2.1 initialization
tmpSals = Sals{1,1};
tmpsalMatrix = zeros(size(tmpSals{1,1},1),size(tmpSals{1,1},2),length(tmpSals));
clear tmpSals

% 2.2 ��ֵ��ת��Ϊn�׾���
for ii=1:length(Sals)
    tmpSals = Sals{1,ii};% ÿһ��model��Ӧ�µ�����֡
    for jj=1:length(tmpSals)
        tmpsalMatrix(:,:,jj) = tmpsalMatrix(:,:,jj) + tmpSals{1,jj};
    end
    clear tmpSals
end
clear Sals

% 2.3 ��һ��������
for kk=1:size(tmpsalMatrix,3)
    frame_sal = tmpsalMatrix(:,:,kk);
    frame_sal = normalizeSal(frame_sal);
    frame_sal = uint8(255*frame_sal);
    imwrite(frame_sal,[saliencyMapPath,frame_names{1,kk}(1:end-4),'_init.png']) 
    clear frame_sal
end

% 2.4 clear
clear frame_names saliencyMapPath
end


