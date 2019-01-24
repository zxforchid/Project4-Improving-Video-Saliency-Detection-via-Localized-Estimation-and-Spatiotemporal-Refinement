function [model1,model2,result] = baggingTestRFNew(im, feadata, model, spInfor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 基于前述训练得到的模型进行的test, 获取各帧的初始显著性图（多尺度的平均）
% feadata  相当于testing data
% model    generic的模型
% result   返回的显著性图
% 
% 2017.03.01 15:04PM
% 引入zhihua zhou 的classImbalance 解决之道
% tmodel = struct('scalemap',{},'trees',{},'alpha',{},'thresh',{});
% 2017.03.29  10:55AM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SP_SCALE_NUM = length(feadata);
[height,width,dims]  = size(im);

%% BEGIN &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
result = 0;% 初始预测结果，像素级的
model1 = 0;
model2 = 0;
for ss=1:SP_SCALE_NUM 
%     ss
    tmpSP           = spInfor{ss,1};
    tmpPixellist    = tmpSP.pixelList;
    sp_sal_data     = feadata{1,ss};
    
    [SALS,SalValue] = testNew0504(sp_sal_data,model);
% %     SalValue = EvaluateValue(sp_sal_data,model);% 单尺度预测

    SalValue1 = normalizeSal(SALS(:,1));
    [SalValue_Img1, ~] = CreateImageFromSPs(SalValue1, tmpPixellist, height, width, true);
    model1  = model1 + SalValue_Img1;
    
    SalValue2 = normalizeSal(SALS(:,2));
    [SalValue_Img2, ~] = CreateImageFromSPs(SalValue2, tmpPixellist, height, width, true);
    model2  = model2 + SalValue_Img2;

    SalValue = normalizeSal(SalValue);
    [SalValue_Img, ~] = CreateImageFromSPs(SalValue, tmpPixellist, height, width, true);
    result  = result + SalValue_Img;
  
   clear SalValue SalValue_Img tmpPixellist tmpSP sp_sal_data
end
model1 = normalizeSal(model1);
model2 = normalizeSal(model2);
result = normalizeSal(result);% 多尺度平均意义下的像素级显著性图

% result = graphCut_Refine(im,result); 
% result = normalizeSal(guidedfilter(result,result,6,0.1));
% result = normalizeSal(result);


clear im feadata model spInfor
end

function [SALS,SalValue] = testNew0504(sp_sal_data,models)
    sp_sal_data = double(sp_sal_data);
    SALS = zeros(size(sp_sal_data,1),length(models));
    for kk=1:length(models)
        model = models(1,kk);
        segment_saliency_regressor = model.dic;
        scalemap                   = model.scalemap;
        [sp_sal_data_mappedA]      = scaleForSVM_corrected2(sp_sal_data,scalemap.MIN,scalemap.MAX,0,1);% 归一化
    
        sp_sal_prob = regRF_predict( sp_sal_data_mappedA, segment_saliency_regressor );
        tmpSal      = normalizeSal(sp_sal_prob);
        SALS(:,kk)  = tmpSal;
    end
%     if length(models)==2
%         SalValue = SALS(:,1)*0.7 + SALS(:,2)*0.3;
% %         SalValue = SALS(:,1)*0.6 + SALS(:,2)*0.4;% 第一列对应当前帧的模型
%     else
%         SalValue = SALS;
%     end
%     SalValue = sum(SALS,2);

    if isempty(models)
        SalValue = zeros(size(sp_sal_data,1),1);
        fprintf('\n empty model!!!')
    else
        SalValue = sum(SALS,2);
    end
    clear sp_sal_data models
    clear segment_saliency_regressor scalemap sp_sal_data_mappedA sp_sal_prob
end