function [labelInfor] = sampleSelection2N1(gt,spInfor,param,ii,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����ѡ��
% direction 'F' 'B'
% conFID ������Ӧ��֡���  1,2��3  or  1,2,3,4,5
% traindatas/trainlabels ѵ������
% PCONF ��ԭʼ����ѡȡ����
% 2017.04.11 21:19PM
%
% ���ݷ��򣬻�ȡ������ǩ;������3���ڵ�
% 2017.04.17 22:41PM
%
% �Ե� 2 & N-1 ֡�����Ĵ���ѡ�������������н���4֡������ii=3�ǵ�ǰ���ڵ�����
% ff ����ȷ����ǰ֡�ı��
% 2017.04.21 8:24AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
%% 2 �ռ� newindexs & initindexs
direction = param.direction;
frameNum = param.frameNum;
if ff==2 % 1,2,3,4֡����2֡Ϊ���ģ���Ӧii=3
switch direction
    case 'F' % ǰ��:1���£���Ӧii=4
        if ii==4 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);%  [0.8,0]
        end
        
    case 'B' % ����3,4�Ѹ��£���Ӧii=1,2
        if ii<3 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end
end

%% N-1
if ff==(frameNum-1) % N-3,N-2,N-1,N֡����N-1֡Ϊ���ģ���Ӧii=3
switch direction
    case 'F' % ǰ��N-3,N-2֡�Ѹ���,��Ӧ ii=1,2
        if ii<3 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
        
    case 'B' % ����:N���£���Ӧii=4
        if ii==4 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end  
end
clear gt spInfor param ii
end