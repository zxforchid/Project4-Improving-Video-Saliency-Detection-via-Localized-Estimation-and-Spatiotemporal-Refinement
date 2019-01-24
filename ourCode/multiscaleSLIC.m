function result = multiscaleSLIC(image,spnumbers)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% multiscaleSLIC
% ͼ��֮��߶ȷָ�
% image ����ͼ��
% spnumber �����طָ�ĳ߶ȣ���߶ȣ�
% V1�� 2016.07.20
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
result = cell(length(spnumbers),1);
[height,width,dim] = size(image);
for ss=1:length(spnumbers)
% �����طָ�
spnumber = spnumbers(ss);
[idxcurrImage, adjcMatrix, pixelList,area] = SLIC_Split(image, spnumber);
spNum = size(adjcMatrix, 1);
bdIds = GetBndPatchIds(idxcurrImage); 

meanRgbCol = GetMeanColor(image, pixelList);
meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
colDistM = GetDistanceMatrix(meanLabCol);
[clipVal, ~, ~] = EstimateDynamicParas(adjcMatrix, colDistM);

meanPos = GetNormedMeanPos(pixelList, height, width);
posDistM = GetDistanceMatrix(meanPos);

% adjcMatrix(adjcMatrix==2) = 1;% ��ȥ�Խ���Ԫ�أ�1 ��ʾ�ڽ�
adjcMatrix1 = adjcMatrix;
adjcMatrix1(adjcMatrix1==2) = 1;
adjmat = double( adjcMatrix1 ) .* (1 - eye(spNum, spNum));
adjmat = full(adjmat);    
%---------------  ��������������Ϣ 2016.08.01 -------------------
spcenter = regionprops(idxcurrImage, 'Centroid');
region_center = zeros(spNum,2);
for ii=1:spNum
    region_center(ii,1) =  spcenter(ii).Centroid(1);
    region_center(ii,2) =  spcenter(ii).Centroid(2);
end
%---------------------------------------------------------------
result{ss,1}.adjcMatrix = adjcMatrix;
result{ss,1}.colDistM = colDistM;
result{ss,1}.clipVal = clipVal;
result{ss,1}.idxcurrImage = idxcurrImage;
result{ss,1}.adjmat = adjmat;
result{ss,1}.pixelList =pixelList;
result{ss,1}.area = area;
result{ss,1}.spNum = spNum;
result{ss,1}.bdIds = bdIds;
result{ss,1}.posDistM = posDistM;
result{ss,1}.region_center = region_center;

clear idxcurrImage adjmat adjcMatrix pixelList area bdIds region_center spcenter
clear colDistM clipVal
end

clear image spnumbers

end