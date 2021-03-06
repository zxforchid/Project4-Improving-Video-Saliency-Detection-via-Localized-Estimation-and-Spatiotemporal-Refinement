function [labelInfor] = sampleSelection1N(gt,spInfor,param,ii,ff)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 样本选择
% direction 'F' 'B'
% conFID 样本对应的帧标号  1,2，3  or  1,2,3,4,5
% traindatas/trainlabels 训练数据
% PCONF 最原始样本选取比例
% 2017.04.11 21:19PM
%
% 根据方向，获取样本标签;适用于3窗口的
% 2017.04.17 22:41PM
%
% 对第 1 & N 帧建立的窗口选择样本；窗口中仅有三帧；其中ii=3是当前窗口的中心
% ff 用于确定当前帧的编号
% 2017.04.21 8:24AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
%% 1 收集 newindexs & initindexs
direction = param.direction;
frameNum = param.frameNum;
if ff==1 % 1,2,3帧，第一帧为中心，对应ii=3
switch direction
    case 'F' % 前向无更新
        labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        
    case 'B' % 后向：2,3已更新；对应ii=1,2
        if ii<3 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end
end

%% N
if ff==frameNum % N-2,N-1,N帧，第N帧为中心；对应ii=3
switch direction
    case 'F' % 前向：N-2,N-1帧已更新,对应 ii=1,2
        if ii<3 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
        
    case 'B' % 后向无更新
        labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
%         if ii>2 % 3
%            labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
%         else % 1,2
%            labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
%         end
end  
end
clear gt spInfor param ii
end