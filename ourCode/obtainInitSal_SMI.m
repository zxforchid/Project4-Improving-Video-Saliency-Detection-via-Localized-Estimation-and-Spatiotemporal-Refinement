function [initSals] = obtainInitSal_SMI(frames,frame_names,frameRecords, saliencyMapPath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ��ʼ������ͼ2, ��ģ���ںϣ�ͳһ���� 2~N-1֡ͼ��
% ���ݲ��õĲ�ɫͼ���������ȡ initSal
% ע�⣺ԭʼ sal �ĺ�׺�� .png
% 2017.03.10 10:11AM
% ����ԭʼ��ʼ��������ͼ & GP���������ͼ
% 2017.03.24 22:19PM
% ����SMI�Ķ�Ӧԭģ�͵ĳ�ʼ������ͼ
% 2017.04.06  20:26PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initSals = cell(1,length(frame_names));
% initSals_GP = cell(1,length(frame_names));
for f = 1:length(frame_names) 
     frameRecord = frameRecords{1,f};
     h = frameRecord(1);w = frameRecord(2);
     top = frameRecord(3);
     bot = frameRecord(4);
     left = frameRecord(5);
     right = frameRecord(6);
     partialH = bot - top + 1;
     partialW = right - left + 1;

     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'.png']);
     tmpInitSal = tmpInitSal(:,:,1);
     
     if partialH ~= h || partialW ~= w % ��ȡ���Ĳ���
        tmpInitSal = tmpInitSal(top:bot, left:right);
     end
     
     tmpInitSal = normalizeSal(tmpInitSal);
     tmpInitSal = graphCut_Refine(frames{1,f},tmpInitSal); 
%      tmpInitSal = normalizeSal(guidedfilter(tmpInitSal,tmpInitSal,6,0.1));
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals{1,f} = tmpInitSal;
     clear tmpInitSal h w top bot left right
end
clear frame_names saliencyMapPath frames

end