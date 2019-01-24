function MMI_FunNew3(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 采用 co-map 的形式于多模型之融合
% 2017.03.27 20:21PM
% 采用 co-sample 迭代策略
% 2017.03.28 9:06AM
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf( ['VideoName: ',videoNames(gg).name,'............\n']);
        video_data=[root_videoDataSet,videoNames(gg).name,'\'];
        OPTICALFLOW=[rootFlow,DatasetName,'\',videoNames(gg).name,'\'];
       
        fprintf('obtain the initial information ......\n')
        [frames,frame_names,Feas,Flows,spInfors] =  ...
                             obtainInitInfor2(video_data,OPTICALFLOW,param);
        clear Flows
        
        % 生成保存文件
        saliencyMapPath_Our =...
              [salPath,DatasetName,'\',videoNames(gg).name,'\'];
        if( ~exist( saliencyMapPath_Our, 'dir' ) )
            mkdir( saliencyMapPath_Our );
        end       
        
        fprintf('obtain modelSals ......\n')% 共4个模型：'SGSP','GD','CVS','RWRV'
        INITSALS_ORI = cell(1,length(salModels));
        INITSALS = cell(1,length(salModels));
        for vv=1:length(salModels)
            saliencyMapPath_Models = ...
                [modelPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            [initSals,initSals_GP] = obtainInitSal2(frame_names,saliencyMapPath_Models,frames);
            INITSALS{1,vv} = initSals_GP;
            INITSALS_ORI{1,vv} = initSals;
            clear initSals initSals_GP
        end
        fprintf('obtain the initSal ......\n')
        initSals = obtainWeakSal(INITSALS_ORI);
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear initSals INITSALS_ORI
        
%         initSals = obtainWeakSal(INITSALS);% GP版的initsal
        
        fprintf('improving process ......')
        for iter=1:param.iterNum % 可以进行多次迭代
            % initInfor: frames/Flows/spInfors/Feas/INITSALS 五种,信息对应
            fprintf('forward process ...\n')
            [INITSALS_F,forwardSals] = forwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            
            fprintf('backward process ...\n')
            [INITSALS_B,backwardSals] = backwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            clear INITSALS
            
            fprintf('integration ...\n')
            % 对于当前帧的各模型对应的显著性图进行融合，此时的IINITSALS依然是 1*modelNum/ 1*frameNum
            INITSALS = obtainFBSal_MMI3(INITSALS_F,INITSALS_B);% 1*modelNum/1*frameNum
            SALS3 = obtainWeakSal(INITSALS);% 1*frameNum
            save_finalSals3_New(SALS3,frame_names,saliencyMapPath_Our,iter);% 2017.3.28  10:25AM
            
            clear forwardSals backwardSals SALS3
            clear INITSALS_F INITSALS_B
        end
%             fprintf('save ...\n')
            clear saliencyMapPath_Models initSals 
            
        clear video_data Groundtruth_path 
        clear frames frame_names Feas spInfors
end