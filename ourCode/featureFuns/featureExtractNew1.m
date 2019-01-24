function result = featureExtractNew1(varargin)
% result = featureExtractNew1(image,spinfor,flow, LEND)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 提取区域级的自身信息及方差（用于构成字典）
% image 图像
% spinfor 多尺度分割信息
% 
% result.D0  objIndex不为空时方存在字典D0 sampleNum*FeaDims
% D0.P D0.N
% result.selfFea
% result.multiContextFea
% result.ORLabels
%
% V1：2016.08.23 16:33PM
% V2: 2016.10.09 19:29PM
% 根据ORLabel选择确定性训练样本（object/border分别作为正负样本）
% V3：2016.10.12 8:38AM
% 构造背景字典所需的元素，尽量包含多一点
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image   = varargin{1};% height*width*3
spinfor = varargin{2};% 多尺度分割信息
flow    = varargin{3};% 光流场 height*width*2
LCEND   = varargin{4};% [x1,y1,x2,y2]
param   = varargin{5};% 参数，用于确定ORlabel

if nargin==6
    objIndex = varargin{6};% GT标签序号
else
    objIndex = [];
end

image = double(image);
[height,width,dims] = size(image);
ScaleNums = length(spinfor);
NUM_COLORS = 48;
numOfBins = NUM_COLORS/3;
range_rgb = [0,255;0,255;0,255];
range_lab = [0,100;-127,128;-127,128]; 
range_hsv = [0,360;0,1;0,1];

%% OR区域标签 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <L 0; >=H 1; L~H 50
ORLabels = computeORLabel(LCEND, objIndex, spinfor, param);

%% preparation work %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% color transform ------------------
im_R = image(:,:,1);
im_G = image(:,:,2);
im_B = image(:,:,3);

[im_L, im_A, im_B1] = ...
    rgb2lab_dong(double(im_R(:)),double(im_G(:)),double(im_B(:)));
im_L=reshape(im_L,size(im_R));
im_A=reshape(im_A,size(im_R));
im_B1=reshape(im_B1,size(im_R));
        
imgHSV=colorspace('HSV<-',uint8(image));      
im_H=imgHSV(:,:,1);
im_S=imgHSV(:,:,2);
im_V=imgHSV(:,:,3);

% texture computation --------------
% 1 LBP
grayim = rgb2gray( uint8(image) );
[imlbp,~] = LBP_uniform(double(grayim));
im_LBP = double( imlbp );
clear imlbp grayim

% 2 covariance
I = (im_R+im_G+im_B)/3;
CovDists = [-1 0 1];
Iy = imfilter(I,CovDists,'symmetric','same','conv');
Ix = imfilter(I,CovDists','symmetric','same','conv');
Ixx = imfilter(Ix,CovDists','symmetric','same','conv');
Iyy = imfilter(Iy,CovDists,'symmetric','same','conv');
[s2, s1] = meshgrid(1:width,1:height);
F = zeros(height,width,1);
F(:,:,1) = im_L;F(:,:,2) = im_A;F(:,:,3) = im_B1;
F(:,:,4) = abs(Ix);F(:,:,5) = abs(Iy);
F(:,:,6) = s1;F(:,:,7) = s2;
F(:,:,8) = abs(Ixx);F(:,:,9) = abs(Iyy);
for i=1:size(F,3)
    F(:,:,i) = F(:,:,i)/max(max(F(:,:,i)));
end
im_COV = reshape(F,[size(F,1)*size(F,2), size(F,3)]);
clear F I Iy Ix Ixx Iyy  

% % motion --------------------------
% Magn=sqrt(flow(:,:,1).^2+flow(:,:,2).^2);    
% Ori=atan2(-flow(:,:,1),flow(:,:,2));


%% compute features of sp %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
selfFea = cell(ScaleNums,1);
multiContextFea = cell(ScaleNums,1);
for ss=1:ScaleNums
    tmpSP = spinfor{ss,1};
    
    % color
    colorHist_rgb = zeros(tmpSP.spNum,3*numOfBins);
    colorHist_lab = zeros(tmpSP.spNum,3*numOfBins);
    colorHist_hsv = zeros(tmpSP.spNum,3*numOfBins);
    
    % texture
    lbpHist = zeros(tmpSP.spNum,59);
    hogHist = zeros(tmpSP.spNum,4*36);
    
    regionCov = COVSIGMA(im_COV,tmpSP.idxcurrImage,tmpSP.spNum);
    
    rect_width = round(sqrt(height*width/tmpSP.spNum)*2/3);% HOG操作区域大小
    
    % motion
    [flowHist, ~] = computeMotionHist(flow,tmpSP.spNum,tmpSP.pixelList,8);% spNum*16
    
    for sp=1:tmpSP.spNum
     pixelList = tmpSP.pixelList{sp,1};
    %% color --------------------- 
     colorHist_rgb(sp,:) = computeColorHist(im_R,im_G,im_B,pixelList,numOfBins,range_rgb);     
     colorHist_lab(sp,:) = computeColorHist(im_L,im_A,im_B1,pixelList,numOfBins,range_lab);   
     colorHist_hsv(sp,:) = computeColorHist(im_H,im_S,im_V,pixelList,numOfBins,range_hsv);   
     
    %% texture ------------------
    % LBP
    lbpHist(sp,:) = hist_dong(im_LBP(pixelList),59,[0,58],0);% hist( imlbp(pixels), 0:255 )'
    lbpHist(sp,:) = lbpHist(sp,:) / max( sum(lbpHist(sp,:)), eps );

    % HOG
    [ys,xs] = ind2sub([height,width],pixelList);
    miny=min(ys);maxy=max(ys);
    minx=min(xs);maxx=max(xs);
    hh = maxy-miny+1;ww=maxx-minx+1;
    yc = miny + round(hh/2);
    xc = minx + round(ww/2);
    rect_width = min(hh,ww);
    hh1 = (yc-round(rect_width/2)):(yc+round(rect_width/2)-1);
    ww1 = (xc-round(rect_width/2)):(xc+round(rect_width/2)-1);
    if (yc-round(rect_width/2))<1
        hh1=1:(yc+round(rect_width/2));
    end
    if (yc+round(rect_width/2))>height
        hh1 = (yc-round(rect_width/2)):height;
    end    
    if (xc-round(rect_width/2))<1
        ww1=1:(xc+round(rect_width/2));
    end
    if (xc+round(rect_width/2))>width
        ww1 = (xc-round(rect_width/2)):width;
    end   
    subimg = image(hh1,ww1,:);
    
    if rect_width<6 % 确保最小的cell的尺寸为 3*3 2016.09.01 18:55PM
        rect_width = 6;
    end
    subimg = imresize(subimg,[rect_width,rect_width]);
    % 确保2*2的构造 revised in 2016.08.30 20:45PM
    cellsize_hog = round(rect_width/2);
    tmphog = vl_hog(single(subimg), cellsize_hog, 'Variant', 'DalalTriggs', 'NumOrientations', 9);
    hogHist(sp,:) = tmphog(:); % 1*(2*2*36)
%     disp([ss,sp])
    clear x y hh ww subimg tmphog
    
    end
    %% GD -----------------------
     % 于OR区域中处理
     tmpORlabel = ORLabels{ss,1};% spNum*3
     ISORlabel = tmpORlabel(:,1);
     ISBorderlabel = tmpORlabel(:,2);
     [index0,~] = find(ISORlabel==0);% OR外区域
     [index01,~] = find(ISORlabel==1);% OR内区域标号
     index1 = [];% border 于 OR 中的序号
     for dd=1:length(index01)% 寻找border,并重新构造区域编号
         tmpID = index01(dd);
         if ISBorderlabel(tmpID)==1
             index1 = [index1;dd];
         end
     end
     adjcMatrix = tmpSP.adjcMatrix; % 测地距离专供， 邻接1/2， 不邻接0， 对角线为1
     adjcMatrix(index0,:) = [];
     adjcMatrix(:,index0) = [];
     
     bdIds = index1; % NOTE: 不是 tmpSP.bdIds
     clear index1
     
     colDistM = tmpSP.colDistM;
     colDistM(index0,:) = [];
     colDistM(:,index0) = [];
     
     posDistM = tmpSP.posDistM;
     posDistM(index0,:) = [];
     posDistM(:,index0) = [];
     
     [clipVal, ~, ~] = EstimateDynamicParas(adjcMatrix, colDistM);
     geoDist = GeodesicSaliency(adjcMatrix, bdIds, colDistM, posDistM, clipVal);% length(index01)*1
     geoDist = normalizeSal(geoDist);% 1*sampleNum_OR
     clear  adjcMatrix colDistM posDistM clipVal
%      clear tmpORlabel ISORlabel ISBorderlabel index0 index01

     %% 构建 MultiContrast 特征(OR区域)
     colorHist_rgb_contrast = computeMultiContrast(colorHist_rgb,tmpSP,tmpORlabel);
     colorHist_rgb_contrast(isnan(colorHist_rgb_contrast)) = 0;
     multiContextFea{ss,1}.colorHist_rgb = colorHist_rgb_contrast;
     
     colorHist_lab_contrast = computeMultiContrast(colorHist_lab,tmpSP,tmpORlabel);
     colorHist_lab_contrast(isnan(colorHist_lab_contrast)) = 0;
     multiContextFea{ss,1}.colorHist_lab = colorHist_lab_contrast;
     
     colorHist_hsv_contrast = computeMultiContrast(colorHist_hsv,tmpSP,tmpORlabel);
     colorHist_hsv_contrast(isnan(colorHist_hsv_contrast)) = 0;
     multiContextFea{ss,1}.colorHist_hsv = colorHist_hsv_contrast;
     
     lbpHist_contrast = computeMultiContrast(lbpHist,tmpSP,tmpORlabel);
     lbpHist_contrast(isnan(lbpHist_contrast)) = 0;
     multiContextFea{ss,1}.lbpHist       = lbpHist_contrast;
     
     hogHist_contrast = computeMultiContrast(hogHist,tmpSP,tmpORlabel);
     hogHist_contrast(isnan(hogHist_contrast)) = 0;
     multiContextFea{ss,1}.hogHist       = hogHist_contrast;
     
     regionCov_contrast = computeMultiContrast(regionCov,tmpSP,tmpORlabel);
     regionCov_contrast(isnan(regionCov_contrast)) = 0;
     multiContextFea{ss,1}.regionCov     = regionCov_contrast;
     
     geoDist_contrast = computeMultiContrast(geoDist',tmpSP,tmpORlabel);
     geoDist_contrast(isnan(geoDist_contrast))  = 0;
     multiContextFea{ss,1}.geoDist = geoDist_contrast;
     
     flowHist_contrast = computeMultiContrast(flowHist,tmpSP,tmpORlabel);
     flowHist_contrast(isnan(flowHist_contrast)) = 0;
     multiContextFea{ss,1}.flowHist      = flowHist_contrast;
     
     clear colorHist_rgb_contrast colorHist_lab_contrast colorHist_hsv_contrast 
     clear hogHist_contrast lbpHist_contrast regionCov_contrast geoDist_contrast flowHist_contrast
     %% 构建 selfFea 特征: sampleNum*FeaDims (OR区域)
     colorHist_rgb(isnan(colorHist_rgb)) = 0;
     colorHist_lab(isnan(colorHist_lab)) = 0;
     colorHist_hsv(isnan(colorHist_hsv)) = 0;
     lbpHist(isnan(lbpHist))             = 0;
     hogHist(isnan(hogHist))             = 0;
     regionCov(isnan(regionCov))         = 0;
     geoDist(isnan(geoDist))             = 0;
     flowHist(isnan(flowHist))           = 0;
     selfFea{ss,1}.colorHist_rgb = colorHist_rgb(index01,:);
     selfFea{ss,1}.colorHist_lab = colorHist_lab(index01,:);
     selfFea{ss,1}.colorHist_hsv = colorHist_hsv(index01,:);  
     selfFea{ss,1}.lbpHist       = lbpHist(index01,:);
     selfFea{ss,1}.hogHist       = hogHist(index01,:);
     selfFea{ss,1}.regionCov     = regionCov(index01,:);   
     selfFea{ss,1}.geoDist       = geoDist';% revised in 2016.08.28 16:43PM geoDist 1* sampleNunm(OR)
     selfFea{ss,1}.flowHist      = flowHist(index01,:);
     
end
clear colorHist_rgb colorHist_lab colorHist_hsv lbpHist hogHist regionCov geoDist flowHist
clear im_R im_G im_B im_L im_A im_B1 im_H im_S im_V

%% 构建初始字典（多尺度下样本集中： 前景字典、 背景字典）D0
if 1
if nargin==6
    D0.P = struct;D0.N = struct;% sampleNum*feaDim
    DP_colorHist_rgb = []; DN_colorHist_rgb = [];
    DP_colorHist_lab = []; DN_colorHist_lab = [];
    DP_colorHist_hsv = []; DN_colorHist_hsv = [];
    DP_lbpHist       = []; DN_lbpHist       = [];
    DP_hogHist       = []; DN_hogHist       = [];
    DP_regionCov     = []; DN_regionCov     = [];
    DP_geoDist       = []; DN_geoDist       = [];
    DP_flowHist      = []; DN_flowHist      = [];
    
    for ss=1:ScaleNums
        tmpSP = spinfor{ss,1};
        tmpORlabel = ORLabels{ss,1};% spNum*3
        ISORlabel = tmpORlabel(:,1);
        index_out_OR = find(ISORlabel~=1);
        ISOBJlabel = tmpORlabel(:,3);
        Plabel = ISORlabel.*ISOBJlabel;% (1,1) P 
        Plabel(index_out_OR,:) = [];% 去除OR外部区域
        indexP = find(Plabel==1);% 确定OR区域中哪些是 object 

        if 0
        % revised in 2016.10.09  19:29PM
        % 选择确定性的训练样本（负样本采用border）
        ISBORDERlabel = tmpORlabel(:,2);
        ISOBJlabel(ISOBJlabel==1) = 6;% 置反ISOBJlabel，用于确定indexN
        ISOBJlabel(ISOBJlabel==0) = 1;
        ISOBJlabel(ISOBJlabel==6) = 0;  
        Nlabel = ISORlabel .* ISOBJlabel .* ISBORDERlabel; % 1 1 1 ---> border 即 OR=1， OBJ=0， BORDER=1
        Nlabel(index_out_OR,:) = [];
        indexN = find(Nlabel==1);
        end
        
        % revised in 2016.10.12 9:46AM 构建背景字典元素 OR=1 OBJECT=0
        if 1 % 在OR中且OBJ=0，为确定性背景
        [index_in_OR,~] = find(ISORlabel==1);% OR区域标号
        indexN = [];% OR中背景区域编号
        for dd=1:length(index_in_OR)
            tmpID = index_in_OR(dd);
            if ISOBJlabel(tmpID)==0
               indexN = [indexN;dd];
            end
        end
        
        end
        
        % 于OR中取正负样本
        DP_colorHist_rgb = [DP_colorHist_rgb;selfFea{ss,1}.colorHist_rgb(indexP,:),multiContextFea{ss,1}.colorHist_rgb(indexP,:)];
        DP_colorHist_lab = [DP_colorHist_lab;selfFea{ss,1}.colorHist_lab(indexP,:),multiContextFea{ss,1}.colorHist_lab(indexP,:)];
        DP_colorHist_hsv = [DP_colorHist_hsv;selfFea{ss,1}.colorHist_hsv(indexP,:),multiContextFea{ss,1}.colorHist_hsv(indexP,:)];  
        DP_lbpHist       = [DP_lbpHist;      selfFea{ss,1}.lbpHist(indexP,:),      multiContextFea{ss,1}.lbpHist(indexP,:)];
        DP_hogHist       = [DP_hogHist;      selfFea{ss,1}.hogHist(indexP,:),      multiContextFea{ss,1}.hogHist(indexP,:)];
        DP_regionCov     = [DP_regionCov;    selfFea{ss,1}.regionCov(indexP,:),    multiContextFea{ss,1}.regionCov(indexP,:)];
        DP_geoDist       = [DP_geoDist;      selfFea{ss,1}.geoDist(indexP,:),      multiContextFea{ss,1}.geoDist(indexP,:)];
        DP_flowHist      = [DP_flowHist;     selfFea{ss,1}.flowHist(indexP,:),     multiContextFea{ss,1}.flowHist(indexP,:)];
        
        DN_colorHist_rgb = [DN_colorHist_rgb;selfFea{ss,1}.colorHist_rgb(indexN,:),multiContextFea{ss,1}.colorHist_rgb(indexN,:)];
        DN_colorHist_lab = [DN_colorHist_lab;selfFea{ss,1}.colorHist_lab(indexN,:),multiContextFea{ss,1}.colorHist_lab(indexN,:)];
        DN_colorHist_hsv = [DN_colorHist_hsv;selfFea{ss,1}.colorHist_hsv(indexN,:),multiContextFea{ss,1}.colorHist_hsv(indexN,:)];  
        DN_lbpHist       = [DN_lbpHist;      selfFea{ss,1}.lbpHist(indexN,:),      multiContextFea{ss,1}.lbpHist(indexN,:)];
        DN_hogHist       = [DN_hogHist;      selfFea{ss,1}.hogHist(indexN,:),      multiContextFea{ss,1}.hogHist(indexN,:)];
        DN_regionCov     = [DN_regionCov;    selfFea{ss,1}.regionCov(indexN,:),    multiContextFea{ss,1}.regionCov(indexN,:)];
        DN_geoDist       = [DN_geoDist;      selfFea{ss,1}.geoDist(indexN,:),      multiContextFea{ss,1}.geoDist(indexN,:)];
        DN_flowHist      = [DN_flowHist;     selfFea{ss,1}.flowHist(indexN,:),     multiContextFea{ss,1}.flowHist(indexN,:)];    
        
    end
    D0.P.colorHist_rgb = DP_colorHist_rgb; 
    D0.P.colorHist_lab = DP_colorHist_lab; 
    D0.P.colorHist_hsv = DP_colorHist_hsv; 
    D0.P.lbpHist       = DP_lbpHist;
    D0.P.hogHist       = DP_hogHist;
    D0.P.regionCov     = DP_regionCov;
    D0.P.geoDist       = DP_geoDist;
    D0.P.flowHist      = DP_flowHist;
    
    D0.N.colorHist_rgb = DN_colorHist_rgb; 
    D0.N.colorHist_lab = DN_colorHist_lab; 
    D0.N.colorHist_hsv = DN_colorHist_hsv; 
    D0.N.lbpHist       = DN_lbpHist;
    D0.N.hogHist       = DN_hogHist;
    D0.N.regionCov     = DN_regionCov;
    D0.N.geoDist       = DN_geoDist;
    D0.N.flowHist      = DN_flowHist;
    
    % SAVE
    result.D0 = D0;
    
    clear D0
end
end
%% save
result.selfFea         = selfFea;
result.multiContextFea = multiContextFea;
result.ORLabels        = ORLabels;

clear selfFea multiContextFea ORLabels
clear image spinfor flow LCEND param 



end

% %1 计算OR区域标签： OR内外，边界，前背景 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% function ORLabels = computeORLabel(LCEND, objIndex, spinfor,param)
% % lend = [x1,y1,x2,y2];
% % objectIndex GT标签
% % 
% ORTHS = param.ORTHS;
% OR_th = ORTHS(1);
% OR_BORDER_th = ORTHS(2);
% OR_OB_th = ORTHS(3);% default 0.8
% 
% SPSCALENUM = length(spinfor);
% ORLabels = cell(SPSCALENUM,1);
% 
% [height,width,dims] = size(spinfor{1,1}.idxcurrImage);
% ORI = zeros(height,width);
% ORI(LCEND(2):LCEND(4),LCEND(1):LCEND(3))=1;
% ORIndex = find(ORI(:)==1);
% 
% for ss=1:SPSCALENUM % 每个尺度下
%     tmpSP = spinfor{ss,1};
%     
%     LABEL = [];ISOR=[];ISOBJ=[];ISBORDER = [];
%     for sp=1:tmpSP.spNum % 各区域
%         TMP = find(tmpSP.idxcurrImage==sp);
%         
%         
%         % 1. 首先判断是否在OR区域内 1/0
%         indSP_OR = ismember(TMP, ORIndex);
%         ratio_OR = sum(indSP_OR)/length(indSP_OR);% accuracy score
%         
%         % revised in 2016.08.29 8:07AM ------------------------------------
%         if ratio_OR==0
%             ISOR = [ISOR;0];
%             ISBORDER = [ISBORDER;0];
%         else
%             ISOR = [ISOR;1];% 属于OR区域
%             
%             if ratio_OR>0 && ratio_OR<1
%                 ISBORDER = [ISBORDER;1];% 边界超像素区域
%             end
%             
%             if ratio_OR==1
%                 ISBORDER = [ISBORDER;0];
%             end
%         end
%         % -----------------------------------------------------------------
% %         if  ratio_OR< OR_th % 位于OR外部
% %             ISOR = [ISOR;0];
% %             ISBORDER = [ISBORDER;0];
% %         else
% %             ISOR = [ISOR;1];
% %             % 2. 判定OR区域边界超像素 <1 OR边界超像素
% %             if ratio_OR<OR_BORDER_th
% %                 ISBORDER = [ISBORDER;1];% 边界超像素区域
% %             else
% %                 ISBORDER = [ISBORDER;0];
% %             end        
% %         end
%         
%         %3. 再判断是否在Object中 1/0
%         if isempty(objIndex)
%         ISOBJ = [ISOBJ;100];  
%         else
%         indSP_GT = ismember(TMP,objIndex);
%         ratio_GT = sum(indSP_GT)/length(indSP_GT);% accuracy score
%         
%         if  ratio_GT < OR_OB_th
%             ISOBJ = [ISOBJ;0];% NEGTIVE
%         else
%             ISOBJ = [ISOBJ;1]; % POSITIVE
%         end;            
%         end
% 
%         
%     end
%     LABEL = [ISOR,ISBORDER,ISOBJ];
%     ORLabels{ss,1} = LABEL;
%     clear tmpSP
% end
% 
% clear LCEND objIndex spinfor param
% 
% end

%2 计算区域运动信息 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function [flowHistTable_SP, meanMagnOri_SP] = computeMotionHist(flow,numSP,pixelList,numOfBins)
% 幅度、相位均用上了
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
flowHistTable_SP = flowHistTable(:,numOfBins+1:end);    
meanMagnOri_SP   = meanMagnOri;
clear flow numSP pixelList numOfBins flowHistTable meanMagnOri
end

%3 计算颜色直方图：rgb/hsv/lab &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
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

%4 计算多对比度信息： local border global &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
function multiContextFea = computeMultiContrast(fea,tmpSP,tmpORlabel)
% 某一尺度下的多对比度特征
% 2016.08.24 15:45PM
% 
[height,width,dims] = size(tmpSP.idxcurrImage);
ISORlabel = tmpORlabel(:,1);
ISBorderlabel = tmpORlabel(:,2);
[index0,~] = find(ISORlabel==0);
[index01,~] = find(ISORlabel==1);% OR区域标号
bdIds = [];% border 于 OR 中的序号
for dd=1:length(index01)
    tmpID = index01(dd);
    if ISBorderlabel(tmpID)==1
       bdIds = [bdIds;dd];
    end
end
     
spNum1 = length(index01);
multiContextFea = zeros(spNum1,3);
DistMat = GetDistanceMatrix(fea);


% 于整幅图像提取的特征需要去除OR外的区域样本
if size(fea,1)==tmpSP.spNum
DistMat(index0,:) =[];
DistMat(:,index0) =[];
end
clear fea
area = tmpSP.area; area(index0) = [];% area(:,index0) = [];
adjmat = tmpSP.adjmat;adjmat(index0,:) = [];adjmat(:,index0) = [];

boundary = zeros(spNum1,spNum1);
boundary(:,bdIds) = 1;

% pixelList= tmpSP.pixelList;% spNum*1
% pixelList{index0,1} = [];
pixelList = cell(spNum1,1);
for pp=1:spNum1
    pixelList{pp,1} =  tmpSP.pixelList{index01(pp),1};
end

% 面积因子在原来归一化的基础上会再进行一次归一化-----------------------------------------------------------------
% lambda_j 
area = (area)';
area = area/sum(area);
% global context
area_all_weight = repmat(area, [spNum1, 1])./repmat(sum(area,2)+eps,[spNum1,spNum1]);
% local adjcent
area_adj_weight = repmat(area, [spNum1, 1]) .* adjmat;
area_adj_weight = area_adj_weight ./ repmat(sum(area_adj_weight, 2) + eps, [1, spNum1]);  

% area_boundary_weight = area_all_weight.*boundary;
area_boundary_weight = repmat(area, [spNum1, 1]) .* boundary;
area_boundary_weight = area_boundary_weight ./ repmat(sum(area_boundary_weight, 2) + eps, [1, spNum1]); 
clear area
%  w_ij (global, local and border)----------------------------------------------------------------------------
meanPos = GetNormedMeanPos(pixelList, height, width);
posDistM = GetDistanceMatrix(meanPos);% 全局的距离空间距离
posDistM(posDistM==0) = 1e-10;
[maxDistsGlobal,maxIndexGlobal] = max(posDistM,[],2);
posDistM(posDistM==1e-10) = 0;
posDistMGlobal = posDistM./repmat(maxDistsGlobal,[1,spNum1]);

posDistM = GetDistanceMatrix(meanPos);
posDistMLocal = posDistM.*adjmat;
posDistMLocal(posDistMLocal==0)=1e-10;
[maxDistsLocal,maxIndexLocal] = max(posDistMLocal,[],2);
posDistMLocal(posDistMLocal==1e-10) = 0;
posDistMLocal = posDistMLocal./repmat(maxDistsLocal,[1,spNum1]);

posDistM = GetDistanceMatrix(meanPos);
posDistMBorder = posDistM.*boundary;
posDistMBorder(posDistMBorder==0)=1e-10;
[maxDistsBorder,maxIndexBorder] = max(posDistMBorder,[],2);
posDistMBorder(posDistMBorder==1e-10) = 0;
posDistMBorder = posDistMBorder./repmat(maxDistsBorder,[1,spNum1]);

clear meanPos posDistM

% LAMBDA_J*W_IJ ----------------------------------------------------------------------------------------------
dist_weight_global = area_all_weight.*exp( -posDistMGlobal );% global weight
dist_weight_local = area_adj_weight.*exp( -posDistMLocal);% local weight:相邻接则不为零，否则，为零
dist_weight_boundary = area_boundary_weight.*exp(-posDistMBorder);% boundary weight: 边界位置不为零，非边界位置为零

multiContextFea(:,1) = sum(DistMat(:,:) .* dist_weight_global, 2) ./ (sum(dist_weight_global, 2) + eps);
multiContextFea(:,2) = sum(DistMat(:,:) .* dist_weight_local, 2) ./ (sum(dist_weight_local, 2) + eps);
multiContextFea(:,3) = sum(DistMat(:,:) .* dist_weight_boundary, 2) ./ (sum(dist_weight_boundary, 2) + eps);

clear dist_weight_global dist_weight_local dist_weight_boundary
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     colorCov_rgb  = zeros(tmpSP.spNum,3);
%     colorCov_lab  = zeros(tmpSP.spNum,3);
%     colorCov_hsv  = zeros(tmpSP.spNum,3);

%      % regional covariance
%      colorCov_rgb(sp,:) = [var(im_R(pixelList)),var(im_G(pixelList)),var(im_B(pixelList))];
%      colorCov_lab(sp,:) = [var(im_L(pixelList)),var(im_A(pixelList)),var(im_B1(pixelList))];
%      colorCov_hsv(sp,:) = [var(im_H(pixelList)),var(im_S(pixelList)),var(im_V(pixelList))];


%     lbpCov = zeros(tmpSP.spNum,1);
%     lbpCov(sp,1) = var( im_LBP(pixelList) );

%     [x,y] = tmpSP.region_center(sp,:);
%     x = round(x);y=round(y);
%     hh = (y-round(rect_width/2)):(y+round(rect_width/2));
%     ww = (x-round(rect_width/2)):(x+round(rect_width/2));
%     if (y-round(rect_width/2))<1
%         hh=0:(y+round(rect_width/2));
%     end
%     if (y+round(rect_width/2))>height
%         hh = (y-round(rect_width/2)):height;
%     end    
%     if (x-round(rect_width/2))<1
%         ww=0:(x+round(rect_width/2));
%     end
%     if (x+round(rect_width/2))>width
%         ww = (x-round(rect_width/2)):width;
%     end   
%     subimg = image(hh,ww,:);

