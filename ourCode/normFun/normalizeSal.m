function [ out ] = normalizeSal( img )
img = double(img);

if max(img(:)) == min(img(:))% 防止数据过小
    out=(img-min(img(:)))/(max(img(:))-min(img(:))+eps);
else
    out=(img-min(img(:)))/(max(img(:))-min(img(:)));
end
end

