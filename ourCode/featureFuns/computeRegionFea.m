function regionFea = computeRegionFea(image,flow,tmpSPinfor)
% Lab + Flow
% 
meanRgbCol = GetMeanColor(image, tmpSPinfor.pixelList);
meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
clear image

curFlow = double(flow);
Magn    = sqrt(curFlow(:,:,1).^2+curFlow(:,:,2).^2);    
Ori     = atan2(-curFlow(:,:,1),curFlow(:,:,2));
meanMagn = GetMeanColor(Magn, tmpSPinfor.pixelList);
meanOri  = GetMeanColor(Ori, tmpSPinfor.pixelList);
clear Ori Magn flow
clear  tmpSPinfor

% [height,width] = size(im_L);
% regionFea = zeros(tmpSPinfor.spNum,5);
regionFea = [meanLabCol,meanMagn,meanOri];

clear meanLabCol meanMagn meanOri


end