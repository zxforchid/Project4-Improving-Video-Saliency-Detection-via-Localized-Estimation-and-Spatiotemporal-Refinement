function tmodel = baggingTrainRFNew(trn_sal_data, trn_sal_lab, param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bagging式的随机森林训练
% 这里下采样方式不同，要注意！！！
% 
% trainData  训练特征， sampleNum*feaDim
% trainLabel 训练标签， sampleNum*1
% param      参数设置
% tmodel     返回的训练模型
% 2017.3.1 19:46PM
% 引入zhihua zhou 的classImbalance 解决之道
% 2017.03.29  10:55AM
% param.conFID 帧之标志
% 2017.04.11
% xiaofei zhou,shanghai university
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% training &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% param.num_tree = 100;
% param.T = 4; % 抽样次数
% param.rounds = 10; % 每次抽样得到的模型的弱分类器的个数
% param.beta = 1.2; % 每次抽样的正负样本的比例

% tmodel
% ens= struct('scalemap',{},'trees',{},'alpha',{},'thresh',{});
% tmodel = EasyEnsemble(trn_sal_data,trn_sal_lab,param);
EESign = param.EESign(1);
switch EESign
    case 2
        fprintf('\n tmodel ID = %d ',EESign)
        tmodel = EasyEnsemble2(trn_sal_data,trn_sal_lab,param);
    case 3
        fprintf('\n tmodel ID = %d ',EESign)
        tmodel = EasyEnsemble3(trn_sal_data,trn_sal_lab,param);
end


clear trn_sal_data trn_sal_lab 

end