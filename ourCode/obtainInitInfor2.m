function [frames,frame_names,Feadatas,Flows,spInfors] =  ...
                             obtainInitInfor2(video_data,OPTICALFLOW,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ�������ָ���Ϣ����������ģ���ں� 2~N-1
% ͳһ����Ϊȡ������Ƶ�ĵ� 2~N-1 ֡
% OPTICALFLOW  ����·��
% frames       image
% frame_names  imageName
% 2017.03.10 16:24PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ��ȡ��ɫͼ���׺�� &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
colorImgList = dir(video_data);
suffix_color = colorImgList(5).name(end-3:end);
clear colorImgList
colorImgList = dir(fullfile(video_data, strcat('*', suffix_color)));
Lists = cell(length(colorImgList),2);% ������������֡�ŵĶ�Ӧ��
imgNum = length(colorImgList);
for pp=1:imgNum
    Lists{pp,1} = pp;% ID
    Lists{pp,2} = colorImgList(pp).name(1:end-4);% NAME
end
clear colorImgList

%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
spInfors    = cell(1,imgNum-2);
Feadatas    = cell(1,imgNum-2);
Flows       = cell(1,imgNum-2);
frames      = cell(1,imgNum-2);
frame_names = cell(1,imgNum-2);
nn=1;
for f = 2:(imgNum-1)
    % 1. ��ȡ image & name
     frame_name = [Lists{f,2},suffix_color];
     im = imread([video_data,frame_name(1:end-4),suffix_color]);% �����ƶ�ȡcolorImage
     frames{1,nn} = im;
     frame_names{1,nn} = frame_name;
    
     % 2. ���������������Ӧ��֡�Ŷ�Ӧ����
%      for ss=1:imgNum
%          tmpName = Lists{ss,2};
%          if strcmp(frame_name(1:end-4),tmpName)
%              ID =  Lists{ss,1};
%              break;
%          end
%          clear tmpName
%      end
     ID = Lists{f,1};
     load ([OPTICALFLOW,'opf_',num2str(ID),'.mat'],'MVF_Foward_f_fp')
     Flows{1,nn} = MVF_Foward_f_fp;
     
     % 3. �ָ���Ϣ
     spInfor = multiscaleSLIC(im,param.spnumbers);
     spInfors{1,nn} = spInfor;
     
     % 4. ����
     feadata = featureExtract0(im, MVF_Foward_f_fp, spInfor);
     Feadatas{1,nn} = feadata;
    
    clear frame_name im ID MVF_Foward_f_fp spInfor feadata
    nn = nn + 1;
end
clear video_data OPTICALFLOW param nn Lists
end