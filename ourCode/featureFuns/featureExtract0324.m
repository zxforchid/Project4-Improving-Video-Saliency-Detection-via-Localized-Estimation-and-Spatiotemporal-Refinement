function  feadata = featureExtract0324(im, flow, spinfor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 特征提取
% im      输入图像 uint8结构
% flow    输入帧对应的光流场
% spinfor 输入帧对应的多尺度分割结果
% feadata 对应的特征（所有尺度下的）cell
% 
% 2017.02.28  15:50PM
% 2017.03.24 14:47PM
% 仅采用外观 Lab, 运动 幅值相位 及 位置信息
% 
% xiaofei zhou, shanghai university
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im = uint8(im);

%% 1、preparation work %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grayim_cur = rgb2gray(im);% 用于LBP
im = im2double(im);% 2016.12.02 15:38PM，输入为 unit8  0~1
[height,width,dims] = size(im);
ScaleNums = length(spinfor);

% color transform ------------------
im_R = im(:,:,1);
im_G = im(:,:,2);
im_B = im(:,:,3);

image_lab = rgb2lab( im );
im_L      = image_lab(:,:,1) / 100;
im_A      = image_lab(:,:,2) / 220 + 0.5;
im_B1     = image_lab(:,:,3) / 220 / 0.5;
clear  image_lab

% % LBP ------------------------------
% [imlbp,~] = LBP_uniform(double(grayim_cur));
% im_LBP = double( imlbp );
% clear imlbp grayim_cur

% motion --------------------------
curFlow = double(flow);
Magn    = sqrt(curFlow(:,:,1).^2+curFlow(:,:,2).^2);    
Ori     = atan2(-curFlow(:,:,1),curFlow(:,:,2));
clear curFlow flow
%% compute features of sp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feadata = cell(1,ScaleNums);
% feadata = [];
for ss=1:ScaleNums
    tmpSP = spinfor{ss,1};
    regionsLocation =  ...
        calculateRegionProps(tmpSP.spNum,tmpSP.idxcurrImage);
    sup_feat = [];
    for sp=1:tmpSP.spNum
	    ind       = regionsLocation{sp}.pixelInd;
	    indxy     = regionsLocation{sp}.pixelIndxy;
        
        %1 区域均值
	    meanall1 = [mean(im_L(ind)),mean(im_A(ind)),mean(im_B1(ind)), ...
                    mean(Magn(ind)),mean(Ori(ind))];
        meanall2 = [mean(indxy(:,2))/width,mean(indxy(:,1))/height];

        %2 区域方差 
        varall   = [var(im_L(ind)),var(im_A(ind)),var(im_B1(ind)), ...
                    var(Magn(ind)),var(Ori(ind))];
                
%         %1 区域均值
% 	    meanall1 = [mean(im_R(ind)),mean(im_G(ind)),mean(im_B(ind)), ...
%                     mean(im_L(ind)),mean(im_A(ind)),mean(im_B1(ind)), ...
%                     mean(im_LBP(ind)),mean(Magn(ind)),mean(Ori(ind))];
%         meanall2 = [mean(indxy(:,2))/width,mean(indxy(:,1))/height];
% %         color_weight(ind) = computeColorDist([R(ind) G(ind) B1(ind) L(ind) A(ind) B2(ind) XX/col YY/row],repmat(meanall, [length(ind), 1]));
% 
%         %2 区域方差 
%         varall   = [var(im_R(ind)),var(im_G(ind)),var(im_B(ind)), ...
%                     var(im_L(ind)),var(im_A(ind)),var(im_B1(ind)), ...
%                     var(im_LBP(ind)),var(Magn(ind)),var(Ori(ind))];
        
 	    sup_feat = [sup_feat;meanall1,varall,meanall2];

        clear ind indxy meanall1 meanall2 varall
    end

     %% 单尺度下的输出的特征值
     sup_feat(isnan(sup_feat))   = 0;
     feadata{ss,1} = sup_feat;
%      feadata = [feadata;sup_feat];
     
     clear sup_feat
end
clear im flow spinfor
clear im_R im_G im_B im_L im_A im_B1 im_LBP Magn Ori

end