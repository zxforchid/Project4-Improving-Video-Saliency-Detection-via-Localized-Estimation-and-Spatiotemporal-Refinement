function [ out ] = normalizeSal( img )
img = double(img);

if max(img(:)) == min(img(:))% ��ֹ���ݹ�С
    out=(img-min(img(:)))/(max(img(:))-min(img(:))+eps);
else
    out=(img-min(img(:)))/(max(img(:))-min(img(:)));
end
end

