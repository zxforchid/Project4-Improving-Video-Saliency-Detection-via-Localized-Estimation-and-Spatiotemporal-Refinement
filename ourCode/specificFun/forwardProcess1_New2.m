% function [initSals,forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [initSals] = forwardProcess1_New2(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ǰ����: 
% frames     ��֮֡ͼ����Ϣ
% spInfors   �ָ���Ϣ
% Feas       ��������
% initSals   ��ʼ������ͼ  
% ע�⣺ �������Ϣ���֡���������һһ��Ӧ�ģ�����
% forwardSal ǰ��Ԥ��Ľ��
% 2017.03.10 10:41AM
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ����zhouzhihua�Ĺ�������ƽ�⣩�������µĳ���
% 2017.03.29 13:32PM
% ���У����ڸ��º��������ͼ���ſ�����ֵ
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
    tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal,frames{1,f});% ��strong + weak�Ľ�������и���
    initSals{1,f}   = tmpSal1;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ��������          
    clear tmpSal tmpSal1
    
    %% clear һЩ�ù�������  initSals & initSalsF
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

