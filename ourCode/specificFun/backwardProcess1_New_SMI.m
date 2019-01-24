% function [initSals,backwardSals] = backwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [SSSS] = backwardProcess1_New_SMI(frames,spInfors,Feas,initSals,initSalsF, ... 
                                            param,frame_names,saliencyMapPath_Our)
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
% �����У��䱣�棬��ʡ�ڴ�ռ�
% 2017.04.06  7:08AM
% ���У����ڸ��º��������ͼ���ſ�����ֵ
% 2017.04.17  22:15
% copyright by xiaofei zhou, shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% backwardSals = cell(1,length(frames));
param.direction = 'B';
SSSS=0;
for f = length(frames):-1:1   
    f
    % NW=1
    if f==1 || f==length(frames)
        [tmpSal] = processEnds1N(frames,Feas,spInfors,initSals,param,f);
%         [tmpSal] = processEnds1N(frames{1,f},Feas{1,f},spInfors{1,f},initSals{1,f},param);
    end
            
    % NW=3
    if f==2 || f==(length(frames)-1)  
        [tmpSal] = processEnds2N1(frames,Feas,spInfors,initSals,param,f);
    end
            
    % NW=5
    if f>=3 && f<=(length(frames)-2) 
        [tmpSal] = processEnds2_0_New(frames,Feas,spInfors,initSals,param,f);
    end
    
%     backwardSals{1,f} = tmpSal;
    tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal,frames{1,f});
    initSals{1,f}   = tmpSal1;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ�������� 
    clear tmpSal tmpSal1
    
    %% sal1/final
    GGG = normalizeSal(initSalsF{1,f} + initSals{1,f});
    GGG = graphCut_Refine(frames{1,f},GGG); 
    GGG = normalizeSal(guidedfilter(GGG,GGG,6,0.1));
    GGG = uint8(255*GGG);
    imwrite(GGG,[saliencyMapPath_Our,frame_names{1,f}(1:end-4),'_final.png']) 
    clear GGG
    
    
    %% backward���ǵ�ǰ֡���º��������ͼ,��Ӧ�� initSals
    GGG = initSals{1,f};
    GGG = uint8(255*GGG);
    imwrite(GGG,[saliencyMapPath_Our,frame_names{1,f}(1:end-4),'_backward.png']) 
    clear GGG
    
    %% clear һЩ�ù�������  initSals & initSalsF
    initSalsF{1,f} = [];
    if f<=(length(frames)-2) && f>=3% �޳�����Ҫ��֡��������ͼ����ʡ�ռ�
       initSals{1,f+2} = [];
       frames{1,f+2} = [];
       spInfors{1,f+2} = [];
    end
    
    if f==2 
        initSals{1,2} = [];
        initSals{1,3} = [];
        initSals{1,4} = [];
        
        frames{1,2} = [];
        frames{1,3} = [];
        frames{1,4} = [];
        
        spInfors{1,2} = [];
        spInfors{1,3} = [];
        spInfors{1,4} = [];
    end
    
    if f==1
        initSals{1,1} = [];
        frames{1,1}   = [];
        spInfors{1,1} = [];
    end
    
end
clear frames spInfors Feas param initSalsF initSals frame_names saliencyMapPath_Our
end