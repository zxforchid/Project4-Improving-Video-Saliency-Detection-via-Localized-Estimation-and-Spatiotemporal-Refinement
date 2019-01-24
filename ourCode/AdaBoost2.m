function EEE = AdaBoost2(trainset, traintarget, param)
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% Input:
%   trainset: n-by-d training set
%   traintarget: n-by-1 training target
%   catidx: indicates which attributes are discrete ones (Note: start from 1)
%   rounds: use $rounds$ iterations to train each AdaBoost classifier
% Output:
%   ensemble: AdaBoost classifier, a structure variable
% Note: this method uses 'treefit' decision tree method in statistics toolbox to 
%   generate base classifiers 

% Copyright: Xu-Ying Liu, Jianxin Wu, and Zhi-Hua Zhou, 2009
% Contact: Xu-Ying Liu (liuxy@lamda.nju.edu.cn)
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% revised by xiaofei zhou, 
% param num_tree, rounds
% 2017.03.29 8:54AM
% 结合EasyEnsemble2，于该部分进行另一层级的抽样分解组合
% 2017.03.30 8:46AM
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
opt.shrinkageFactor = 0.1;
opt.subsamplingFactor = 0.5;
opt.maxTreeDepth = uint32(2);% 10  % this was the default before customization
opt.randSeed = uint32(rand()*1000); % param.randSeed;
opt.loss = 'exploss';
% numIters = 200;

% opt.importance = 0;
% opt.do_trace = 0;
% num_tree = param.num_tree;% 200;
rounds = param.rounds;

%% 构造弱分类器 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% 再次随机抽样，有放回随机抽取 rounds 次，数目等于少数类
trainPos = trainset(traintarget==1,:);
trainNeg = trainset(traintarget==0,:);
poscount = sum(traintarget==1);
negcount = sum(traintarget==0);

if poscount<negcount
    mojorClass_data = trainNeg;
    mojorClass_label = zeros(negcount,1);
    minorClass_data = trainPos;
    minorClass_label = ones(poscount,1);
else
    mojorClass_data = trainPos;
    mojorClass_label = ones(poscount,1);
    minorClass_data = trainNeg;
    minorClass_label = zeros(negcount,1);
end
clear trainPos trainNeg poscount negcount

minorCount = size(minorClass_data,1);
majorCount = size(mojorClass_data,1);
mojorClass_data = mojorClass_data(randperm(majorCount),:);% 多数类置乱

ensemble.scalemap = cell(rounds,1);
ensemble.trees = cell(rounds,1);
ensemble.votes = cell(rounds,1);
ensemble.traintarget = cell(rounds,1);
ensemble.trainresult = cell(rounds,1);
% ensemble.alpha = zeros(rounds,1);
% i=1;
for i=1:rounds
%     majorNum = minorCount;
    majorNum = round((param.PP1_1)*majorCount);% 每次从多数类中抽取 PP1_1 的样本
    if majorNum<minorCount
        majorNum = minorCount;
    end
    majorset_data = mojorClass_data(1:majorNum,:);
    majorset_label = mojorClass_label(1:majorNum,:);
    curtrainset = [majorset_data;minorClass_data];
    curtarget = [majorset_label;minorClass_label];
%     if sum(curtarget(:))==0
%         mojorClass_data = mojorClass_data(randperm(majorCount),:);
%         continue;
%     end
    
    % training
    [curtrainset1,scalemap] = scaleForSVM_corrected1(curtrainset,0,1);% 归一化
    ensemble.scalemap{i} = scalemap;
    %---- 2017.04.07 -----%
    % 新的随机森林框架
    opt.mtry = uint32(ceil(sqrt(size(curtrainset1,2))));% 特征维数
    curtarget(curtarget==0) = -1;
    tree = SQBMatrixTrain(single(curtrainset1), curtarget, uint32(param.num_tree), opt);
    
%     mtry = floor(sqrt(size(curtrainset1,2)));% 特征维数
%     tree = classRF_train(double(curtrainset1),curtarget, param.num_tree, mtry, opt);
    ensemble.trees{i} = tree;
    
    
    % testing: trainset/traintarget,即用原始训练集进行测试
    [trainset1] = scaleForSVM_corrected2(trainset,scalemap.MIN,scalemap.MAX,0,1);% 归一化
%     [trainresult,votes] = classRF_predict(double(trainset1),tree);
%     ensemble.votes{i} = max(votes,[],2)/(param.num_tree);

    % 新的随机森林框架
    pred = SQBMatrixPredict( tree, single(trainset1) );
    trainresult = double(pred > 0);% 1/0
    ensemble.votes{i} = pred;% NOTE: 有正有负，大于0 pos,小于等于0 neg,类似于SVM的决策值!!!
    ensemble.traintarget{i} = traintarget;
    ensemble.trainresult{i} = trainresult;
    
    % 重新置乱多数类
    mojorClass_data = mojorClass_data(randperm(majorCount),:);
    
    clear majorset_data  majorset_label curtrainset curtarget
    clear curtrainset1 scalemap tree
    clear trainset1 trainresult votes
end


%% adaboost 构建强分类器 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% ensemble1 = struct('scalemap',{},'trees',{},'alpha',{});
weight = ones(size(traintarget))/size(traintarget,1);
nn=1;
ensemble1.scalemap = cell(rounds,1);
ensemble1.trees = cell(rounds,1);
ensemble1.alpha = zeros(rounds,1);
for jj=1:rounds
    votes       = ensemble.votes{jj};% NOTE: 有正有负，大于0 pos,小于等于0 neg,类似于SVM的决策值!!!
    trainresult = ensemble.trainresult{jj};
    traintarget = ensemble.traintarget{jj};
    y_dec = weight.*abs(votes);% 类似于 luhuchuan 的 y_dec = D{fi} .* abs(tdec{j}');  
    bb = 0.5 * log(sum(y_dec(trainresult==traintarget))/(sum(y_dec(trainresult~=traintarget))+eps));
    if bb<0 break; end
%     ensemble1.alpha        = [ensemble1.alpha;bb];
    ensemble1.scalemap{nn,1} = ensemble.scalemap{jj};
    ensemble1.trees{nn,1}    = ensemble.trees{jj};
    ensemble1.alpha(nn,1)    = bb;
    
%     trainresult1 = trainresult;
%     trainresult1(trainresult1==0)=-1;% 1/-1
%     votes = votes.*trainresult1;
%     clear trainresult1 trainresult 
    traintarget1 = traintarget;
    traintarget1(traintarget1==0)=-1;
    
    % 同号，正确分类，后两项大于零，weight减少；否则，小于零，减少
    weight = weight .* exp(-bb*votes.*traintarget1); 
%     weight = weight .* exp(-ensemble.alpha(nn)*votes.*traintarget1); 
    weight = weight / sum(weight);
    clear votes traintarget1 traintarget bb
    
    nn = nn + 1;
end

clear ensemble
clear trainset traintarget param

%% 重新输出ens
if (nn-1)<rounds
    fprintf('\n nn<rounds: %d',nn-1)
ensemble2.scalemap = cell(nn-1,1);
ensemble2.trees = cell(nn-1,1);
ensemble2.alpha = zeros(nn-1,1);
for hhh=1:(nn-1)
    ensemble2.scalemap{hhh,1} = ensemble1.scalemap{hhh,1};
    ensemble2.trees{hhh,1}    = ensemble1.trees{hhh,1};
    ensemble2.alpha(hhh,1)    = ensemble1.alpha(hhh,1);
end
EEE = ensemble2;
clear ensemble1 ensemble2
else
EEE = ensemble1;   
clear ensemble1
end
end