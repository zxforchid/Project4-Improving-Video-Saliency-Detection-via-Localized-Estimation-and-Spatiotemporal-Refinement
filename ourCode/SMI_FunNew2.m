function SMI_FunNew2(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ������zhouzhihua�Ĺ����� 
% 2017.03.29 14:51PM
% �ֽ׶ν���ע��ģ�͵�����
% 2017.04.05 15:19PM
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf( ['VideoName: ',videoNames(gg).name,'............\n']);
        video_data=[root_videoDataSet,videoNames(gg).name,'\'];
        OPTICALFLOW=[rootFlow,DatasetName,'\',videoNames(gg).name,'\'];
        
        % 1. ��ȡ���� &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
        fprintf('feature extract ...\n')
        [frames,frame_names,FeadatasF,FeadatasB,spInfors] = ...
                      obtainInitInfor2_1(video_data,OPTICALFLOW,param);
        
        % 2. begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
        for vv=1:length(salModels)
            fprintf('process model %s .........\n',salModels{vv})
            fprintf('obtain initSal ...\n')
            saliencyMapPath_Models = ...
                [modelPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
           [initSals] = obtainInitSal_SMI(frames,frame_names,saliencyMapPath_Models);

            saliencyMapPath_Our =...
                [salPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            if( ~exist( saliencyMapPath_Our, 'dir' ) )
               mkdir( saliencyMapPath_Our );
            end
            
            fprintf('forward process ...\n')
            [initSalsF] = forwardProcess1_New(frames,spInfors,FeadatasF,initSals,param);
            save_Sals_New(initSalsF,frame_names,saliencyMapPath_Our,'_foreward.png');
            
            fprintf('backward process ...\n')
            [~] = backwardProcess1_New_SMI(frames,spInfors,FeadatasB,initSals,initSalsF, ... 
                                           param,frame_names,saliencyMapPath_Our);
            clear initSals initSalsF
            clear saliencyMapPath_Models saliencyMapPath_Our
        end
clear frames frame_names FeadatasF FeadatasB spInfors

clear video_data Groundtruth_path 
clear root_videoDataSet rootFlow modelPath 
clear salPath DatasetName videoNames salModels param gg
end