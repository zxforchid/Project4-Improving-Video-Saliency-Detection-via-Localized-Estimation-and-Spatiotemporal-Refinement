function [frames,frame_names,Feadatas,Flows,spInfors] =  ...
                             obtainInitInfor2(video_data,OPTICALFLOW,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 获取光流、分割信息及特征；多模型融合 2~N-1
% 统一设置为取整个视频的第 2~N-1 帧
% OPTICALFLOW  光流路径
% frames       image
% frame_names  imageName
% 2017.03.10 16:24PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 获取彩色图像后缀名 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& 
colorImgList = dir(video_data);
suffix_color = colorImgList(5).name(end-3:end);
clear colorImgList
colorImgList = dir(fullfile(video_data, strcat('*', suffix_color)));
Lists = cell(length(colorImgList),2);% 建立起名称与帧号的对应表
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
    % 1. 获取 image & name
     frame_name = [Lists{f,2},suffix_color];
     im = imread([video_data,frame_name(1:end-4),suffix_color]);% 按名称读取colorImage
     frames{1,nn} = im;
     frame_names{1,nn} = frame_name;
    
     % 2. 光流：将名称与对应的帧号对应起来
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
     
     % 3. 分割信息
     spInfor = multiscaleSLIC(im,param.spnumbers);
     spInfors{1,nn} = spInfor;
     
     % 4. 特征
     feadata = featureExtract0(im, MVF_Foward_f_fp, spInfor);
     Feadatas{1,nn} = feadata;
    
    clear frame_name im ID MVF_Foward_f_fp spInfor feadata
    nn = nn + 1;
end
clear video_data OPTICALFLOW param nn Lists
end