function save_Sals_New1(SLAS,frame_names,saliencyMapPath,suffix,ii)
% 保存初始显著性图
% ii 是帧的 ID 序号
% SLAS 1*frameNum 的cell
% 2017.04.03 13:52PM
% 
% frameNum = length(SLAS);
% for ii=1:frameNum
    tmpSal = SLAS{1,ii};
    tmpSal = uint8(255*tmpSal);
%     imwrite(tmpFore,[saliencyMapPath,frame_names{1,ii}(1:end-4),'_foreward.png']) 
    imwrite(tmpSal,[saliencyMapPath,frame_names{1,ii}(1:end-4),suffix]) 
    clear tmpSal
% end

clear SLAS frame_names saliencyMapPath suffix
end