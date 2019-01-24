function MMI_Fun(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
        fprintf( ['VideoName: ',videoNames(gg).name,'............\n']);
        video_data=[root_videoDataSet,videoNames(gg).name,'\'];
        OPTICALFLOW=[rootFlow,DatasetName,'\',videoNames(gg).name,'\'];
       
        fprintf('obtain the initial information ......\n')
        [frames,frame_names,Feas,Flows,spInfors] =  ...
                             obtainInitInfor2(video_data,OPTICALFLOW,param);
        clear Flows
        
        % ���ɱ����ļ�
        saliencyMapPath_Our =...
              [salPath,DatasetName,'\',videoNames(gg).name,'\'];
        if( ~exist( saliencyMapPath_Our, 'dir' ) )
            mkdir( saliencyMapPath_Our );
        end       
        
        fprintf('obtain modelSals ......\n')% ��4��ģ�ͣ�'SGSP','GD','CVS','RWRV'
        INITSALS = cell(1,length(salModels));
        for vv=1:length(salModels)
            saliencyMapPath_Models = ...
                [modelPath,DatasetName,'\',salModels{vv},'\',videoNames(gg).name,'\'];
            [initSals] = obtainInitSal2(frame_names,saliencyMapPath_Models,frames);
            INITSALS{1,vv} = initSals;
            clear initSals
        end
        fprintf('obtain the initSal ......\n')
        initSals = obtainWeakSal(INITSALS);
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear INITSALS
        
        fprintf('improving process ......')
        for iter=1:param.iterNum % ���Խ��ж�ε���
            % initInfor: frames/Flows/spInfors/Feas/INITSALS ����,��Ϣ��Ӧ
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

        clear video_data Groundtruth_path 

end