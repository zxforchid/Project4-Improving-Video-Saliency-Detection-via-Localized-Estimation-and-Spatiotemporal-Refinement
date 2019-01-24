function [backwardSals] = backwardProcess1(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 后向处理 
% frames      各帧之图像信息
% spInfors    分割信息
% Feas        区域特征
% initSals    初始显著性图   
% 注意： 输入的信息名字、数量均是一一对应的！！！
% backwardSal 反向预测的结果
% 2017.03.10 10:41AM
% copyright by xiaofei zhou, shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
backwardSals = cell(1,length(frames));
for f = length(frames):-1:1   
    % NW=1
    if f==1 || f==length(frames)
        [tmpSal] = processEnds_0(frames{1,f},Feas{1,f},spInfors{1,f},initSals{1,f},param);
        backwardSals{1,f} = tmpSal;
        tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal);
        initSals{1,f}   = tmpSal1;% 对应的第一帧的显著性图要改变，为后续服务 
    end
            
    % NW=3
    if f==2 || f==(length(frames)-1)  
        [tmpSal] = processEnds1_0(frames,Feas,spInfors,initSals,param,f);
        backwardSals{1,f} = tmpSal;
        tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal);
        initSals{1,f}   = tmpSal1;
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-2) 
        [tmpSal] = processEnds2_0(frames,Feas,spInfors,initSals,param,f);
        backwardSals{1,f} = tmpSal;
        tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal);
        initSals{1,f}   = tmpSal1;
    end   
    clear tmpSal tmpSal1
end
clear frames param initSals Flows
end