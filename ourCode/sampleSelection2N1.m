function [labelInfor] = sampleSelection2N1(gt,spInfor,param,ii,ff)
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
% 对第 2 & N-1 帧建立的窗口选择样本；窗口中仅有4帧；其中ii=3是当前窗口的中心
% ff 用于确定当前帧的编号
% 2017.04.21 8:24AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     labelInfor = labelExtract1(gt,spInfor,param.OB_ths);
%% 2 收集 newindexs & initindexs
direction = param.direction;
frameNum = param.frameNum;
if ff==2 % 1,2,3,4帧，第2帧为中心，对应ii=3
switch direction
    case 'F' % 前向:1更新，对应ii=4
        if ii==4 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);%  [0.8,0]
        end
        
    case 'B' % 后向：3,4已更新；对应ii=1,2
        if ii<3 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end
end

%% N-1
if ff==(frameNum-1) % N-3,N-2,N-1,N帧，第N-1帧为中心；对应ii=3
switch direction
    case 'F' % 前向：N-3,N-2帧已更新,对应 ii=1,2
        if ii<3 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
        
    case 'B' % 后向:N更新，对应ii=4
        if ii==4 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths1);% [0.75,0.05]
        else 
           labelInfor = labelExtract1(gt,spInfor,param.OB_ths);% [0.8,0]
        end
end  
end
clear gt spInfor param ii
end