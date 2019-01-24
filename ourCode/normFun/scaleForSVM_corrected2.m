function [test_scale] = scaleForSVM_corrected2(test_data,MIN,MAX,ymin,ymax)
% correct scaling for SVM | Jan Kodovsky | 2011-10-12

% [MIN,MAX] = deal(min(train_data),max(train_data));
% 
% train_scale = scale_data(train_data,MIN,MAX,ymin,ymax);
% mapping.MAX = MAX;
% mapping.MIN = MIN;
test_scale  = scale_data(test_data,MIN,MAX,ymin,ymax);
clear test_data MIN MAX ymin ymax

end

function data = scale_data(data,MIN,MAX,ymin,ymax)
N = size(data,1);
data = data-MIN(ones(N,1),:);
data = data./(MAX(ones(N,1),:)-MIN(ones(N,1),:) + eps);
data = data*(ymax-ymin)-ymin;
clear MIN MAX ymin ymax
end