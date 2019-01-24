function [initSals,initSals_GP] = obtainInitSal2(frame_names,saliencyMapPath,frames)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ��ʼ������ͼ2, ��ģ���ںϣ�ͳһ���� 2~N-1֡ͼ��
% ���ݲ��õĲ�ɫͼ���������ȡ initSal
% ע�⣺ԭʼ sal �ĺ�׺�� .png
% 2017.03.10 10:11AM
% ����ԭʼ��ʼ��������ͼ & GP���������ͼ
% 2017.03.24 22:19PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initSals = cell(1,length(frame_names));
initSals_GP = cell(1,length(frame_names));
for f = 1:length(frame_names) 
     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'.png']);
     tmpInitSal = tmpInitSal(:,:,1);
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals{1,f} = tmpInitSal;
     
     tmpInitSal = graphCut_Refine(frames{1,f},tmpInitSal); 
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals_GP{1,f} = tmpInitSal;
     clear tmpInitSal
end
clear frame_names saliencyMapPath frames

end