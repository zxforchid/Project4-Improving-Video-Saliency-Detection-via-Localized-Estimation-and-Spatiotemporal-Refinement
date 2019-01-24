% -------------------------------------------------------------------------
% Gradient computation using central difference filter [-1 0 1]. Gradients
% at the image borders are computed using forward difference. Gradient
% directions are between -180 and 180 degrees measured counterclockwise
% from the positive X axis.
% -------------------------------------------------------------------------
function [gMag, gDir] = hogGradient(img,roi)

if nargin == 1
    roi = [];    
    imsize = size(img);
else
    imsize = roi(3:4);
end

img = single(img);

if ndims(img)==3
    rgbMag = zeros([imsize(1:2) 3],class(img));
    rgbDir = zeros([imsize(1:2) 3],class(img));
    
    for i = 1:3
        [rgbMag(:,:,i), rgbDir(:,:,i)] = computeGradient(img(:,:,i),roi);
    end
    
    % find max color gradient for each pixel
    [gMag, maxChannelIdx] = max(rgbMag,[],3);
    
    % extract gradient directions from locations with maximum magnitude
    sz = size(rgbMag);
    [rIdx, cIdx] = ndgrid(1:sz(1), 1:sz(2));
    ind  = sub2ind(sz, rIdx(:), cIdx(:), maxChannelIdx(:));
    gDir = reshape(rgbDir(ind), sz(1:2));
else
    [gMag,gDir] = computeGradient(img,roi);
end
% -------------------------------------------------------------------------
% Gradient computation for ROI within an image.
% -------------------------------------------------------------------------
function [gx, gy] = computeGradientROI(img, roi)
img    = single(img);
imsize = size(img);

% roi is [r c height width]
rIdx = roi(1):roi(1)+roi(3)-1;
cIdx = roi(2):roi(2)+roi(4)-1;

imgX = coder.nullcopy(zeros([roi(3)   roi(4)+2],class(img)));
imgY = coder.nullcopy(zeros([roi(3)+2 roi(4)  ],class(img)));

% replicate border pixels if ROI is on the image border. 
if rIdx(1) == 1 || cIdx(1)==1  || rIdx(end) == imsize(1) ...
        || cIdx(end) == imsize(2)
    
    if rIdx(1) == 1
        padTop = img(rIdx(1), cIdx);
    else
        padTop = img(rIdx(1)-1, cIdx);
    end
    
    if rIdx(end) == imsize(1)
        padBottom = img(rIdx(end), cIdx);
    else
        padBottom = img(rIdx(end)+1, cIdx);
    end
    
    if cIdx(1) == 1
        padLeft = img(rIdx, cIdx(1));
    else
        padLeft = img(rIdx, cIdx(1)-1);
    end
    
    if cIdx(end) == imsize(2)
        padRight = img(rIdx, cIdx(end));
    else
        padRight = img(rIdx, cIdx(end)+1);
    end
    
    imgX = [padLeft img(rIdx,cIdx) padRight];
    imgY = [padTop; img(rIdx,cIdx);padBottom];
else  
    imgX = img(rIdx,[cIdx(1)-1 cIdx cIdx(end)+1]);
    imgY = img([rIdx(1)-1 rIdx rIdx(end)+1],cIdx);
end

gx = conv2(imgX, [1 0 -1], 'valid');
gy = conv2(imgY, [1;0;-1], 'valid');


% -------------------------------------------------------------------------
function [gMag,gDir] = computeGradient(img,roi)

if isempty(roi)
    gx = zeros(size(img),class(img));
    gy = zeros(size(img),class(img));
    
    gx(:,2:end-1) = conv2(img, [1 0 -1], 'valid');
    gy(2:end-1,:) = conv2(img, [1;0;-1], 'valid');
    
    % forward difference on borders
    gx(:,1)   = img(:,2)   - img(:,1);
    gx(:,end) = img(:,end) - img(:,end-1);
    
    gy(1,:)   = img(2,:)   - img(1,:);
    gy(end,:) = img(end,:) - img(end-1,:);
else
    [gx, gy] = computeGradientROI(img, roi);
end

% return magnitude and direction
gMag = hypot(gx,gy);
gDir = atan2d(-gy,gx);