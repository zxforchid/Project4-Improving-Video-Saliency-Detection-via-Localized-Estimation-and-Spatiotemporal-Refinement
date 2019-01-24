function result = baggingTestRF(im, feadata, model, spInfor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����ǰ��ѵ���õ���ģ�ͽ��е�test, ��ȡ��֡�ĳ�ʼ������ͼ����߶ȵ�ƽ����
% feadata  �൱��testing data
% model    generic��ģ��
% result   ���ص�������ͼ
% 
% 2017.03.01 15:04PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SP_SCALE_NUM = length(feadata);
[height,width,dims]  = size(im);

%% BEGIN &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
result = 0;% ��ʼԤ���������ؼ���
for ss=1:SP_SCALE_NUM %���߶��µ�Ԥ�� 
    tmpSP           = spInfor{ss,1};
    tmpPixellist    = tmpSP.pixelList;
    sp_sal_data     = feadata{1,ss};
    SALS = zeros(size(sp_sal_data,1),length(model));
    
   for kk=1:length(model)
    segment_saliency_regressor = model{kk,1}.dic;
    scalemap                   = model{kk,1}.scalemap;
    [sp_sal_data_mappedA] = scaleForSVM_corrected2(sp_sal_data,scalemap.MIN,scalemap.MAX,0,1);% ��һ��
    
    sp_sal_prob = regRF_predict( sp_sal_data_mappedA, segment_saliency_regressor );
    tmpSal = normalizeSal(sp_sal_prob);
    SALS(:,kk) = tmpSal;
    clear sp_sal_prob sp_sal_data_mappedA segment_saliency_regressor scalemap
    clear tmpSal
   end
   
   SalValue = sum(SALS,2);
   SalValue = normalizeSal(SalValue);
   [SalValue_Img, ~] = CreateImageFromSPs(SalValue, tmpPixellist, height, width, true);
   result  = result + SalValue_Img;
   
   clear SalValue_Img SALS tmpPixellist tmpSP sp_sal_data
end

result = normalizeSal(result);% ��߶�ƽ�������µ����ؼ�������ͼ

% result = graphCut_Refine(im,result); 
% result = normalizeSal(guidedfilter(result,result,6,0.1));
% result = normalizeSal(result);


clear im feadata model spInfor
end