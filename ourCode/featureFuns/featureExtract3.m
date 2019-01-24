function result = featureExtract3(tmpMFea,tmpSP,tmpSPLabel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% featureExtract3   GC LC BC
% 特征提取之 high level feature,OR外的区域特征值为 【0 0 0】
% 返回之区域特征仅为OR内之区域特征
% tmpMFea 表示单尺度下中层次特征: spNum * (6*8*3)
% tmpSP   单尺度分割结果
% spinfor{ss,1}.idxcurrImage = idxcurrImage;
% spinfor{ss,1}.adjmat = adjmat;
% spinfor{ss,1}.pixelList =pixelList;
% spinfor{ss,1}.area = area;
% spinfor{ss,1}.spNum = spNum;
% spinfor{ss,1}.bdIds = bdIds;
%
% tmpSPLabel 单尺度下的标签： OR OR_BORDER OBJECT
% 
% result.ObjectLabel = ObjectLabel;% OR内区域样本标签
% result.multiContextFea = multiContextFea; global local border 特征
% result.aidIndex = aidIndex;% OR外区域标号，也是我们要舍弃的
% V1： 2016.07.20
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 首先做精简，构造区域OR操作矩阵： agjmat_OR、 boundary_OR 
idxcurrImage = tmpSP.idxcurrImage;
[height,width,dims]=size(idxcurrImage);clear idxcurrImage
adjmat = tmpSP.adjmat;
pixelList = tmpSP.pixelList;
area = tmpSP.area;
spNum = tmpSP.spNum;
clear tmpSP

boundary = zeros(spNum,spNum);
BIDS = [];ObjectLabel = [];
for sp=1:spNum
    spLabel = tmpSPLabel(sp,:);
    
    if spLabel(1)==0
        tmpMFea(sp,:) = 100;
    else
        ObjectLabel = [ObjectLabel;spLabel(3)];
        % 边界超像素区域位于OR内
         if spLabel(2)==1
             BIDS = [BIDS;sp];% 保存边界超像素编号
         end
    end
end

% 舍弃OR外区域:aidIndex为要舍弃的区域标号
aid = sum(tmpMFea,2);
aidIndex = find(aid==(100*size(tmpMFea,2)));
tmpMFea(aidIndex,:) = [];
adjmat(aidIndex,:) = [];
adjmat(:,aidIndex) = [];

boundary(:,BIDS) = 1;% revised 20160731, 将OR边界区域置一
boundary(aidIndex,:) = [];
boundary(:,aidIndex) = [];

pixelList(aidIndex,:) = [];
area(aidIndex,:) = [];


%% 矩阵化操作，构造 GC LC BC
spNum1 = spNum - length(aidIndex);
multiContextFea = zeros(spNum1,3);
regionCovDistMat = GetDistanceMatrix(tmpMFea);
clear tmpMFea

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

% LAMBDA_J*W_IJ ----------------------------------------------------------------------------------------------
dist_weight_global = area_all_weight.*exp( -posDistMGlobal );% global weight
dist_weight_local = area_adj_weight.*exp( -posDistMLocal);% local weight:相邻接则不为零，否则，为零
dist_weight_boundary = area_boundary_weight.*exp(-posDistMBorder);% boundary weight: 边界位置不为零，非边界位置为零

multiContextFea(:,1) = sum(regionCovDistMat(:,:) .* dist_weight_global, 2) ./ (sum(dist_weight_global, 2) + eps);
multiContextFea(:,2) = sum(regionCovDistMat(:,:) .* dist_weight_local, 2) ./ (sum(dist_weight_local, 2) + eps);
multiContextFea(:,3) = sum(regionCovDistMat(:,:) .* dist_weight_boundary, 2) ./ (sum(dist_weight_boundary, 2) + eps);

%% 
result.ObjectLabel = ObjectLabel;%OR区域超像素标签表征物体还是背景
result.multiContextFea = multiContextFea;% 多对比度特征
result.aidIndex = aidIndex;% OR外区域标号

clear multiContextFea ObjectLabel tmpSPLabel

end

