% ²âÊÔ region covriance ÓÚµ¥·ùÍ¼Ïñ
% 2016/06/02  22:14PM
% xiaofei zhou
% 

clear all;close all;clc 

Img = imread(['.\regionCov\272.jpg']);
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


spnumber = 200;
[idxImg, adjcMatrix, pixelList,area] = SLIC_Split(Img, spnumber);
spNum = size(adjcMatrix, 1);


% Pre-coompute covariance, color and sigma points descriptors
spInd=1;
for sp=1:spNum
    Ind = find(idxImg==sp);
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


