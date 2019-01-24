function [forwardSal] = forwardProcess2(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ǰ���� 1--->N-1����ģ���ں�
% frames     ��֮֡ͼ����Ϣ
% spInfors   �ָ���Ϣ
% Feas       ��������
% initSals   ��ʼ������ͼ
% forwardSal ǰ��Ԥ��Ľ��
% 2017.03.10 10:41AM
% copyright by xiaofei zhou, shanghai university
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
forwardSal = cell(1,length(frames)-1);
for f = 1:(length(frames)-1)   
    % NW=1
    if f==1 || f==(length(frames)-1)
        [tmpSal,~] = processEnds_0(frames{1,f},Feas{1,f},spInfors{1,f},initSals{1,f},param);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ�������� 
    end
            
    % NW=3
    if f==2 || f==(length(frames)-2) 
        [tmpSal] = processEnds1_0(frames,Feas,spInfors,initSals,param,f);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-3) 
        [tmpSal] = processEnds2_0(frames,Feas,spInfors,initSals,param,f);
        forwardSal{1,f} = tmpSal;
        initSals{1,f}   = tmpSal;
    end
            
    clear tmpSal
end
clear frames spInfors Feas initSals param
end

