function [SSSS,backwardSals] = backwardProcess1_New1_1(frames,spInfors, ...
                         Feas,INITSALS,INITSALS_F,param,frame_names,saliencyMapPath_Our)
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
% ���ڳ���Ƶ֡���У������б䱣�棬�Խ�ʡ�ռ�
% 2017.04.03 13:35PM
% copyright by xiaofei zhou, shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
backwardSals = cell(1,length(frames));
SSSS = 0;
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
     clear tmpSal tmpSal1
     %% ��ʡ�ռ� &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    % SAL1 ----------------------------------------------------------------
    GGG = obtainFBSal_MMI3_1(INITSALS_F,INITSALS,f);
    GGG = uint8(255*GGG);
    imwrite(GGG,[saliencyMapPath_Our,frame_names{1,f}(1:end-4),'_final.png']) 
    clear GGG
    
    for mm=1:length(INITSALS_F) % ��ʡ�ռ�
        INITSALS_F{1,mm}{1,f} = [];
%         tmpSALF = INITSALS_F{1,mm};
%         tmpSALF{1,f} = [];
    end
    
    % backward ------------------------------------------------------------
    GGG = obtainWeakSal_New(INITSALS,f);
    GGG = uint8(255*GGG);
    imwrite(GGG,[saliencyMapPath_Our,frame_names{1,f}(1:end-4),'_backward.png']) 
    clear GGG
    
    % clear ---------------------------------------------------------------
    if f<=(length(frames)-2) && f>=3% �޳�����Ҫ��֡��������ͼ����ʡ�ռ�
    for mm=1:length(INITSALS) 
        INITSALS{1,mm}{1,f+2} = [];
    end
    end
    
    if f==2 
    for mm=1:length(INITSALS) 
        INITSALS{1,mm}{1,2} = [];
        INITSALS{1,mm}{1,3} = [];
        INITSALS{1,mm}{1,4} = [];
    end
    end
    
    if f==1
    for mm=1:length(INITSALS) 
        INITSALS{1,mm}{1,1} = [];
    end
    end
    
   
end
% clear frames param Flows
clear frames spInfors Feas INITSALS INITSALS_F param frame_names saliencyMapPath_Our
end