function result = RegionCov_SuperpixelLevel(frames,frame_names,initialPath)
% 计算 region covariance
% 2016/06/03
% xiaofei zhou
% 
numOfFrame=length(frames);
spnumbers = 100:50:250;% [100 150 200 250]
result = 0;
for frame_it=1:numOfFrame
fprintf('\n %d ',frame_it)
%% compute optical flow and obtain magnitude & orientation
currImage = double(frames{1,frame_it});
[height, width, ch] = size(currImage);

if frame_it>1 && frame_it<numOfFrame
    preImage  = double(frames{1,frame_it-1});
    nextImage = double(frames{1,frame_it+1}); 
end

if frame_it == 1
    preImage  = double(frames{1,numOfFrame});
    nextImage = double(frames{1,frame_it+1}); 
end

if frame_it == numOfFrame
    preImage  = double(frames{1,frame_it-1});
    nextImage = double(frames{1,1}); 
end

curFlow = mex_LDOF( currImage, nextImage);
Magn    = sqrt(curFlow(:,:,1).^2+curFlow(:,:,2).^2);    
Ori     = atan2(-curFlow(:,:,1),curFlow(:,:,2));

%% Extract visual features in pixel-level
I = (currImage(:,:,1)+currImage(:,:,2)+currImage(:,:,3))/3;
CovDists = [-1 0 1];
Iy = imfilter(I,CovDists,'symmetric','same','conv');
Ix = imfilter(I,CovDists','symmetric','same','conv');
Ixx = imfilter(Ix,CovDists','symmetric','same','conv');
Iyy = imfilter(Iy,CovDists,'symmetric','same','conv');
[L, a, b] = RGB2Lab(currImage);
[s2, s1] = meshgrid(1:width,1:height);

F = zeros(height,width,1);
F(:,:,1) = L; F(:,:,2) = a; F(:,:,3) = b;
F(:,:,4) = abs(Ix); F(:,:,5) = abs(Iy);
F(:,:,6) = s1; F(:,:,7) = s2;
F(:,:,8) = abs(Ixx); F(:,:,9) = abs(Iyy);
F(:,:,10) = Magn; F(:,:,11) = Ori;

for i=1:size(F,3)
    F(:,:,i) = F(:,:,i)/max(max(F(:,:,i)));
end

G = reshape(F,[size(F,1)*size(F,2), size(F,3)]);
    
%% SLIC obtain superpixel & multiScales 
%% obtain features with superpixel level
SalGPixelLevel = zeros(height, width, length(spnumbers));
SalLPixelLevel = zeros(height, width, length(spnumbers));
SalBPixelLevel = zeros(height, width, length(spnumbers));
for ss=1:length(spnumbers)
spnumber = spnumbers(ss);
[idxcurrImage, adjcMatrix, pixelList,area] = SLIC_Split(frames{1,frame_it}, spnumber);
spNum = size(adjcMatrix, 1);
adjcMatrix(adjcMatrix==2) = 1;% 除去对角线元素，1 表示邻接
adjmat = double( adjcMatrix ) .* (1 - eye(spNum, spNum));
adjmat = full(adjmat);
% multi-context matrix ----------------------------------------------------
% lambda_j -------------
area = area';
% global context ---------
area_all_weight = repmat(area, [spNum, 1])./repmat(sum(area,2)+eps,[spNum,spNum]);
% local adjcent ----------
% area_adj_weight = area_all_weight.*adjmat;
area_adj_weight = repmat(area, [spNum, 1]) .* adjmat;
area_adj_weight = area_adj_weight ./ repmat(sum(area_adj_weight, 2) + eps, [1, spNum]);  
% border context ----------
bdIds = GetBndPatchIds(idxcurrImage); 
% bdIds = extract_bg_sp(idxcurrImage,height,width);
boundary = zeros(spNum,spNum);
boundary(:,bdIds) = 1;
% area_boundary_weight = area_all_weight.*boundary;
area_boundary_weight = repmat(area, [spNum, 1]) .* boundary;
area_boundary_weight = area_boundary_weight ./ repmat(sum(area_boundary_weight, 2) + eps, [1, spNum]); 
% area_boundary_weight = boundary.*area_all_weight;

%  w_ij (global, local and border) -------------
meanPos = GetNormedMeanPos(pixelList, height, width);
posDistM = GetDistanceMatrix(meanPos);% 全局的距离空间距离
posDistM(posDistM==0) = 100;
[minDistsGlobal,minIndexGlobal] = min(posDistM,[],2);
posDistM(posDistM==100) = 0;
posDistMGlobal = posDistM./repmat(minDistsGlobal,[1,spNum]);

posDistMLocal = posDistM.*adjmat;
posDistMLocal(posDistMLocal==0)=100;
[minDistsLocal,minIndexLocal] = min(posDistMLocal,[],2);
posDistMLocal(posDistMLocal==100) = 0;
posDistMLocal = posDistMLocal./repmat(minDistsLocal,[1,spNum]);

posDistMBorder = posDistM.*boundary;
posDistMBorder(posDistMBorder==0)=100;
[minDistsBorder,minIndexBorder] = min(posDistMBorder,[],2);
posDistMBorder(posDistMBorder==100) = 0;
posDistMBorder = posDistMBorder./repmat(minDistsBorder,[1,spNum]);

% LAMBDA_J*W_IJ -------------
dist_weight_global = area_all_weight.*exp( -posDistMGlobal );% global weight
dist_weight_local = area_adj_weight.*exp( -posDistMLocal);% local weight:相邻接则不为零，否则，为零
dist_weight_boundary = area_boundary_weight.*exp(-posDistMBorder);% boundary weight: 边界位置不为零，非边界位置为零

% 计算区域级的 multicontext 特征表示----------------------------------------
%region covariance 的 sigmapoints 表示
% currImgsigmapoints = zeros(spNum,1);
currImgsigmapoints = [];
for sp=1:spNum
    Ind = find(idxcurrImage==sp); 
     
    if isnan(cov(G(Ind,:)))
        cov1 = 0.001*eye(size(F,3));
    else
        cov1 = cov(G(Ind,:)) + 0.001*eye(size(F,3)); % Add very small values to diagonal entries
    end                                              % in order to cope with homogeneous regions
    
    m = mean(G(Ind,:));
    covC = cov1;
    covC = 2.0*(size(covC,1)+0.1)*covC;
    L = chol(covC);
    
    li = L(:);
    for k=1:size(F,3)*size(F,3)
        li(k) = li(k)+m(mod(k-1,size(F,3))+1);
    end
    lj = L(:);
    for k=1:size(F,3)*size(F,3)
        lj(k) = m(mod(k-1,size(F,3))+1)-lj(k);
    end
    resRef = [m li' lj'];
%     currImgsigmapoints(sp,:) = resRef; 
    currImgsigmapoints = [currImgsigmapoints;resRef];
    clear resRef m L
    
end

% construct multicontext features [global, local, border, self]
regionFea = zeros(spNum,3+size(currImgsigmapoints,2));
regionCovDistMat = GetDistanceMatrix(currImgsigmapoints);% spNum*spNum
regionFea(:,1) = sum(regionCovDistMat(:,:) .* dist_weight_global, 2) ./ (sum(dist_weight_global, 2) + eps);
regionFea(:,2) = sum(regionCovDistMat(:,:) .* dist_weight_local, 2) ./ (sum(dist_weight_local, 2) + eps);
regionFea(:,3) = sum(regionCovDistMat(:,:) .* dist_weight_boundary, 2) ./ (sum(dist_weight_boundary, 2) + eps);
regionFea(:,4:end) = currImgsigmapoints(:,:);

% creat initial spatio-temporal saliency map
SalGlobal = regionFea(:,1);
SalLocal  = regionFea(:,2);
SalBorder = regionFea(:,3);

SalGlobal = normalize_sal(SalGlobal);
SalLocal  = normalize_sal(SalLocal);
SalBorder = normalize_sal(SalBorder);

SGPsingle = spSaliency2Pixels( SalGlobal, idxcurrImage ,0);
SLPsingle = spSaliency2Pixels( SalLocal, idxcurrImage, 0 );
SBPsingle = spSaliency2Pixels( SalBorder, idxcurrImage,0);

SalGPixelLevel(:, :, ss) = SGPsingle;
SalLPixelLevel(:, :, ss) = SLPsingle;
SalBPixelLevel(:, :, ss) = SBPsingle;

% clear some variables
clear idxcurrImage adjcMatrix pixelList area currImage
clear SalGlobal SalLocal SalBorder
clear SGPsingle SLPsingle SBPsingle
end

%--------------------------------------------------------------------------
% fusion method1/2
f1=0;f2=0;
for fs=1:length(spnumbers)
    salsingle1 = SalGPixelLevel(:,:,fs) + SalLPixelLevel(:,:,fs) + SalBPixelLevel(:,:,fs);
    salsingle2 = SalGPixelLevel(:,:,fs) .* SalLPixelLevel(:,:,fs) .* SalBPixelLevel(:,:,fs);
    salsingle1 = normalize_sal(salsingle1);
    salsingle2 = normalize_sal(salsingle2);
    f1 = f1 + salsingle1;
    f2 = f2 + salsingle2;
    clear salsingle1 salsingle2
end
f1 = uint8(255 * normalize_sal(f1));
f2 = uint8(255 * normalize_sal(f2));

% fusion method3/4
% multi-level saliency fusion
SalGPixelLevel1 = sum(SalGPixelLevel, 3);
SalLPixelLevel1 = sum(SalLPixelLevel, 3);
SalBPixelLevel1 = sum(SalBPixelLevel, 3);

SalGPixelLevel1 = normalize_sal(SalGPixelLevel1);
SalLPixelLevel1  = normalize_sal(SalLPixelLevel1);
SalBPixelLevel1 = normalize_sal(SalBPixelLevel1);

f3 = uint8(255 * normalize_sal(SalGPixelLevel1 + SalLPixelLevel1 + SalBPixelLevel1));
f4 = uint8(255 * normalize_sal(SalGPixelLevel1 .* SalLPixelLevel1 .* SalBPixelLevel1));

% save results ------------------------------------------------------------
imname = frame_names{1,frame_it}(1:end-4);
% Sal_initial
SG = uint8(255 * SalGPixelLevel1);
SL = uint8(255 * SalLPixelLevel1);
SB = uint8(255 * SalBPixelLevel1);
imwrite(SG, [initialPath,imname,'_SG.png'])
imwrite(SL, [initialPath,imname,'_SL.png'])
imwrite(SB, [initialPath,imname,'_SB.png'])

imwrite(f1, [initialPath,imname,'_f1.png'])
imwrite(f2, [initialPath,imname,'_f2.png'])
imwrite(f3, [initialPath,imname,'_f3.png'])
imwrite(f4, [initialPath,imname,'_f4.png'])

clear imname
end






end