% test

cur_image = im2double(cur_image);% 2016.12.02 15:38PM， 0~1
[height,width,dims] = size(cur_image);

% color transform ------------------
im_R = cur_image(:,:,1);
im_G = cur_image(:,:,2);
im_B = cur_image(:,:,3);

% 2 covariance
I = (im_R+im_G+im_B)/3;
CovDists = [-1 0 1];
Iy = imfilter(I,CovDists,'symmetric','same','conv');
Ix = imfilter(I,CovDists','symmetric','same','conv');
Ixx = imfilter(Ix,CovDists','symmetric','same','conv');
Iyy = imfilter(Iy,CovDists,'symmetric','same','conv');
[s2, s1] = meshgrid(1:width,1:height);
normS = sqrt(height^2 + width^2);% 加入对角线归一化
s1 = s1./normS;
s2 = s2./normS;
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

regionCov = COVSIGMA(im_COV,tmpSP.idxcurrImage,tmpSP.spNum);

