function [initSals] = obtainInitSal1(frame_names,saliencyMapPath,frames)
% ��ȡ��ʼ������ͼ2, ��ģ������
% ע�⣺ԭʼ sal �ĺ�׺�� .png
% 2017.03.10 10:11AM
% 
initSals = cell(1,length(frame_names)-1);
for f = 1:(length(frame_names)-1) 
     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'.png']);
     tmpInitSal = normalizeSal(tmpInitSal);
     
     tmpInitSal = graphCut_Refine(frames{1,f},tmpInitSal); 
     tmpInitSal = normalizeSal(tmpInitSal);
    
     initSals{1,f} = tmpInitSal;
     clear tmpInitSal
end
clear frame_names saliencyMapPath frames

end