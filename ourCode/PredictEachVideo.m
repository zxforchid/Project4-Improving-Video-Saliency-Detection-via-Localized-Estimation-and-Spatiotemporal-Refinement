function PredictEachVideo(param, frame_names,videoFea,videoIm,videoSpinor, ...
                     trainData,videoIDS,tmodelss,tmodel,saliencyMapPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 利用整体训练得到的model & 训练集中各model进行测试
% videoFea  1*帧数 cell, videoIm/videoSpinor亦是
% trainData  所有视频、帧之区域集合矩阵
% 2017.03.06
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainData = single(trainData);
%% 0 获取当前视频的特征矩阵（所有帧所有尺度下的所有区域）
videoFeaMatrix = [];
for ii=1:length(videoFea)
    tmpFea1 = videoFea{1,ii};% 每一帧
    for jj=1:length(tmpFea1)
        tmpFea2 = tmpFea1{1,jj}; % 各尺度
        videoFeaMatrix = [videoFeaMatrix;tmpFea2];
        clear tmpFea2
    end
    clear tmpFea1
end
videoFeaMatrix = single(videoFeaMatrix);

% 重新分配model
[n1,n2] = size(tmodelss);
videoModels = cell(1,n2);
for ii=1:n2 % n2为训练集中的视频数目
    tmpmodels = cell(n1,1);
    for jj=1:n1 % 每个视频训练得到的model
        tmpmodels{jj,1} = tmodelss{jj,ii};
    end
    videoModels{1,ii} = tmpmodels;
    clear tmpmodels
end
clear tmodelss
%% 1. 于训练集中寻找相似 videos 
numVideo = unique(videoIDS);
values = [];
for cc=1:length(numVideo)
    indexs = find(videoIDS==cc);% 第 ii 号视频
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
    
%     % 当前视频与任意一视频的距离（各区域对应最小距离）
%     for dd=1:size(videoFeaMatrix,1)
%         diff = repmat(videoFeaMatrix(dd,:),size(tmpVideoData,1),1) - tmpVideoData;
%         diff = sum((diff.^2),2);
%         diffs = [diffs;min(diff)];
%         clear diff
%     end
%     values = [values;sum(diffs)];% 所有区域的距离之和,作为两视频之间的距离
        
%     clear tmpVideoData indexs
end
% 升序排列：x 值 value， y(1)值 index, 表示距离最小者对应的视频
[x,y] = sort(values);
clear trainData videoIDS values

%% 2 利用当前视频对应的相似视频的 model 进行预测 &&&&&&&&&&&&&&&&&&&&
Sals = cell(1,param.topN + 1);
for kk=1:param.topN
    tmpIndex = y(kk);
    tmpModel = videoModels{1,tmpIndex};
    Sals{1,kk} = prediction(videoIm,videoFea,videoSpinor,tmpModel);
    clear tmpIndex tmpModel
end
clear videoModels
%% 3 利用整体之 model 进行预测 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Sals{1,param.topN + 1} = prediction(videoIm,videoFea,videoSpinor,tmodel);
clear tmodel videoIm videoFea videoSpinor
 
%% 4 fusion
integrateSals(Sals,frame_names,saliencyMapPath);
clear frame_names saliencyMapPath Sals

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 利用任意一模型对当前视频进行预测
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

% 2 融合不同来源的显著性图,并保存结果
function integrateSals(Sals,frame_names,saliencyMapPath)
% 2.1 initialization
tmpSals = Sals{1,1};
tmpsalMatrix = zeros(size(tmpSals{1,1},1),size(tmpSals{1,1},2),length(tmpSals));
clear tmpSals

% 2.2 赋值，转化为n阶矩阵
for ii=1:length(Sals)
    tmpSals = Sals{1,ii};% 每一种model对应下的所有帧
    for jj=1:length(tmpSals)
        tmpsalMatrix(:,:,jj) = tmpsalMatrix(:,:,jj) + tmpSals{1,jj};
    end
    clear tmpSals
end
clear Sals

% 2.3 归一化，保存
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


