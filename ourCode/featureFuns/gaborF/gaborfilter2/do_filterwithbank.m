function [result] = do_filterwithbank(im,bank)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ����ʵ�֣���ͼ��ʹ��Gabor�˲������ת����
%
%%% ������
%   im       �� ��ת����ͼ��
%   bank        �� �ɺ���do_createfilterbank�õ����˲���
%
%%% ���أ�
%   result                     �� ͼ��ת����Ľ��
%       .amplitudes            �� ��ͬ���ص���������
%       .phases                �� ��ͬ���ص����λ����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[N1 N2] = size(im);
N3 = length(bank);
phases = zeros(N1,N2,N3);
amplitudes = zeros(N1,N2,N3);
imagefft = fft2(im);

for ind = 1:N3
    fprintf('���ڴ����˲� %d \n',ind);
     temp = ifft2(imagefft .* bank{ind}.filter);
     phases(:,:,ind) = angle(temp);
     amplitudes(:,:,ind) = abs(temp);
end
result.phases = phases;
result.amplitudes = amplitudes;

end