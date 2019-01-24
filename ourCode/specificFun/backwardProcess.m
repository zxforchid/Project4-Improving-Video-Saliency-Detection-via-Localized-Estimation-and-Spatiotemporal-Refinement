function [backwardSals] = backwardProcess(frames,param,forwardSals,Flows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������ N-1--->1
% frames           ����Ƶ֡��Ϣ
% param            ����
% forwardSal       ǰ��Ԥ��Ľ��
% Flows            ����֡��Ӧ�Ĺ�������
% backwardSal      ����Ԥ��Ľ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
backwardSals = cell(1,length(frames)-1);
for f = (length(frames)-1):-1:1   
    % NW=1
    if f==1 || f==(length(frames)-1)
        [tmpSal,~] = processEnds(Flows{1,f},forwardSals{1,f},frames{1,f},param);
        backwardSals{1,f} = tmpSal;
        forwardSals{1,f}  = tmpSal;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ�������� 
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