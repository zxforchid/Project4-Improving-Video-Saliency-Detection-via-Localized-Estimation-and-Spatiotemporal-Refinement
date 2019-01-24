function [forwardSal] = forwardProcess(frames,param,initSals,Flows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 前向处理 1--->N-1
% frames           各视频帧信息
% param            参数
% initSals         原始的初始显著性图
% Flows            所有帧对应的光流集合
% forwardSal       前向预测的结果
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
forwardSal = cell(1,length(frames)-1);
for f = 1:(length(frames)-1)   
    % NW=1
    if f==1 || f==(length(frames)-1)
        [tmpSal,~] = processEnds(Flows{1,f},initSals{1,f},frames{1,f},param);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;% 对应的第一帧的显著性图要改变，为后续服务 
    end
            
    % NW=3
    if f==2 || f==(length(frames)-2) 
        [tmpSal] = processEnds1(Flows,initSals,frames,param,f);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-3) 
        [tmpSal] = processEnds2(Flows,initSals,frames,param,f);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;
    end
            
    clear tmpSal
end
clear frames param initSals Flows
end

