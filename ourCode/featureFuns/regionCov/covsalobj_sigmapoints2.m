function [segments regionCenters Segments] = covsalobj_sigmapoints2(imfile, stepsize, ratio, show_results)
% Inputs:   imfile      - filename of the input image
%           stepsize    - stepsize for superpixels
%           ratio       - ratio of the number of surrounding superpixels in the saliency estimation
% Output:   salmapCob   - estimated saliency map
%
% Sample run: [salmapCov salmapCol salmapSig] = covsalobj('Image_60.bmp',0.1,1/3,1);
addpath(genpath('/data/aysun/ForMATLAB/code/3rdparty'));
switch nargin
    case 1
        stepsize = 0.1;
        ratio = 1/3;
        show_results = 1;
    case 2
        ratio = 1/3;
        show_results = 0;
    case 3
        show_results = 0;
end

% Read input image
Img = double(imread(imfile));
[height, width, ch] = size(Img);

% Extract visual features
I = (Img(:,:,1)+Img(:,:,2)+Img(:,:,3))/3;
CovDists = [-1 0 1];
Iy = imfilter(I,CovDists,'symmetric','same','conv');
Ix = imfilter(I,CovDists','symmetric','same','conv');
Ixx = imfilter(Ix,CovDists','symmetric','same','conv');
Iyy = imfilter(Iy,CovDists,'symmetric','same','conv');
[L, a, b] = RGB2Lab(Img);
[s2, s1] = meshgrid(1:width,1:height);

F = zeros(height,width,1);
F(:,:,1) = L;
F(:,:,2) = a;
F(:,:,3) = b;
F(:,:,4) = abs(Ix);
F(:,:,5) = abs(Iy);
F(:,:,6) = s1;
F(:,:,7) = s2;
F(:,:,8) = abs(Ixx);
F(:,:,9) = abs(Iyy);
for i=1:size(F,3)
    F(:,:,i) = F(:,:,i)/max(max(F(:,:,i)));
end

G = reshape(F,[size(F,1)*size(F,2), size(F,3)]);

% Extract superpixels using SLIC (using VLFeat library)
regionSize = stepsize*min(height,width);
segments = vl_slic(im2single(imread(imfile)), regionSize, ratio, 'verbose') ;
segments = segments+1;

if length(unique(segments))~=max(segments(:))
    A=1:max(segments(:));
    res=setdiff(A,unique(segments));
    for j=1:length(res)
        [index]=find(segments>double(res(j)));
        segments(index)=segments(index)-1;
        res=res-1;
    end
end


segmentList = unique(segments(:))';
segmentCount = length(segmentList);

% Calculate superpixel centers
regionCenters = [];
for i=segmentList
    [indY indX] = find(segments==i);
    regionCenters = [regionCenters; [median(indX) median(indY)]];
end

% Find region adjacency
% [Am, Al] = regionadjacency(segments);

% Use a fully-connected neighborhood structure
Am = ones(segmentCount)-eye(segmentCount);
for i=1:size(Am,1)
    Al{i} = setdiff(1:size(Am,2),i);
end

% Pre-coompute covariance, color and sigma points descriptors
spInd=1;
for sp=segmentList
    Ind = find(segments==sp);
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
    
    Segments{spInd}.cov = cov1;                % Covariance descriptor
    Segments{spInd}.sigmapoints = resRef;      % Sigma points descriptor
    Segments{spInd}.color = mean(G(Ind,1:3));  % Color descriptor
    spInd = spInd + 1;
end

% Compute pairwise spatial and feature distances
DLoc = zeros(segmentCount);
DCov = zeros(segmentCount);
DCol = zeros(segmentCount);
DSig = zeros(segmentCount);
for sp=1:segmentCount
    for spNeighbor = Al{sp}
        DLoc(sp,spNeighbor) = norm(regionCenters(sp,:)-regionCenters(spNeighbor,:));
        DCov(sp,spNeighbor) = norm(Segments{sp}.cov - Segments{spNeighbor}.cov);
        DCol(sp,spNeighbor) = norm(Segments{sp}.color-Segments{spNeighbor}.color);
        DSig(sp,spNeighbor) = norm(Segments{sp}.sigmapoints - Segments{spNeighbor}.sigmapoints);
    end
end

salmapCov = zeros (size(I)); salCov = zeros(1,segmentCount);
salmapSig = zeros (size(I)); salSig = zeros(1,segmentCount);
salmapCol = zeros (size(I)); salCol = zeros(1,segmentCount);
for sp=1:segmentCount
    CovDists = [];
    ColDists = [];
    SigDists = [];
    for spNeighbor = Al{sp}  % traverse the neighbors of superpixel sp (all are considered here!)
        CovDists = [ CovDists DCov(sp,spNeighbor)/DLoc(sp,spNeighbor)];
        ColDists = [ ColDists DCol(sp,spNeighbor)/DLoc(sp,spNeighbor)];
        SigDists = [ SigDists DSig(sp,spNeighbor)/DLoc(sp,spNeighbor)];
    end
    
    dummyCov = sort(CovDists,'ascend');
    dummyCol = sort(ColDists,'ascend');
    dummySig = sort(SigDists,'ascend');
    
    salCov(sp) = sum(dummyCov(1:ceil(length(CovDists)*ratio))/round(length(CovDists)*ratio));
    salCol(sp) = sum(dummyCol(1:ceil(length(ColDists)*ratio))/round(length(ColDists)*ratio));
    salSig(sp) = sum(dummySig(1:ceil(length(SigDists)*ratio))/round(length(SigDists)*ratio));
    
    salmapCov(find(segments==sp)) = salCov(sp);
    salmapCol(find(segments==sp)) = salCol(sp);
    salmapSig(find(segments==sp)) = salSig(sp);
end





if show_results==1
    figure;
    [sx,sy]=vl_grad(double(segments), 'type', 'forward') ;
    s = find(sx | sy) ;
    imp = im2single(imread(imfile));
    imp([s s+numel(imp(:,:,1)) s+2*numel(imp(:,:,1))]) = 1 ;
    subplot(1,1,1);
    imagesc(imp) ; axis image off ; hold on ;
    title('Original Image');
    for i=1:length(segmentList)
        text(regionCenters(i,1),regionCenters(i,2),sprintf('%d',i));
    end
    
end

end

