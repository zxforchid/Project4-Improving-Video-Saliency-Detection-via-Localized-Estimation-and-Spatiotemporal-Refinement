function [labelInfor] = sampleSelection_3w(gt,spInfor,param,ii)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 样本选择
% direction 'F' 'B'
% conFID 样本对应的帧标号  1,2，3  or  1,2,3,4,5
% traindatas/trainlabels 训练数据
% PCONF 最原始样本选取比例
% 
% 2017.04.11 21:19PM
% 根据方向，获取样本标签;适用于3窗口的
% 2017.04.17 22:41PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
%% 1 收集 newindexs & initindexs
direction = param.direction;
switch direction
    case 'F' % 前向
        if ii<2 % 1
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else % 2,3
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
        
    case 'B' % 后向
        if ii>2 % 3
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else % 1,2
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end
clear gt spInfor param ii
end