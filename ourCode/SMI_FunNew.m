function SMI_FunNew(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 全新的设计： 特征/分类器/策略
% 2017.03.24 14:16PM
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf( ['VideoName: ',videoNames(gg).name,'............\n']);
        video_data=[root_videoDataSet,videoNames(gg).name,'\'];
        OPTICALFLOW=[rootFlow,DatasetName,'\',videoNames(gg).name,'\'];

        for vv=1:length(salModels)
            fprintf('process model %s ......\n',salModels{vv})
            fprintf('obtain initSal ...\n')
            saliencyMapPath_Models = ...
                [modelPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            [frames,frame_names,Feas,initSals,~,spInfors] = ...
                      obtainInitInfor1(saliencyMapPath_Models,video_data,OPTICALFLOW,param);
            clear Flows
            
            saliencyMapPath_Our =...
                [salPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            if( ~exist( saliencyMapPath_Our, 'dir' ) )
               mkdir( saliencyMapPath_Our );
            end
            
            for iter=1:param.iterNum % 可以进行多次迭代  1
            % initInfor: frames/Flows/spInfors/Feas/initSals 五种
            fprintf('forward process ...\n')
            [forwardSals] = forwardProcess1(frames,spInfors,Feas,initSals,param);
            
            fprintf('backward process ...\n')
            [backwardSals] = backwardProcess1(frames,spInfors,Feas,initSals,param);
            
            fprintf('integration ...\n')
            SALS = integrateSals(initSals,forwardSals,backwardSals,frames);
            initSals = SALS;
            if iter<param.iterNum
                clear forwardSals backwardSals SALS initSals
            end
            end
            fprintf('save ...\n')
            saveSals(SALS,forwardSals,backwardSals,frame_names,saliencyMapPath_Our);
            
            clear forwardSals backwardSals SALS
            clear saliencyMapPath_Models initSals 
        end

        clear video_data Groundtruth_path 

end