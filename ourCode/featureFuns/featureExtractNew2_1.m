function result = featureExtractNew2_1(varargin)
% result = featureExtractNew1(image,spinfor,flow, LEND)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ���򼶵�������Ϣ��������ڹ����ֵ䣩
% image ͼ��
% spinfor ��߶ȷָ���Ϣ
% 
% result.D0  objIndex��Ϊ��ʱ�������ֵ�D0 sampleNum*FeaDims
% D0.P D0.N
% result.selfFea
% result.multiContextFea
% result.ORLabels
%
% V1��2016.08.23 16:33PM
% V2: 2016.10.09 19:29PM
% ����ORLabelѡ��ȷ����ѵ��������object/border�ֱ���Ϊ����������
%
% V3��2016.10.12 8:38AM
% ���챳���ֵ������Ԫ�أ�����������һ��
%
% V4�� 2016.10.24 9:12AM
% ��context����ת��Ϊȫ������
% 
% V5: 2016.11.02 9:33AM
% ����LBP-TOP����������Ϊ��9������
% �� cur_image ����ȡ����
% 
% V6: 2016.11.04 22:46PM
% ȥ��һЩ������ LBP/GEODESIC/MULTI-CONTEXT
% ���� LM_texture & LM_textureHist
%
% V7: 2016.11.05  13:28PM
% ���� multi-context ���������಻��
%
% V8: 2016.11.06  20:47PM
% ��ȥ��LBP�������ϼƹ�10������
%
% V9: 2016.11.12 13:54PM
% ȥ��HOG/GEO/LM_textureture ��������
% 
% V10: 2016.12.02
% ȥ�� multi-contrast����
% 
% V11: 2016.12.02  14��05pm
% ����ȫ�µ����������� ������DRFI��ͬʱȥ��contrast
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cur_image   = varargin{1};% height*width*3 uint8
spinfor     = varargin{2};% ��߶ȷָ���Ϣ
flow        = varargin{3};% ������ height*width*2
param       = varargin{4};% ����������ȷ��ORlabel
% pre_image   = varargin{5};% height*width*3
% next_image  = varargin{6};% height*width*3

if nargin==5
    objIndex = varargin{5};% GT��ǩ���
else
    objIndex = [];
end
cur_image = uint8(cur_image);

%% OR�����ǩ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <L 0; >=H 1; L~H 50
% ��ʱ��LCENDӦ��Ϊԭͼ��ߴ��С
% LCEND = [1,1,width,height];
% ORLabels = computeORLabel(LCEND, objIndex, spinfor, param);
ORLabels = computeORLabel(objIndex, spinfor, param);

%% preparation work %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cur_image = double(cur_image);
grayim_cur = rgb2gray(cur_image);% ����LBP
cur_image = im2double(cur_image);% 2016.12.02 15:38PM������Ϊ unit8  0~1
[height,width,dims] = size(cur_image);
ScaleNums = length(spinfor);

% color transform ------------------
im_R = cur_image(:,:,1);
im_G = cur_image(:,:,2);
im_B = cur_image(:,:,3);

image_lab = rgb2lab( cur_image );
im_L      = image_lab(:,:,1) / 100;
im_A      = image_lab(:,:,2) / 220 + 0.5;
im_B1     = image_lab(:,:,3) / 220 / 0.5;
clear  image_lab

% input_imlab = RGB2Lab(cur_image);
% im_L  = input_imlab(:,:,1);
% im_A  = input_imlab(:,:,2);
% im_B1 = input_imlab(:,:,3);
% clear input_imlab
% 
% im_L = normalizeSal(im_L);% normalize the LAB color feature
% im_A = normalizeSal(im_A);
% im_B1 = normalizeSal(im_B1);

% 1 LBP
% grayim_cur = rgb2gray(cur_image);
[imlbp,~] = LBP_uniform(double(grayim_cur));
im_LBP = double( imlbp );
% im_LBP = normalizeSal(im_LBP);
clear imlbp grayim

% motion --------------------------
curFlow = double(flow);
Magn    = sqrt(curFlow(:,:,1).^2+curFlow(:,:,2).^2);    
Ori     = atan2(-curFlow(:,:,1),curFlow(:,:,2));
% Magn    = normalizeSal(Magn);
% Ori     = normalizeSal(Ori);

%% compute features of sp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfFea = cell(ScaleNums,1);
% multiContextFea = cell(ScaleNums,1);
% regionFea = cell(ScaleNums,1);
for ss=1:ScaleNums
    tmpSP = spinfor{ss,1};
    regionsLocation =  ...
        calculateRegionProps(tmpSP.spNum,tmpSP.idxcurrImage);
    sup_feat = [];
    for sp=1:tmpSP.spNum
%         pixelList = tmpSP.pixelList{sp,1};
	    ind       = regionsLocation{sp}.pixelInd;
	    indxy     = regionsLocation{sp}.pixelIndxy;
        
        %1 �����ֵ
	    meanall1 = [mean(im_R(ind)),mean(im_G(ind)),mean(im_B(ind)), ...
                    mean(im_L(ind)),mean(im_A(ind)),mean(im_B1(ind)), ...
                    mean(im_LBP(ind)),mean(Magn(ind)),mean(Ori(ind))];
        meanall2 = [mean(indxy(:,2))/width,mean(indxy(:,1))/height];
%         color_weight(ind) = computeColorDist([R(ind) G(ind) B1(ind) L(ind) A(ind) B2(ind) XX/col YY/row],repmat(meanall, [length(ind), 1]));

        %2 ���򷽲� 
        varall   = [var(im_R(ind)),var(im_G(ind)),var(im_B(ind)), ...
                    var(im_L(ind)),var(im_A(ind)),var(im_B1(ind)), ...
                    var(im_LBP(ind)),var(Magn(ind)),var(Ori(ind))];
        
 	    sup_feat = [sup_feat;meanall1,varall,meanall2];

        clear ind indxy meanall1 meanall2 varall
    end

     %% ���� selfFea ����: sampleNum*FeaDims (ȫ���µ�������Ϣ)
     sup_feat(isnan(sup_feat))   = 0;
     selfFea{ss,1}.regionFea = sup_feat;
     
     clear sup_feat
end
clear colorHist_rgb colorHist_lab colorHist_hsv lbpHist hogHist regionCov geoDist flowHist
clear im_R im_G im_B im_L im_A im_B1 im_H im_S im_V LM_texture LM_textureHist

%% ������ʼ�ֵ䣨��߶����������У� ǰ���ֵ䡢 �����ֵ䣩D0
% �����ֵ�ʱ��������OR���Χ 2016.10.24 9:22AM
if 1
if nargin==5
    D0.P = struct;D0.N = struct;% sampleNum*feaDim
    DP_regionFea     = []; DN_regionFea     = [];
    
  for ss=1:ScaleNums
        tmpSP = spinfor{ss,1};
        ISOBJECT = ORLabels{ss,1};% 1/0/50/100
        indexP = find(ISOBJECT==1);% ȷ��OR��������Щ�� object 
        indexN = find(ISOBJECT==0);

        DP_regionFea     = [DP_regionFea;     selfFea{ss,1}.regionFea(indexP,:)]; 
        DN_regionFea     = [DN_regionFea;     selfFea{ss,1}.regionFea(indexN,:)];

  end
    D0.P.regionFea      = DP_regionFea;
    D0.N.regionFea      = DN_regionFea;
    
    % SAVE
    result.D0 = D0;
    
    clear D0
end
end
%% save
result.selfFea         = selfFea;% ȫ�ߴ��������������г߶��µ���������
% result.multiContextFea = multiContextFea;
result.ORLabels        = ORLabels;

clear selfFea multiContextFea ORLabels
clear image spinfor flow LCEND param 



end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2 ���������˶���Ϣ &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function [flowHistTable_SP, meanMagnOri_SP] = computeMotionHist(flow,numSP,pixelList,numOfBins)
% ���ȡ���λ��������
curFlow=double(flow);
Magn=sqrt(curFlow(:,:,1).^2+curFlow(:,:,2).^2);    
Ori=atan2(-curFlow(:,:,1),curFlow(:,:,2));
    
flowHistTable=zeros(numSP,3*numOfBins);
%the first col for magnitude,the second for orientation,the last probabilty
meanMagnOri=zeros(numSP,2);
for sp=1:numSP
    bin=0;
    curOri=Ori(pixelList{sp,1});
    curMagn=Magn(pixelList{sp,1});
    % the mean magnitude for each superpixels
    meanMagnOri(sp,1)=mean(curMagn);
    meanMagnOri(sp,2)=median(curOri);
        
    for angle=(-pi+2*pi/numOfBins):2*pi/numOfBins:pi
        bin=bin+1;
        index=curOri<=angle;
        if sum(sum(index))==0
           flowHistTable(sp,bin)=angle;
        else
           flowHistTable(sp,bin)=mean(curOri(index));
        end
           flowHistTable(sp,bin+numOfBins)=sum(curMagn(index));
           flowHistTable(sp,bin+2*numOfBins)=sum(sum(index));      
           curOri(index)=Inf;
    end
    
    %normalize
    temp= flowHistTable(sp,numOfBins+1:2*numOfBins);
    temp=temp./flowHistTable(sp,2*numOfBins+1:3*numOfBins);
    isNaN=isnan(temp);
    temp(isNaN)=0;
    flowHistTable(sp,numOfBins+1:2*numOfBins)=temp;
    flowHistTable(sp,2*numOfBins+1:3*numOfBins)=normalizeFeats(flowHistTable(sp,2*numOfBins+1:3*numOfBins));
        
end

%save the data
% flowHistTable_SP = flowHistTable(:,numOfBins+1:end); 
flowHistTable_SP = flowHistTable(:,2*numOfBins+1:3*numOfBins);% ��ȡ��λ
meanMagnOri_SP   = meanMagnOri;
clear flow numSP pixelList numOfBins flowHistTable meanMagnOri
end

%3 ������ɫֱ��ͼ��rgb/hsv/lab &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function colorHist = computeColorHist(imx,imy,imz,pixelList,numOfBins,ranges)
colorHist = zeros(1,numOfBins*3);
     hist_sample=[];
     hist_sample(1,:)=imx(pixelList);
     hist_sample(2,:)=imy(pixelList);
     hist_sample(3,:)=imz(pixelList);
     colorHist(1,1:numOfBins)              =hist_dong(hist_sample(1,:)',numOfBins,ranges(1,:),0);
     colorHist(1,numOfBins+1:2*numOfBins)  =hist_dong(hist_sample(2,:)',numOfBins,ranges(2,:),0);
     colorHist(1,2*numOfBins+1:3*numOfBins)=hist_dong(hist_sample(3,:)',numOfBins,ranges(3,:),0); 
     colorHist(1,:)=colorHist(1,:)/sum(colorHist(1,:));
end

%4 �����Աȶ���Ϣ�� local border global &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% ĳһ�߶��µĶ�Աȶ�����
% 2016.08.24 15:45PM
% ȫ�������µĶ�context���� 2016.10.24 16:36PM
% ���� boundary connectivity, CVPR2015,  2016.11.24
% function multiContextFea = computeMultiContrast(fea,tmpSP,tmpORlabel)
function multiContextFea = computeMultiContrast(fea,tmpSP)
[height,width,dims] = size(tmpSP.idxcurrImage);
multiContextFea = zeros(tmpSP.spNum,3);
DistMat = GetDistanceMatrix(fea);
clear fea

bdIds = tmpSP.bdIds;
area = tmpSP.area; 
adjmat = tmpSP.adjmat;
boundary = zeros(tmpSP.spNum,tmpSP.spNum);
boundary(:,bdIds) = 1;

pixelList = cell(tmpSP.spNum,1);
for pp=1:tmpSP.spNum
     pixelList{pp,1} =  tmpSP.pixelList{pp,1};
end

[clipVal, geoSigma, neiSigma] = EstimateDynamicParas(tmpSP.adjcMatrix, DistMat);
[bgProb, bdCon, bgWeight] = EstimateBgProb(DistMat, tmpSP.adjcMatrix, bdIds, clipVal, geoSigma);
bgProb = normalizeSal(bgProb);

% ���������ԭ����һ���Ļ����ϻ��ٽ���һ�ι�һ��-----------------------------------------------------------------
% lambda_j 
area = (area)';
area = area/sum(area);

% global context
area_all_weight = repmat(area, [tmpSP.spNum, 1])./repmat(sum(area,2)+eps,[tmpSP.spNum,tmpSP.spNum]);

% local adjcent
area_adj_weight = repmat(area, [tmpSP.spNum, 1]) .* adjmat;
area_adj_weight = area_adj_weight ./ repmat(sum(area_adj_weight, 2) + eps, [1, tmpSP.spNum]);  

% area_boundary_weight = area_all_weight.*boundary;
area_boundary_weight = repmat(area, [tmpSP.spNum, 1]) .* boundary;
area_boundary_weight = area_boundary_weight ./ repmat(sum(area_boundary_weight, 2) + eps, [1, tmpSP.spNum]); 
clear area
%  w_ij (global, local and border)----------------------------------------------------------------------------
meanPos = GetNormedMeanPos(pixelList, height, width);
posDistM = GetDistanceMatrix(meanPos);% ȫ�ֵľ���ռ����
posDistM(posDistM==0) = 1e-10;
[maxDistsGlobal,maxIndexGlobal] = max(posDistM,[],2);
posDistM(posDistM==1e-10) = 0;
posDistMGlobal = posDistM./repmat(maxDistsGlobal,[1,tmpSP.spNum]);

posDistM = GetDistanceMatrix(meanPos);
posDistMLocal = posDistM.*adjmat;
posDistMLocal(posDistMLocal==0)=1e-10;
[maxDistsLocal,maxIndexLocal] = max(posDistMLocal,[],2);
posDistMLocal(posDistMLocal==1e-10) = 0;
posDistMLocal = posDistMLocal./repmat(maxDistsLocal,[1,tmpSP.spNum]);

posDistM = GetDistanceMatrix(meanPos);
posDistMBorder = posDistM.*boundary;
posDistMBorder(posDistMBorder==0)=1e-10;
[maxDistsBorder,maxIndexBorder] = max(posDistMBorder,[],2);
posDistMBorder(posDistMBorder==1e-10) = 0;
posDistMBorder = posDistMBorder./repmat(maxDistsBorder,[1,tmpSP.spNum]);

clear meanPos posDistM

% LAMBDA_J*W_IJ ----------------------------------------------------------------------------------------------
% bgProb  regionNum*1  ���� background probability ��ΪȨ�ؼ�Ȩ��ÿ�����򣡣��� 2016.11.24
bgProbWeight = repmat(bgProb',[size(bgProb,1),1]);
dist_weight_global = area_all_weight.*exp( -posDistMGlobal ).*bgProbWeight;% global weight
dist_weight_local = area_adj_weight.*exp( -posDistMLocal).*bgProbWeight;% local weight:���ڽ���Ϊ�㣬����Ϊ��
dist_weight_boundary = area_boundary_weight.*exp(-posDistMBorder).*bgProbWeight;% boundary weight: �߽�λ�ò�Ϊ�㣬�Ǳ߽�λ��Ϊ��

% dist_weight_global = area_all_weight.*exp( -posDistMGlobal );% global weight
% dist_weight_local = area_adj_weight.*exp( -posDistMLocal);% local weight:���ڽ���Ϊ�㣬����Ϊ��
% dist_weight_boundary = area_boundary_weight.*exp(-posDistMBorder);% boundary weight: �߽�λ�ò�Ϊ�㣬�Ǳ߽�λ��Ϊ��

multiContextFea(:,1) = sum(DistMat(:,:) .* dist_weight_global, 2) ./ (sum(dist_weight_global, 2) + eps);
multiContextFea(:,2) = sum(DistMat(:,:) .* dist_weight_local, 2) ./ (sum(dist_weight_local, 2) + eps);
multiContextFea(:,3) = sum(DistMat(:,:) .* dist_weight_boundary, 2) ./ (sum(dist_weight_boundary, 2) + eps);

clear dist_weight_global dist_weight_local dist_weight_boundary
end
