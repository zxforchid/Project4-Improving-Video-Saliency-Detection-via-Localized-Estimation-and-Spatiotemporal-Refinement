function [bgProb, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma)
% Estimate background probability using boundary connectivity

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

bdCon = BoundaryConnectivity(adjcMatrix, colDistM, bdIds, clipVal, geoSigma, true);

% bdConSigma = 1; %sigma for converting bdCon value to background probability
bdConSigma = mean(bdCon(:));
if bdConSigma==0
    bdConSigma = 1;
end
fgProb = exp(-bdCon.^2 / (2 * bdConSigma * bdConSigma)); %Estimate bg probability
bgProb = 1 - fgProb;

bgWeight = bgProb;
% % bgWeight = normalizeSal(bgWeight);
% Give a very large weight for very confident bg sps can get slightly
% better saliency maps, you can turn it off.

% fixHighBdConSP = true; % 2016.11.25 delete
% highThresh = 3;
% if fixHighBdConSP
%     bgWeight(bdCon > highThresh) = 1000;
% end

end