function [backwardSals] = backwardProcess(frames,param,forwardSals,Flows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 后向处理 N-1--->1
% frames           各视频帧信息
% param            参数
% forwardSal       前向预测的结果
% Flows            所有帧对应的光流集合
% backwardSal      反向预测的结果
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
backwardSals = cell(1,length(frames)-1);
for f = (length(frames)-1):-1:1   
    % NW=1
    if f==1 || f==(length(frames)-1)
        [tmpSal,~] = processEnds(Flows{1,f},forwardSals{1,f},frames{1,f},param);
        backwardSals{1,f} = tmpSal;
        forwardSals{1,f}  = tmpSal;% 对应的第一帧的显著性图要改变，为后续服务 
    end
            
    % NW=3
    if f==2 || f==(length(frames)-2) 
        [tmpSal] = processEnds1(Flows,forwardSals,frames,param,f);
        backwardSals{1,f} = tmpSal;
        forwardSals{1,f}  = tmpSal;
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-3) 
        [tmpSal] = processEnds2(Flows,forwardSals,frames,param,f);
        backwardSals{1,f} = tmpSal;
        forwardSals{1,f}  = tmpSal;
    end   
    clear tmpSal
end
clear frames param forwardSals Flows
end