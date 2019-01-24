function tmodel = baggingTrainRFNew(trn_sal_data, trn_sal_lab, param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% baggingʽ�����ɭ��ѵ��
% �����²�����ʽ��ͬ��Ҫע�⣡����
% 
% trainData  ѵ�������� sampleNum*feaDim
% trainLabel ѵ����ǩ�� sampleNum*1
% param      ��������
% tmodel     ���ص�ѵ��ģ��
% 2017.3.1 19:46PM
% ����zhihua zhou ��classImbalance ���֮��
% 2017.03.29  10:55AM
% param.conFID ֮֡��־
% 2017.04.11
% xiaofei zhou,shanghai university
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% training &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% param.num_tree = 100;
% param.T = 4; % ��������
% param.rounds = 10; % ÿ�γ����õ���ģ�͵����������ĸ���
% param.beta = 1.2; % ÿ�γ��������������ı���

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