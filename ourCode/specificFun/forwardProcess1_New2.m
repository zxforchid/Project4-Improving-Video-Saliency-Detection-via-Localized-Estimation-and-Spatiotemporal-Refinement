% function [initSals,forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [initSals] = forwardProcess1_New2(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 前向处理: 
% frames     各帧之图像信息
% spInfors   分割信息
% Feas       区域特征
% initSals   初始显著性图  
% 注意： 输入的信息名字、数量均是一一对应的！！！
% forwardSal 前向预测的结果
% 2017.03.10 10:41AM
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 引入zhouzhihua的工作（非平衡），采用新的程序
% 2017.03.29 13:32PM
% 并行，对于更新后的显著性图，放宽其阈值
% 2017.04.17  22:15
% copyright by xiaofei zhou, shanghai university
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% forwardSal = cell(1,length(frames));
param.direction = 'F';
for f = 1:length(frames)  
    f
    % NW=1
    if f==1 || f==length(frames)
        [tmpSal] = processEnds1N(frames,Feas,spInfors,initSals,param,f);
%         [tmpSal] = processEnds1N(frames{1,f},Feas{1,f},spInfors{1,f},initSals{1,f},param);
    end
          
    % NW=3
    if f==2 || f==(length(frames)-1) 
        [tmpSal] = processEnds2N1(frames,Feas,spInfors,initSals,param,f);
%         [tmpSal] = processEnds2N1(frames,Feas,spInfors,initSals,param,f);
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-2) 
        [tmpSal] = processEnds2_0_New(frames,Feas,spInfors,initSals,param,f);
    end
    
%     forwardSal{1,f} = tmpSal;
    tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal,frames{1,f});% 用strong + weak的结果来进行更新
    initSals{1,f}   = tmpSal1;% 对应的第一帧的显著性图要改变，为后续服务          
    clear tmpSal tmpSal1
    
    %% clear 一些用过的输入  initSals & initSalsF
    if f<=(length(frames)-2) && f>=3% 3~N-2 
       frames{1,f-2} = [];
       spInfors{1,f-2} = [];
    end
    
    if f==(length(frames)-1)  % N-1
        frames{1,f} = [];
        frames{1,f-1} = [];
        frames{1,f-2} = [];
        
        spInfors{1,f} = [];
        spInfors{1,f-1} = [];
        spInfors{1,f-2} = [];
    end
    
    if f==length(frames)% N
        frames{1,f} = [];
        spInfors{1,f} = [];
    end
end
clear frames spInfors Feas param
end

