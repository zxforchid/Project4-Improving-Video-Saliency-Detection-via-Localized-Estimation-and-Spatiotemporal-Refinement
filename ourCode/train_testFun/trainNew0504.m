function tmodel = trainNew0504(trainData,trainLabel,param)
%% 2017.05.03 21:07PM
%% initial &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
trainData = double(trainData);
opt.importance = 0;
opt.do_trace = 1;
num_tree = param.num_tree;% 200;
mtry = floor(sqrt(size(trainData,2)));% ÌØÕ÷Î¬Êý

[trainData1,scalemap] = scaleForSVM_corrected1(trainData,0,1);

%% ÑµÁ· &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
model = regRF_train( trainData1, trainLabel, num_tree, mtry, opt );
segment_saliency_regressor = compressRegModel(model);
tmodel.dic           = segment_saliency_regressor;
tmodel.scalemap      = scalemap;

%% clear &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
clear trainData trainLabel param trainData1 segment_saliency_regressor scalemap
end