function ensemble1= EasyEnsemble3(trainset, traintarget, param)
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% Input:
%   trainset: n-by-d training set
%   traintarget: n-by-1 training target
%   catidx: indicates which attributes are discrete ones (Note: start from 1)
%   T: sample $T$ subsets of negtive examples
%   rounds: use $rounds$ iterations to train each AdaBoost classifier
% Output:
%   ensemble: EasyEnsemble classifier, a structure variable

% Copyright: Xu-Ying Liu, Jianxin Wu, and Zhi-Hua Zhou, 2009
% Contact: Xu-Ying Liu (liuxy@lamda.nju.edu.cn)

%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% param: num_tree,T,rounds
% revised by xiaofei zhou, 2017.03.29 8:54AM
% hirchical model, 即先从多数类抽取 P1 比例的样本（2/3）；
% 然后每个子集的多数类中再抽取 2倍 |少数类| 的多数类样本（2|P|）；
% 基于此构建各弱分类器！！！
% 2017.03.29 23:10PM
% 对应于idea3,从多数类T次抽取 PP2 比例的样本（2/3），并结合原少数类样本，构成
% 各训练子集，得到对应的各弱分类器，最后利用adaboost算法得到最终的强分类器
% 2017.03.30 15:13PM
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
opt.shrinkageFactor = 0.1;
opt.subsamplingFactor = 0.5;
opt.maxTreeDepth = uint32(2);% 10  % this was the default before customization
opt.randSeed = uint32(rand()*1000); % param.randSeed;
opt.loss = 'exploss';

%% A 随机抽样，构造弱分类器 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% rounds = param.rounds;
% ensemble = struct('scalemap',{},'trees',{},'votes',{},'traintarget',{},'trainresult',{});
poscount = sum(traintarget==1);
negcount = length(traintarget)-poscount;
posset = trainset(traintarget==1,:);
negset = trainset(traintarget==0,:);

% 1 获取多数类 & 少数类
if poscount<negcount
    mojorClass_data = negset;
    mojorClass_label = zeros(negcount,1);
    minorClass_data = posset;
    minorClass_label = ones(poscount,1);
else
    mojorClass_data = posset;
    mojorClass_label = ones(poscount,1);
    minorClass_data = negset;
    minorClass_label = zeros(negcount,1);
end
clear posset negset poscount negcount

minorCount = size(minorClass_data,1);
majorCount = size(mojorClass_data,1);
mojorClass_data = mojorClass_data(randperm(majorCount),:);% 置乱

% 2 随机抽样本，构造训练子集，获取弱分类器
ensemble = struct;
ensemble.scalemap    = cell(param.T,1);
ensemble.trees       = cell(param.T,1);
ensemble.votes       = cell(param.T,1);
ensemble.traintarget = cell(param.T,1);
ensemble.trainresult = cell(param.T,1);
opt.importance = 0;
opt.do_trace = 0;
for i=1:param.T
    i
    % 2.1 每次随机抽取多数类样本的|PP2|比例
    majorNum = round((param.PP2)*majorCount);
    if majorNum<minorCount
        majorNum = minorCount;
    end
    % 2.2 训练子集
    majorset_data = mojorClass_data(1:majorNum,:);
    majorset_label = mojorClass_label(1:majorNum,:);
    curtrainset = [majorset_data;minorClass_data];
    curtarget = [majorset_label;minorClass_label];
    
    % 2.3 training
    [curtrainset1,scalemap] = scaleForSVM_corrected1(curtrainset,0,1);% 归一化
    ensemble.scalemap{i} = scalemap;
    
    opt.mtry = uint32(ceil(sqrt(size(curtrainset1,2))));% 特征维数
    curtarget(curtarget==0) = -1;
    tree = SQBMatrixTrain(single(curtrainset1), curtarget, uint32(param.num_tree), opt);
%     mtry = floor(sqrt(size(curtrainset1,2)));% 特征维数
%     tree = classRF_train(curtrainset1,curtarget, param.num_tree, mtry);
%     tree = classRF_train(curtrainset1,curtarget, param.num_tree, mtry, opt);
    ensemble.trees{i} = tree;
        
    % 2.4 testing: trainset/traintarget,即用原始训练集进行测试
    [trainset1] = scaleForSVM_corrected2(trainset,scalemap.MIN,scalemap.MAX,0,1);% 归一化
%     [trainresult,votes] = classRF_predict(trainset1,tree);
%     ensemble.votes{i} = max(votes,[],2)/(param.num_tree);

    % 新的随机森林框架
    pred = SQBMatrixPredict( tree, single(trainset1) );
    trainresult = double(pred > 0);% 1/0
    ensemble.votes{i} = pred;% NOTE: 有正有负，大于0 pos,小于等于0 neg,类似于SVM的决策值!!!
    ensemble.traintarget{i} = traintarget;
    ensemble.trainresult{i} = trainresult;
    
    % 2.5 重新置乱多数类
    mojorClass_data = mojorClass_data(randperm(majorCount),:);
    
    clear majorset_data  majorset_label curtrainset curtarget
    clear curtrainset1 scalemap tree mtry pred
    clear trainset1 trainresult votes
end


%% B 于原始训练集，利用Adaboost 构造强分类器 &&&&&&&&&&&&&&&&&&&&&&&
% ensemble1 = struct('scalemap',{},'trees',{},'alpha',{});
% 正负样本权重相同 2017.04.22, 13:46PM
weight = ones(size(traintarget))/size(traintarget,1);

% % 为正负样本分配不同权重,2017.04.22, 13:46PM
% weight = zeros(size(traintarget));
% weight(traintarget==1) = 1/sum(traintarget==1);
% weight(traintarget==0) = 1/sum(traintarget==0);
% weight = weight / sum(weight);

nn=1;
for jj=1:param.T
    jj
    votes       = ensemble.votes{jj};
    trainresult = ensemble.trainresult{jj};
    traintarget = ensemble.traintarget{jj};
    y_dec       = weight.*abs(votes);% 类似于 luhuchuan 的 y_dec = D{fi} .* abs(tdec{j}');  
    bb = 0.5 * log(sum(y_dec(trainresult==traintarget))/(sum(y_dec(trainresult~=traintarget))+eps));% 弱分类器连接权重
    if bb<0 break; end
%     ensemble1.alpha        = [ensemble1.alpha;bb];
    ensemble1.scalemap{nn,1} = ensemble.scalemap{jj};
    ensemble1.trees{nn,1}    = ensemble.trees{jj};
    ensemble1.alpha(nn,1)    = bb;
    
%     trainresult1 = trainresult;
%     trainresult1(trainresult1==0)=-1;
%     votes = votes.*trainresult1;
%     clear trainresult1 trainresult 
    traintarget1 = traintarget;
    traintarget1(traintarget1==0)=-1;
    weight = weight .* exp(-bb*votes.*traintarget1); 
%     weight = weight .* exp(-ensemble.alpha(nn)*votes.*traintarget1); 
    if sum(weight(:))==0
        weight = weight / (sum(weight(:))+eps);% 保证weight不为零
    else
        weight = weight / sum(weight(:));
    end
    clear votes traintarget1 traintarget bb
    
    nn = nn + 1;
end

clear ensemble
clear trainset traintarget param

clear trainset traintarget param
end

%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
% % 1 获取弱分类器
% function ens = weakFun(curtrainset,curtarget,param,opt)
%     ens = struct('scalemap',{},'trees',{},'votes',{},'traintarget',{},'trainresult',{});
%     % training
%     [curtrainset1,scalemap] = scaleForSVM_corrected1(curtrainset,0,1);% 归一化
%     ens.scalemap = scalemap;
%     mtry = floor(sqrt(size(curtrainset1,2)));% 特征维数
%     tree = classRF_train(curtrainset1,curtarget, param.num_tree, mtry, opt);
%     ens.trees = tree;
%     clear boostset1
%     
%     % testing
%     [trainresult,votes] = classRF_predict(curtrainset1,tree);
%     ens.votes = max(votes,[],2)/(param.num_tree);
%     ens.traintarget = curtarget;
%     ens.trainresult = trainresult;
%     clear curtrainset1 votes trainresult tree scalemap
%     
%     clear curtrainset curtarget param opt
% %     ens = AdaBoost(curtrainset,curtarget,param);% node classifier   
% %     ensemble(node) = ens;  clear ens  
% end