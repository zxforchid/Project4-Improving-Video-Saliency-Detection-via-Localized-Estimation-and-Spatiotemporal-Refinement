function ensemble= EasyEnsemble2(trainset, traintarget, param)
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
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

% % ensemble = struct('scalemap',{},'trees',{},'alpha',{});
ensemble = [];
poscount = sum(traintarget==1);
negcount = length(traintarget)-poscount;
posset = trainset(traintarget==1,:);
negset = trainset(traintarget==0,:);


%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
if negcount>poscount % 负样本数目远远大于正样本，负样本为多数类
fprintf('\n negtive larger than positive ...')
negset = negset(randperm(negcount),:);
for node=1:param.T % stopping criteria
%     node
    % 负样本（多数类）的数目为自身的PP1（2/3）
    negNum = round((param.PP1)*negcount);
    if negNum<poscount
        negNum = poscount;
    end
    nset = negset(1:negNum,:);
    curtrainset = [posset;nset];
    curtarget = zeros(size(curtrainset,1),1);
    curtarget(1:poscount)=1;
    ens = AdaBoost2(curtrainset,curtarget, param);
    ensemble = [ensemble;ens];
%     ens = AdaBoost(curtrainset,curtarget,param);
%     ens = weakFun(curtrainset,curtarget,param,opt);
%     ensemble(node) = ens;    
    negset = negset(randperm(negcount),:);    
    clear negNum nset curtrainset curtarget ens
end

else % 正样本数目远远大于负样本，正样本为多数类
fprintf('\n positive larger than negtive ...')
posset = posset(randperm(poscount),:);    
for node=1:param.T % stopping criteria
    % 正样本（多数类）的数目为自身的PP1（2/3）
    posNum = round((param.PP1)*poscount);
    if posNum<negcount
        posNum = negcount;
    end
    pset = posset(1:posNum,:);
    curtrainset = [pset;negset];
    curtarget = zeros(size(curtrainset,1),1);
    curtarget(1:posNum)=1;
    ens = AdaBoost2(curtrainset,curtarget, param);
    ensemble = [ensemble;ens];
%     ens = weakFun(curtrainset,curtarget,param,opt);
%     ens = AdaBoost(curtrainset,curtarget,param);% node classifier    
%     ensemble(node) = ens;    
    posset = posset(randperm(poscount),:);       
    clear posNum pset curtrainset curtarget ens
end
end

%% combine all weak learners to form the final ensemble
depth = length(ensemble);
% ens = struct('scalemap',{},'trees',{},'votes',{},'traintarget',{},'trainresult',{});
% ensemble1 = struct('scalemap',{},'trees',{},'alpha',{});
ens= struct('scalemap',{},'trees',{},'alpha',{});
for i=1:depth
   ens(1).scalemap = [ens.scalemap; ensemble(i).scalemap];
   ens(1).trees    = [ens.trees; ensemble(i).trees];
   ens(1).alpha    = [ens.alpha; ensemble(i).alpha];
end
% ens.thresh = sum(ens.alpha)/2;
clear ensemble
ensemble = ens;

clear ens trainset traintarget param
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