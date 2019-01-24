function [bank] = do_createfilterbank(imsize,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 函数实现：创建Gabor 滤波组
%
%%% 必选参数：
%   imsize - 图像大小
%%% 可选参数：
%   freqnum — 频率数目
%   orientnum — 方向数目
%   f       —   频率域中的采样步长
%   kmax    —   最大的采样频率
%   sigma   —   高斯窗的宽度与波向量长度的比率
%
%%% 返回结果：
%   bank
%           .freq        —     滤波频率
%           .orient      —     滤波方向
%           .filter      —     Gabor滤波
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conf = struct(...,
    'freqnum',3,...
    'orientnum',6,...
    'f',sqrt(2),...
    'kmax',(pi/2),...
    'sigma',(sqrt(2)*pi) ...
    );

conf = do_getargm(conf,varargin);

bank = cell(1,conf.freqnum*conf.orientnum);
for f0=1:conf.freqnum
    fprintf('处理频率 %d \n', f0);
    for o0=1:conf.orientnum
        [filter_,freq_,orient_] = do_gabor(imsize,(f0-1),(o0-1),conf.kmax,conf.f,conf.sigma,conf.orientnum);
        bank{(f0-1)*conf.orientnum + o0}.freq = freq_; %以orient增序排列
        bank{(f0-1)*conf.orientnum + o0}.filter = filter_;
        bank{(f0-1)*conf.orientnum + o0}.orient = orient_;
    end
end

for ind = 1:length(bank)
    bank{ind}.filter=fftshift(bank{ind}.filter);
end
end


function [filter,Kv,Phiu] = do_gabor (imsize,nu,mu,Kmax,f,sigma,orientnum)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 函数实现： 创建Gabor滤波
%
%%% 参数：
%   imsize     : 滤波的大小（即图像大小）
%   nu         : 频率编号 [0 ...freqnum-1];
%   mu         : 方向编号 [0...orientnum-1]
%   Kmax       ： 最大的采样频率
%   f          ： 频率域中的采样步长
%   sigma      : 高斯窗的宽度与波向量长度的比率
%   orientnum : 方向总数
%
%%% 返回值：
%   filter :    滤波
%   Kv    :    频率大小
%   Phiu :    方向大小
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rows = imsize(1);
cols = imsize(2);
minrow = fix(-rows/2);
mincol = fix(-cols/2);
row = minrow + (0:rows-1);
col = mincol + (0:cols-1);
[X,Y] = meshgrid(col,row);

Kv = Kmax/f^nu;
Phiu = pi * mu /orientnum;
K = Kv * exp(i * Phiu);

F1 = (Kv ^ 2)/ (sigma^2) * exp(-Kv^2 * abs(X.^2 + Y.^2) / (2*sigma^2)) ;
F2 = exp(i * (real(K) * X + imag(K) * Y)) - exp(-sigma^2/2);
filter = F1.* F2;

end