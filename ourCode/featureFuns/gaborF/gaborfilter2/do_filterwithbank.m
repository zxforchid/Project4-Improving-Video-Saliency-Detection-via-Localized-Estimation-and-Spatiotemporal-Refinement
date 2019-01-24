function [result] = do_filterwithbank(im,bank)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% 函数实现：对图像使用Gabor滤波组进行转换换
%
%%% 参数：
%   im       — 被转换的图像
%   bank        — 由函数do_createfilterbank得到的滤波组
%
%%% 返回：
%   result                     — 图像被转换后的结果
%       .amplitudes            — 不同像素点的振幅向量
%       .phases                — 不同像素点的相位向量
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N1 N2] = size(im);
N3 = length(bank);
phases = zeros(N1,N2,N3);
amplitudes = zeros(N1,N2,N3);
imagefft = fft2(im);

for ind = 1:N3
    fprintf('正在处理滤波 %d \n',ind);
     temp = ifft2(imagefft .* bank{ind}.filter);
     phases(:,:,ind) = angle(temp);
     amplitudes(:,:,ind) = abs(temp);
end
result.phases = phases;
result.amplitudes = amplitudes;

end