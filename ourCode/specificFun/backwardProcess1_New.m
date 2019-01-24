% function [initSals,backwardSals] = backwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [initSals] = backwardProcess1_New(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 后向处理 
% frames      各帧之图像信息
% spInfors    分割信息
% Feas        区域特征
% initSals    初始显著性图   
% 注意： 输入的信息名字、数量均是一一对应的！！！
% backwardSal 反向预测的结果
% 2017.03.10 10:41AM
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 引入zhouzhihua的工作（非平衡），采用新的程序
% 2017.03.29 13:32PM
% copyright by xiaofei zhou, shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% backwardSals = cell(1,length(frames));
for f = length(frames):-1:1   
    f
    % NW=1
    if f==1 || f==length(frames)
        [tmpSal] = processEnds_0(frames{1,f},Feas{1,f},spInfors{1,f},initSals{1,f},param);
    end
            
    % NW=3
    if f==2 || f==(length(frames)-1)  
        [tmpSal] = processEnds1_0_New(frames,Feas,spInfors,initSals,param,f);
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-2) 
        [tmpSal] = processEnds2_0_New(frames,Feas,spInfors,initSals,param,f);
    end
    
%     backwardSals{1,f} = tmpSal;
    tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal);
    initSals{1,f}   = tmpSal1;% 对应的第一帧的显著性图要改变，为后续服务 
    clear tmpSal tmpSal1
end
clear frames spInfors Feas param
end