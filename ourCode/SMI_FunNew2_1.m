function SMI_FunNew2_1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ������zhouzhihua�Ĺ����� 
% 2017.03.29 14:51PM
% �ֽ׶ν���ע��ģ�͵�����
% 2017.04.05 15:19PM
% �ڲ�����
% 2017.04.07 11:13AM
% ���У����ڸ��º��������ͼ���ſ�����ֵ
% 2017.04.17  22:15
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf( ['VideoName: ',videoNames(gg).name,'............\n']);
        video_data=[root_videoDataSet,videoNames(gg).name,'\'];
        OPTICALFLOW=[rootFlow,'\',videoNames(gg).name,'\'];
        
        % 1. ��ȡ���� &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
        fprintf('feature extract ...\n')
        [frames,frame_names,frameRecords,FeadatasF,FeadatasB,spInfors] = ...
                      obtainInitInfor2_1(video_data,OPTICALFLOW,param);
        
        % 2. begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
        modelNum = length(salModels);
        for vv=1:modelNum
            tempModel = salModels{vv};
            fprintf('process model %s .........\n',tempModel)
            perModelProcess(modelPath,salPath,tempModel,videoNames, ...
                         frames,frame_names,frameRecords,spInfors,FeadatasF,FeadatasB,param,gg);
        end
clear frames frame_names FeadatasF FeadatasB spInfors
clear video_data Groundtruth_path 
clear root_videoDataSet rootFlow modelPath 
clear salPath DatasetName videoNames salModels param gg
end

function perModelProcess(modelPath,salPath,tempModel,videoNames, ...
                         frames,frame_names,frameRecords, spInfors,FeadatasF,FeadatasB,param,gg)
            fprintf('obtain initSal ...\n')
            saliencyMapPath_Models = ...
                [modelPath,'\',tempModel,'\',videoNames(gg).name,'\'];
           [initSals] = obtainInitSal_SMI(frames,frame_names,frameRecords,saliencyMapPath_Models);

            saliencyMapPath_Our =...
                [salPath,'\',tempModel,'\',videoNames(gg).name,'\'];
            if( ~exist( saliencyMapPath_Our, 'dir' ) )
               mkdir( saliencyMapPath_Our );
            end
            
            fprintf('forward process ...\n')
            [initSalsF,strongSal] = forwardProcess1_New(frames,spInfors,FeadatasF,initSals,param);
            save_Sals_New(initSalsF,frame_names,frameRecords, saliencyMapPath_Our,'_foreward.png');
            
            clear initSals initSalsF
            clear saliencyMapPath_Models saliencyMapPath_Our
            clear modelPath salPath DatasetName tempModel videoNames
            clear frames frame_names spInfors FeadatasF FeadatasB param gg

end