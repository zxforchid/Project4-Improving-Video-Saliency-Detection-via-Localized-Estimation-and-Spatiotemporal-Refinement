function [bank] = do_createfilterbank(imsize,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ����ʵ�֣�����Gabor �˲���
%
%%% ��ѡ������
%   imsize - ͼ���С
%%% ��ѡ������
%   freqnum �� Ƶ����Ŀ
%   orientnum �� ������Ŀ
%   f       ��   Ƶ�����еĲ�������
%   kmax    ��   ���Ĳ���Ƶ��
%   sigma   ��   ��˹���Ŀ���벨�������ȵı���
%
%%% ���ؽ����
%   bank
%           .freq        ��     �˲�Ƶ��
%           .orient      ��     �˲�����
%           .filter      ��     Gabor�˲�
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
    fprintf('����Ƶ�� %d \n', f0);
    for o0=1:conf.orientnum
        [filter_,freq_,orient_] = do_gabor(imsize,(f0-1),(o0-1),conf.kmax,conf.f,conf.sigma,conf.orientnum);
        bank{(f0-1)*conf.orientnum + o0}.freq = freq_; %��orient��������
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
%%% ����ʵ�֣� ����Gabor�˲�
%
%%% ������
%   imsize     : �˲��Ĵ�С����ͼ���С��
%   nu         : Ƶ�ʱ�� [0 ...freqnum-1];
%   mu         : ������ [0...orientnum-1]
%   Kmax       �� ���Ĳ���Ƶ��
%   f          �� Ƶ�����еĲ�������
%   sigma      : ��˹���Ŀ���벨�������ȵı���
%   orientnum : ��������
%
%%% ����ֵ��
%   filter :    �˲�
%   Kv    :    Ƶ�ʴ�С
%   Phiu :    �����С
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