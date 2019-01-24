function tmodel = baggingTrainRF1(trn_sal_data, trn_sal_lab, param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baggingʽ�����ɭ��ѵ��
% �����²�����ʽ��ͬ��Ҫע�⣡����
% 
% trainData  ѵ�������� sampleNum*feaDim
% trainLabel ѵ����ǩ�� sampleNum*1
% param      ��������
% tmodel     ���ص�ѵ��ģ��
% 2017.3.1 19:46PM
% xiaofei zhou,shanghai university
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initial &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
opt.importance = 0;
opt.do_trace = 1;
num_tree = param.num_tree;% 200;
mtry = floor(sqrt(size(trn_sal_data,2)));% ����ά��

%% ��������������ȡƽ������  &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% �������iterm�Σ���Ϊ�趨��
iterNum = param.predictN;
% pos_ind = find(trn_sal_lab == 1);
% neg_ind = find(trn_sal_lab == 0);
% if length(pos_ind) > length(neg_ind)
%     iterNum = round(length(pos_ind)/length(neg_ind));
% else
%     iterNum = round(length(neg_ind)/length(pos_ind));
% end
clear pos_ind neg_ind
tmodel = cell(iterNum,1);
% parfor kk=1:iterNum
for kk=1:iterNum
% ƽ�����ݣ����ڴ��������¹�һ��������  balanceDataNew  2/3
[trn_sal_data_mappedA0, trn_sal_lab0] = balanceDataNew(trn_sal_data, trn_sal_lab, param.beta);
[trn_sal_data_mappedA0,scalemap] = scaleForSVM_corrected1(trn_sal_data_mappedA0,0,1);

% ѵ��
model = regRF_train( trn_sal_data_mappedA0, trn_sal_lab0, num_tree, mtry, opt );
segment_saliency_regressor = compressRegModel(model);
tmodel{kk,1}.dic           = segment_saliency_regressor;
tmodel{kk,1}.scalemap      = scalemap;

% clear trn_sal_data_mappedA0 trn_sal_lab0 segment_saliency_regressor scalemap
end 
clear trn_sal_data_mappedA trn_sal_lab



clear trn_sal_data trn_sal_lab 

clear D0 param
end