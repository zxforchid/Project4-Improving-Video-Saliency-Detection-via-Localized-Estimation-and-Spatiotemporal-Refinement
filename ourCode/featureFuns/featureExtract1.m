function result = featureExtract1(image,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% featureExtract
% 特征提取第一段之low level feature
% input:
% image 输入图像之单通道，例如 L 通道
% 
% Output:
% result M*N cell, M代表方向（8），N代表尺度（相邻处理机制12）
% 
% V1： 2016.07.19
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gbscales = param.gbscales;
gborient = param.gborient;

% gborient = 8;
[height,width] = size(image);
ImgSize = [width,height];
ImgData_temp = image(:);clear image

%GaborFeature = zeros(dim, m_nScale/2 * m_nOrientation);
GaborFeature = gaborextractionmultiscale(ImgData_temp,ImgSize,gbscales,gborient);
clear ImgData_temp;

% GaborFeature_temp = zeros(height*width, gbscales/2);
% for cross = 1 : gbscales/2
%     index = ((cross-1)*gborient + 1) : cross*gborient;
%     GaborFeature_temp(:, cross) = mean(GaborFeature(:, index), 2);
% end
% GaborFeature = GaborFeature_temp;

result = cell(gborient,gbscales/2);

for jj=1:(gbscales/2)
    for ii=1:gborient
%         index_begin = (jj-1)* gborient  + ;
%         index_end = jj * gborient;
        indexGB = (ii-1)*gborient + jj;
        tmpGBMAP = GaborFeature(:,indexGB);
        result{ii,jj} = reshape(tmpGBMAP,[height,width]);
        clear tmpGBMAP
    end
end

clear GaborFeature
end