function SMI_FunNew1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 引入了zhouzhihua的工作， 
% 2017.03.29 14:51PM
% 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf( ['VideoName: ',videoNames(gg).name,'............\n']);
        video_data=[root_videoDataSet,videoNames(gg).name,'\'];
        OPTICALFLOW=[rootFlow,DatasetName,'\',videoNames(gg).name,'\'];
               
        for vv=1:length(salModels)
            fprintf('process model %s ......\n',salModels{vv})
            fprintf('obtain initSal ...\n')
            saliencyMapPath_Models = ...
                [modelPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            [frames,frame_names,FeadatasF,FeadatasB,initSals,spInfors] = ...
                      obtainInitInfor1(saliencyMapPath_Models,video_data,OPTICALFLOW,param);
            
            saliencyMapPath_Our =...
                [salPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            if( ~exist( saliencyMapPath_Our, 'dir' ) )
               mkdir( saliencyMapPath_Our );
            end
            
%             for iter=1:param.iterNum % 可以进行多次迭代
            % initInfor: frames/Flows/spInfors/Feas/initSals 五种
            fprintf('forward process ...\n')
            [initSalsF] = forwardProcess1_New(frames,spInfors,FeadatasF,initSals,param);
            clear FeadatasF
            
            fprintf('backward process ...\n')
            [initSalsB] = backwardProcess1_New(frames,spInfors,FeadatasB,initSals,param);
            clear FeadatasB
            
            fprintf('integration ...\n')% 两种不同的融合方式
            SALS1 = obtainFBSal_SMI(initSalsF,initSalsB);
%             end

            fprintf('save ...\n')
            saveSals(SALS1,initSalsF,initSalsB,frame_names,saliencyMapPath_Our);
%             save_finalSals2(SALS2,frame_names,saliencyMapPath_Our);% 2017.3.26
            
            clear initSalsF initSalsB SALS1 
            clear saliencyMapPath_Models initSals 
            clear frames frame_names Feas initSals spInfors
        end

clear video_data Groundtruth_path 
clear root_videoDataSet rootFlow modelPath 
clear salPath DatasetName videoNames salModels param gg
end