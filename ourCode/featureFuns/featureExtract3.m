function result = featureExtract3(tmpMFea,tmpSP,tmpSPLabel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% featureExtract3   GC LC BC
% ������ȡ֮ high level feature,OR�����������ֵΪ ��0 0 0��
% ����֮����������ΪOR��֮��������
% tmpMFea ��ʾ���߶����в������: spNum * (6*8*3)
% tmpSP   ���߶ȷָ���
% spinfor{ss,1}.idxcurrImage = idxcurrImage;
% spinfor{ss,1}.adjmat = adjmat;
% spinfor{ss,1}.pixelList =pixelList;
% spinfor{ss,1}.area = area;
% spinfor{ss,1}.spNum = spNum;
% spinfor{ss,1}.bdIds = bdIds;
%
% tmpSPLabel ���߶��µı�ǩ�� OR OR_BORDER OBJECT
% 
% result.ObjectLabel = ObjectLabel;% OR������������ǩ
% result.multiContextFea = multiContextFea; global local border ����
% result.aidIndex = aidIndex;% OR�������ţ�Ҳ������Ҫ������
% V1�� 2016.07.20
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ���������򣬹�������OR�������� agjmat_OR�� boundary_OR 
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
        % �߽糬��������λ��OR��
         if spLabel(2)==1
             BIDS = [BIDS;sp];% ����߽糬���ر��
         end
    end
end

% ����OR������:aidIndexΪҪ������������
aid = sum(tmpMFea,2);
aidIndex = find(aid==(100*size(tmpMFea,2)));
tmpMFea(aidIndex,:) = [];
adjmat(aidIndex,:) = [];
adjmat(:,aidIndex) = [];

boundary(:,BIDS) = 1;% revised 20160731, ��OR�߽�������һ
boundary(aidIndex,:) = [];
boundary(:,aidIndex) = [];

pixelList(aidIndex,:) = [];
area(aidIndex,:) = [];


%% ���󻯲��������� GC LC BC
spNum1 = spNum - length(aidIndex);
multiContextFea = zeros(spNum1,3);
regionCovDistMat = GetDistanceMatrix(tmpMFea);
clear tmpMFea

% ���������ԭ����һ���Ļ����ϻ��ٽ���һ�ι�һ��-----------------------------------------------------------------
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
posDistM = GetDistanceMatrix(meanPos);% ȫ�ֵľ���ռ����
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
dist_weight_local = area_adj_weight.*exp( -posDistMLocal);% local weight:���ڽ���Ϊ�㣬����Ϊ��
dist_weight_boundary = area_boundary_weight.*exp(-posDistMBorder);% boundary weight: �߽�λ�ò�Ϊ�㣬�Ǳ߽�λ��Ϊ��

multiContextFea(:,1) = sum(regionCovDistMat(:,:) .* dist_weight_global, 2) ./ (sum(dist_weight_global, 2) + eps);
multiContextFea(:,2) = sum(regionCovDistMat(:,:) .* dist_weight_local, 2) ./ (sum(dist_weight_local, 2) + eps);
multiContextFea(:,3) = sum(regionCovDistMat(:,:) .* dist_weight_boundary, 2) ./ (sum(dist_weight_boundary, 2) + eps);

%% 
result.ObjectLabel = ObjectLabel;%OR�������ر�ǩ�������廹�Ǳ���
result.multiContextFea = multiContextFea;% ��Աȶ�����
result.aidIndex = aidIndex;% OR��������

clear multiContextFea ObjectLabel tmpSPLabel

end

