function [Flows,spInfors,Feadatas] = obtainInitInfor(OPTICALFLOW,frames,frame_names)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ�������ָ���Ϣ��������original
% OPTICALFLOW  ����·��
% frames       image
% frame_names  imageName
% 2017.03.10 16:24PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Flows = cell(1,length(frame_names)-1);
spInfors = cell(1,length(frame_names)-1);
Feadatas = cell(1,length(frame_names)-1);
for f = 1:(length(frame_names)-1) 
     % 1. ����
     load ([OPTICALFLOW,'opf_',num2str(f),'.mat'],'MVF_Foward_f_fp')
     Flows{1,f} = MVF_Foward_f_fp;
     clear MVF_Foward_f_fp
     
     % 2. �ָ���Ϣ
     spInfor = multiscaleSLIC(frames{1,f},param.spnumbers);
     spInfors{1,f} = spInfor;
     
     % 3. ����
     feadata = featureExtract0(frames{1,f}, Flows{1,f}, spInfor);
     Feadatas{1,f} = feadata;
     clear feadata spInfor
end
clear OPTICALFLOW frame_names frames
end