function MMI_FunNew1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
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
%             [initSals] = obtainInitSal2(frame_names,saliencyMapPath_Models,frames);
%             INITSALS{1,vv} = initSals;
            clear initSals initSals_GP
        end
        fprintf('obtain the initSal ......\n')
        initSals = obtainWeakSal(INITSALS_ORI);
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear initSals INITSALS_ORI
        
        initSals = obtainWeakSal(INITSALS);% GP版的initsal
        
        fprintf('improving process ......')
        for iter=1:param.iterNum % 可以进行多次迭代
            % initInfor: frames/Flows/spInfors/Feas/INITSALS 五种,信息对应
            fprintf('forward process ...\n')
            [INITSALS_F,forwardSals] = forwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            
            fprintf('backward process ...\n')
            [INITSALS_B,backwardSals] = backwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            
            fprintf('integration ...\n')% 两种方式获得最终的显著性图，2017.03.26
% % %             SALS1 = obtainFBSal_MMI(INITSALS_F,INITSALS_B);
            SALS2 = integrateSals(initSals,forwardSals,backwardSals,frames);
            INITSALS = SALS2;
            if iter<param.iterNum
                clear SALS INITSALS
%                 clear forwardSals backwardSals SALS initSals
            end
        end
            fprintf('save ...\n')
% % %             forwardSals  = obtainWeakSal(INITSALS_F);
% % %             backwardSals = obtainWeakSal(INITSALS_B);
% % %             saveSals(SALS1,forwardSals,backwardSals,frame_names,saliencyMapPath_Our);
            save_finalSals2(SALS2,frame_names,saliencyMapPath_Our);% 2017.3.26
            
            clear INITSALS_F INITSALS_B
            clear forwardSals backwardSals SALS1 SALS2
            clear saliencyMapPath_Models initSals 
            
        clear video_data Groundtruth_path 
        clear frames frame_names Feas spInfors
end