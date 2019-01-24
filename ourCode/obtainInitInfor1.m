% function [frames,frame_names,Feadatas,initSals,Flows,spInfors] = ...
function [frames,frame_names,FeadatasF,FeadatasB,initSals,spInfors] = ...
    obtainInitInfor1(saliencyMapPath,video_data,OPTICALFLOW,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% ���ڵ�ģ��������������֪��ģ�ͣ���ȡ��Ӧ��image����Ϣ������ͳһ
% ���� initSal �����Ƽ���������������Ϣ����Ŀ������
% ע�⣺ԭʼ sal �ĺ�׺�� .png
% 2017.03.10 16::42PM
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
% clear colorImgList

% flowList = dir(fullfile(OPTICALFLOW, strcat('*', '.mat')));% 1~N
%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
files       = dir(fullfile(saliencyMapPath, strcat('*', '.png')));   
% fileNum = length(files);
% ��������ͼ���������ڲ�ɫͼ������������һ֡��ǰ����������� 2017.3.13 7:26
% if fileNum==imgNum
%     FrameNum = fileNum-1;
% else
%     FrameNum = fileNum;
% end
% ������һ֡ & ���һ֡ 2017.04.05
initSals    = cell(1,imgNum-2);
spInfors    = cell(1,imgNum-2);
FeadatasF    = cell(1,imgNum-2);
FeadatasB    = cell(1,imgNum-2);
frames      = cell(1,imgNum-2);
frame_names = cell(1,imgNum-2);

% original &&&
% initSals    = cell(1,FrameNum-1);
% spInfors    = cell(1,FrameNum-1);
% FeadatasF    = cell(1,FrameNum-1);
% FeadatasB    = cell(1,FrameNum-1);
% % Flows       = cell(1,FrameNum-1);
% frames      = cell(1,FrameNum-1);
% frame_names = cell(1,FrameNum-1);
for ff = 2:imgNum-1
    f = ff-1;
    % 0. ��ȡ������ͼ
%      frame_name = files(ff).name;
     frame_name = colorImgList(ff).name;
     tmpInitSal = imread([saliencyMapPath,frame_name(1:end-4),'.png']);
     tmpInitSal = tmpInitSal(:,:,1);
     tmpInitSal = normalizeSal(tmpInitSal);
     im = imread([video_data,frame_name(1:end-4),suffix_color]);% �����ƶ�ȡcolorImage
     tmpInitSal = graphCut_Refine(im,tmpInitSal); 
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals{1,f} = tmpInitSal;
     frames{1,f} = im;
     frame_names{1,f} = [frame_name(1:end-4),'.png'];
     
     % 1. ���������������Ӧ��֡�Ŷ�Ӧ����
     for ss=1:imgNum
         tmpName = Lists{ss,2};
         if strcmp(frame_name(1:end-4),tmpName)
             ID =  Lists{ss,1};
             break;
         end
         clear tmpName
     end
     load ([OPTICALFLOW,'opf_',num2str(ID),'.mat'],'MVF_Foward_f_fp')
     load ([OPTICALFLOW,'opf_',num2str(ID),'.mat'],'MVF_Foward_f_fn')
%      Flows{1,f} = MVF_Foward_f_fp;
     
     % 2. �ָ���Ϣ
     spInfor = multiscaleSLIC(im,param.spnumbers);
     spInfors{1,f} = spInfor;
     
     % 3. ����
     feadataF = featureExtract0(im, MVF_Foward_f_fp, spInfor);
     FeadatasF{1,f} = feadataF;

     feadataB = featureExtract0(im, MVF_Foward_f_fn, spInfor);
     FeadatasB{1,f} = feadataB;
     
     clear feadataF feadataB spInfor MVF_Foward_f_fp MVF_Foward_f_fn tmpInitSal im frame_name 
end
clear saliencyMapPath video_data Lists files

end