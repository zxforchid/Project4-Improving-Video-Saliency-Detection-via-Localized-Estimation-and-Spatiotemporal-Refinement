function result = postProcessing(initialResult,curImg)
% ∫Û¥¶¿Ì£¨ 2016.11.22
% 
 [r,c] = size(initialResult);
 guassSigmaRatio = 0.25;
 bb = 10;
 
 if 0
% 1 object-biased 
guassianTemplate = calOptimizedGuassTemplate(initialResult,guassSigmaRatio,[r c]);
guassOptimizeResult = guassianTemplate.*initialResult;
guassOptimizeResult = (guassOptimizeResult-min(guassOptimizeResult(:)))/(max(guassOptimizeResult(:))-min(guassOptimizeResult(:)));

% 2 sigmoid enhancement
sigmoidResult = sigmoidFun(guassOptimizeResult,bb);
 end
 
 sigmoidResult = initialResult;
% 3 graph-cut
gpResult = graphCut_Refine(curImg,sigmoidResult); 

% 4 guildfilter
filterReuslt = guidedfilter(gpResult,gpResult,5,0.1);

result = normalizeSal(filterReuslt);

clear initialResult curImg filterReuslt gpResult sigmoidResult guassOptimizeResult guassianTemplate

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1 object-biased function 
function template = calOptimizedGuassTemplate(refImage,sigmaRatio,windowSize)
%% Calculate the object-biased Gaussian model.

r=windowSize(1);
c=windowSize(2);
template = zeros(r,c);
%% Calculate the object center.
row = 1:r;
row = row';
col = 1:c;
XX = repmat(row,1,c).*refImage;
YY = repmat(col,r,1).*refImage;
xcenter = sum(XX(:))/sum(refImage(:));
ycenter = sum(YY(:))/sum(refImage(:));
%% Calculate the Gaussian model.
sigma=[r*sigmaRatio c*sigmaRatio];
for xx = 1:r
    for yy = 1:c
        template(xx,yy) = exp(-(xx-xcenter)^2/(2*sigma(1)^2)-(yy-ycenter)^2/(2*sigma(2)^2));
    end
end

clear refImage sigmaRatio windowSize XX YY 
end

% 2 sigmoid function
function result = sigmoidFun(imSal,bb)
result = 1./(1+exp(-bb*(imSal-0.5)));
result = normalizeSal(result);

clear imSal
end
