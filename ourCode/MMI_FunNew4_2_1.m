function MMI_FunNew4_2_1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 全新框架，集体训练测试而不是一帧帧的训练测试
% 2017.03.24 16::42PM
% 采用 co-map 的形式于多模型之融合
% 2017.03.27 20:21PM
% 采用 co-sample 迭代策略
% 2017.03.28 9:06AM
% 引入了zhouzhihua的工作，并采用 co-sample 的形式进行融合 
% 2017.03.29 14:51PM
% 对于长视频帧序列，边运行变保存，以节省空间
% 2017.04.03 13:35PM
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
        initSals = obtainWeakSal(INITSALS_ORI);% 未进行gp细化，最原始的平均结果
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear initSals INITSALS_ORI
        
        initSals = obtainWeakSal(INITSALS);% GP版的initsal,用于后续融合
        
        fprintf('improving process ......')
%         for iter=1:param.iterNum % 可以进行多次迭代
            % initInfor: frames/Flows/spInfors/Feas/INITSALS 五种,信息对应          
            fprintf('forward process ...\n')
            [INITSALS_F,~] = forwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            INITSALS_F_SAL = obtainWeakSal(INITSALS_F);
            save_Sals_New(INITSALS_F_SAL,frame_names,saliencyMapPath_Our,'_foreward.png')
            clear INITSALS_F_SAL
            
            
            fprintf('backward process New ...\n')% 边运行 边保存
            [~,~] = backwardProcess1_New1_1(frames,spInfors, ...
                         Feas,INITSALS,INITSALS_F,param,frame_names,saliencyMapPath_Our);
            clear INITSALS_F
            
%             fprintf('backward process ...\n')
%             [INITSALS_B,backwardSals] = backwardProcess1_New1(frames,spInfors,Feas,INITSALS,param); 
            
%             INITSALS_F_SAL = obtainWeakSal(INITSALS_F);
            clear INITSALS
            fprintf('integration ...\n')
            % 对于当前帧的各模型对应的显著性图进行融合，此时的IINITSALS依然是 1*modelNum/ 1*frameNum
            % 两种融合方式
% %             INITSALS_F_SAL = obtainWeakSal(INITSALS_F);
% %             INITSALS_B_SAL = obtainWeakSal(INITSALS_B);
% %             INITSALS = obtainFBSal_MMI3(INITSALS_F,INITSALS_B);% 1*modelNum/1*frameNum
% %             SALS1 = obtainWeakSal(INITSALS);% 1*frameNum
%             SALS2 = integrateSals(initSals,forwardSals,backwardSals);

            clear forwardSals backwardSals initSals
%         end
            fprintf('save ...\n')
% %             saveSals(SALS1,INITSALS_F_SAL,INITSALS_B_SAL,frame_names,saliencyMapPath_Our);
%             save_finalSals2(SALS2,frame_names,saliencyMapPath_Our);% 2017.3.26
            
            clear initSalsF initSalsB SALS1 SALS2
            clear saliencyMapPath_Models initSals 
%             clear frames frame_names Feas initSals spInfors
            
        clear video_data Groundtruth_path 
        clear frames frame_names Feas spInfors
end