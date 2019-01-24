function optwCtr = SaliencyOptimizationNew(adjcMatrix, bdIds, motionDistM, colDistM, neiSigmaMOTION,neiSigmaAPP, bgWeight, fgWeight)
% Solve the least-square problem in Equa(9) in our paper

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

adjcMatrix_nn = LinkNNAndBoundary(adjcMatrix, bdIds);

colDistM(adjcMatrix_nn == 0) = Inf;
motionDistM(adjcMatrix_nn == 0) = Inf;

WnAPP    = Dist2WeightMatrix(colDistM,    neiSigmaAPP);      %smoothness term
WnMOTION = Dist2WeightMatrix(motionDistM, neiSigmaMOTION); 


mu = 0.1;                                                   %small coefficients for regularization term
W = WnAPP + WnMOTION + adjcMatrix * mu;                                   %add regularization term
D = diag(sum(W));

bgLambda = 5;   %global weight for background term, bgLambda > 1 means we rely more on bg cue than fg cue.
E_bg = diag(bgWeight * bgLambda);       %background term
E_fg = diag(fgWeight);          %foreground term

spNum = length(bgWeight);
optwCtr =(D - W + E_bg + E_fg) \ (E_fg * ones(spNum, 1));

clear adjcMatrix bdIds motionDistM colDistM neiSigmaMOTION neiSigmaAPP bgWeight fgWeight
end