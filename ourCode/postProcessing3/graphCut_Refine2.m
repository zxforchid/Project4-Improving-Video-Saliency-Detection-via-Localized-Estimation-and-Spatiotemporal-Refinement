function result = graphCut_Refine2(image,smap)
% 利用graph-cut 修正显著性图
% 颜色使用Lab
% 
lambdaPara = 0.1;
[h, w, dim] = size(image);
if dim==1
    temp=uint8(zeros(h,w,3));
    temp(:,:,1)=image;
    temp(:,:,2)=image;
    temp(:,:,3)=image;
    image=temp;
end
% 引入Lab颜色特征
image = uint8(image);
image = im2double(image);
image_lab = rgb2lab( image );
m1      = image_lab(:,:,1) / 100;
m2      = image_lab(:,:,2) / 220 + 0.5;
m3     = image_lab(:,:,3) / 220 / 0.5;
clear  image_lab

% image = double(image);
% % 平滑项
% m1 = image(:,:,1);
% m2 = image(:,:,2);
% m3 = image(:,:,3); 
% clear image

% edge 连接
E = edges4connected(h,w);

% [~, ~, sptialDist] = computeDist(E, h, w);
colorDist = (m1(E(:,1))-m1(E(:,2))).^2+(m2(E(:,1))-m2(E(:,2))).^2+(m3(E(:,1))-m3(E(:,2))).^2;
meanColorDist = mean(colorDist);
if meanColorDist==0
    meanColorDist = meanColorDist+ eps;
end
V = exp(-colorDist/(5*meanColorDist));% Lab
% V = exp(-colorDist/(5*meanColorDist));%./sptialDist;% RGB
AA = lambdaPara * sparse(E(:,1),E(:,2),V);

% 滤波器核
g = fspecial('gauss', [5 5], sqrt(5));  

% graph-cut
[ gcMap, ~ ]  = graphcut0(AA,g,smap);
 gcMap = double(gcMap);

smap1 = smap + gcMap;
result = normalizeSal(smap1); %toc


clear image smap
end