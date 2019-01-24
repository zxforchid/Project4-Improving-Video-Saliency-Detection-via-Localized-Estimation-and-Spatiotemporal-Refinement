function sal = weak_strong_fusion(weakSal,strongSal,im,weights)
% sal=normalizeSal(weakSal*0.3+strongSal*0.7);

sal=normalizeSal(weakSal*weights(1) + strongSal*weights(2));

% sal=normalizeSal(weakSal+strongSal);

% sal = graphCut_Refine(im,sal); 
% sal = normalizeSal(guidedfilter(sal,sal,6,0.1));

clear weakSal strongSal
end