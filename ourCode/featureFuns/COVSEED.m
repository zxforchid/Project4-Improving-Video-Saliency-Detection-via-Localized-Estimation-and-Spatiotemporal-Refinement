function result = COVSEED(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 用于COV操作的像素点描述
% I 输入图像
% result (height*width)*7
%
% V1： 2016.07.20
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I = double(I);
[height,width] = size(I);
CovDists = [-1 0 1];
Iy = imfilter(I,CovDists,'symmetric','same','conv');
Ix = imfilter(I,CovDists','symmetric','same','conv');
Ixx = imfilter(Ix,CovDists','symmetric','same','conv');
Iyy = imfilter(Iy,CovDists,'symmetric','same','conv');
[s2, s1] = meshgrid(1:width,1:height);

F = zeros(height,width,7);
F(:,:,1) = s1; F(:,:,2) = s2; F(:,:,3) = I;
F(:,:,4) = abs(Ix); F(:,:,5) = abs(Iy);
F(:,:,6) = abs(Ixx); F(:,:,7) = abs(Iyy);

for i=1:size(F,3)
    F(:,:,i) = F(:,:,i)/max(max(F(:,:,i)));
end

result = reshape(F,[size(F,1)*size(F,2), size(F,3)]);

clear F I Ix Iy Ixx Iyy

end