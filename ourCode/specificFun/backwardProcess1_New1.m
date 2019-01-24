function [INITSALS,backwardSals] = backwardProcess1_New1(frames,spInfors,Feas,INITSALS,param)
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
% ��ģ�͵��ںϣ�����
% INITSALS ������Ϊ��ʼ������ͼ�������Ϊ���º��������ͼ
% 2017.03.24 16::42PM
% copyright by xiaofei zhou, shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
backwardSals = cell(1,length(frames));
for f = length(frames):-1:1   
    f
    % NW=1
    if f==1 || f==length(frames)
        [tmpSal] = processEnds_0_New1(frames{1,f},Feas{1,f},spInfors{1,f},INITSALS,param,f);
        backwardSals{1,f} = tmpSal;
        INITSALS = weak_strong_fusionNew(INITSALS,f,tmpSal);
    end
            
    % NW=3
    if f==2 || f==(length(frames)-1)  
        [tmpSal] = processEnds1_0_New1(frames,Feas,spInfors,INITSALS,param,f);
        backwardSals{1,f} = tmpSal;
        INITSALS = weak_strong_fusionNew(INITSALS,f,tmpSal);
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-2) 
        [tmpSal] = processEnds2_0_New1(frames,Feas,spInfors,INITSALS,param,f);
        backwardSals{1,f} = tmpSal;
        INITSALS = weak_strong_fusionNew(INITSALS,f,tmpSal);  
    end   
%     imwrite(tmpSal,['.\Results0330\BB\',num2str(f),'_bb.png']) 
    clear tmpSal tmpSal1
end
clear frames param Flows
end