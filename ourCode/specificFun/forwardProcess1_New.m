% function [initSals,forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
% function [initSals] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
function [initSals,forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
% function [forwardSal] = forwardProcess1_New(frames,spInfors,Feas,initSals,param)
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
forwardSal = cell(1,length(frames));
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
        [model1,model2,tmpSal] = processEnds2_0_New(frames,Feas,spInfors,initSals,param,f);
    end
    
%     forwardSal{1,f} = tmpSal;
    tmpSal1 = weak_strong_fusion(initSals{1,f},tmpSal,frames{1,f},param.weights);% ��strong + weak�Ľ�������и���
    tmpSal1 = SOPFun(Feas{1,f},spInfors{1,f},tmpSal1);   
    
    tmpSal1 = graphCut_Refine(frames{1,f},tmpSal1); % ������ 2017.05.05
    tmpSal1 = normalizeSal(guidedfilter(tmpSal1,tmpSal1,6,0.1));
    
    forwardSal{1,f} = tmpSal;% ������� strong �����2017.05.07 10:34AM
    initSals{1,f} = tmpSal1;% ������桢�������յĽ��
    
% %     tmpSal1 = normalizeSal(SOPFun(Feas{1,f},spInfors{1,f},tmpSal1) + tmpSal1);    
% %     initSals{1,f}   = tmpSal1;
    
% % %     forwardSal{1,f}   = tmpSal1;% ������ 2017.05.05
% %     sal = graphCut_Refine(frames{1,f},tmpSal1); % ������ 2017.05.05
% %     sal = normalizeSal(guidedfilter(sal,sal,6,0.1));
% %     initSals{1,f}   = sal;% ��Ӧ�ĵ�һ֡��������ͼҪ�ı䣬Ϊ��������          
    clear tmpSal tmpSal1 sal
    
    %% clear һЩ�ù�������  initSals & initSalsF
    if f<=(length(frames)-1) && f>=2% 2~N-1 
       frames{1,f-1} = [];
       spInfors{1,f-1} = [];
    end
       
    if f==length(frames)% N
        frames{1,f-1} = [];
        spInfors{1,f-1} = [];
        frames{1,f} = [];
        spInfors{1,f} = [];
    end
end
clear frames spInfors Feas param
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = SOPFun(feadata,spInfor,tmpSal1)
scaleNum = length(spInfor);
[height,width,dims]  = size(tmpSal1);
result = 0;
for ss = 1:scaleNum
    adjcMatrix = spInfor{ss,1}.adjcMatrix;
    colDistM   = spInfor{ss,1}.colDistM;
    bdIds      = spInfor{ss,1}.bdIds;
    pixelList  = spInfor{ss,1}.pixelList;
    
    tempFea = feadata{1,ss};
    motionFea = double(tempFea(:,7:8));
    motionDistM = GetDistanceMatrix(motionFea);
    clear tmpFea
    
    
    FGWEIGHT = GetMeanColor(tmpSal1, pixelList);
    
    % APP
    [clipVal, geoSigma, neiSigmaAPP] = EstimateDynamicParas(adjcMatrix, colDistM);
    [bgProb, bdCon, bgWeightAPP] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    clear clipVal geoSigma bgProb bdCon
    
    % motion
    [clipVal, geoSigma, neiSigmaMOTION] = EstimateDynamicParas(adjcMatrix, motionDistM);
    [bgProb, bdCon, bgWeightMOTION] = EstimateBgProb(motionDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    clear clipVal geoSigma bgProb bdCon
    
    bgWeight = bgWeightAPP + bgWeightMOTION;
    bgWeight = normalizeSal(bgWeight);
    SalValue = SaliencyOptimizationNew(adjcMatrix, bdIds, motionDistM, colDistM, neiSigmaMOTION,neiSigmaAPP, bgWeight, FGWEIGHT);
    
    clear neiSigmaMOTION neiSigmaAPP bgWeightAPP bgWeightMOTION
    clear bgProb bdCon bgWeight
    
    [SalValue_Img, ~] = CreateImageFromSPs(SalValue, pixelList, height, width, true);
    result  = result + SalValue_Img;
    
    clear adjcMatrix colDistM bdIds pixelList FGWEIGHT 
    clear clipVal geoSigma neiSigma
    clear bgProb bdCon bgWeight SalValue SalValue_Img
end

result  = result + tmpSal1;
result = normalizeSal(result);
    
clear spInfor tmpSal1
end