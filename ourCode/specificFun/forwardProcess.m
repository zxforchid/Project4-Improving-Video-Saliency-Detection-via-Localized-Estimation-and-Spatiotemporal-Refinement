function [forwardSal] = forwardProcess(frames,param,initSals,Flows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ǰ���� 1--->N-1
% frames           ����Ƶ֡��Ϣ
% param            ����
% initSals         ԭʼ�ĳ�ʼ������ͼ
% Flows            ����֡��Ӧ�Ĺ�������
% forwardSal       ǰ��Ԥ��Ľ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
forwardSal = cell(1,length(frames)-1);
for f = 1:(length(frames)-1)   
    % NW=1
    if f==1 || f==(length(frames)-1)
        [tmpSal,~] = processEnds(Flows{1,f},initSals{1,f},frames{1,f},param);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ�������� 
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

