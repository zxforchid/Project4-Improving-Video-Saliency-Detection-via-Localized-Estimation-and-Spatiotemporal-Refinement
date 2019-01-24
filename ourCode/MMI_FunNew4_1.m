function MMI_FunNew4_1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 采用 co-map 的形式于多模型之融合
% 2017.03.27 20:21PM
% 引入了zhouzhihua的工作，并采用co-map的形式进行融合 
% 2017.03.29 14:51PM
% 
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
            INITSALS_ORI{1,vv} = initSals;
            INITSALS{1,vv} = initSals_GP;
            clear initSals initSals_GP
        end
        fprintf('obtain the initSal ......\n')
        initSals = obtainWeakSal(INITSALS_ORI);% 未进行gp细化，最原始的平均结果
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear initSals INITSALS_ORI
        
        initSals = obtainWeakSal(INITSALS);% GP版的initsal，用于后续的improve
        clear INITSALS
        
        fprintf('improving process ......')
%             for iter=1:param.iterNum % 可以进行多次迭代
            % initInfor: frames/Flows/spInfors/Feas/initSals 五种
            fprintf('forward process ...\n')
            [initSalsF] = forwardProcess1_New(frames,spInfors,Feas,initSals,param);
            
            fprintf('backward process ...\n')
            [initSalsB] = backwardProcess1_New(frames,spInfors,Feas,initSals,param);
            
            fprintf('integration ...\n')% 两种不同的融合方式
            SALS1 = obtainFBSal_SMI(initSalsF,initSalsB);
%             SALS2 = integrateSals(initSals,forwardSals,backwardSals);
%             initSals = SALS2;
            
            clear forwardSals backwardSals initSals
%             end

            fprintf('save ...\n')
            saveSals(SALS1,initSalsF,initSalsB,frame_names,saliencyMapPath_Our);
%             save_finalSals2(SALS2,frame_names,saliencyMapPath_Our);% 2017.3.26
            
            clear initSalsF initSalsB SALS1 SALS2
            clear saliencyMapPath_Models initSals 
%             clear frames frame_names Feas initSals spInfors
            
        clear video_data Groundtruth_path 
        clear frames frame_names Feas spInfors
end