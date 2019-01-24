% function [initSals,backwardSals] = backwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [initSals] = backwardProcess1_New(frames,spInfors,Feas,initSals,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������ 
% frames      ��֮֡ͼ����Ϣ
% spInfors    �ָ���Ϣ
% Feas        ��������
% initSals    ��ʼ������ͼ   
% ע�⣺ �������Ϣ���֡���������һһ��Ӧ�ģ�����
% backwardSal ����Ԥ��Ľ��
% 2017.03.10 10:41AM
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ����zhouzhihua�Ĺ�������ƽ�⣩�������µĳ���
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
    initSals{1,f}   = tmpSal1;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ�������� 
    clear tmpSal tmpSal1
end
clear frames spInfors Feas param
end