function [labelInfor] = sampleSelection_3w(gt,spInfor,param,ii)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����ѡ��
% direction 'F' 'B'
% conFID ������Ӧ��֡���  1,2��3  or  1,2,3,4,5
% traindatas/trainlabels ѵ������
% PCONF ��ԭʼ����ѡȡ����
% 
% 2017.04.11 21:19PM
% ���ݷ��򣬻�ȡ������ǩ;������3���ڵ�
% 2017.04.17 22:41PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
%% 1 �ռ� newindexs & initindexs
direction = param.direction;
switch direction
    case 'F' % ǰ��
        if ii<2 % 1
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else % 2,3
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
        
    case 'B' % ����
        if ii>2 % 3
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else % 1,2
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end
clear gt spInfor param ii
end