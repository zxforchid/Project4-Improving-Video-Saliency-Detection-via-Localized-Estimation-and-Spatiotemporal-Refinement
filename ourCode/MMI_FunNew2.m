function MMI_FunNew2(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ���� co-map ����ʽ�ڶ�ģ��֮�ں�
% 2017.03.27 20:21PM
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        
        initSals = obtainWeakSal(INITSALS);% GP���initsal
        clear INITSALS
        
        fprintf('improving process ......')
        for iter=1:param.iterNum % ���Խ��ж�ε���
            % initInfor: frames/Flows/spInfors/Feas/initSals ����
            fprintf('forward process ...\n')
            [initSalsF, forwardSals] = forwardProcess1_New(frames,spInfors,Feas,initSals,param);
            
            fprintf('backward process ...\n')
            [initSalsB, backwardSals] = backwardProcess1_New(frames,spInfors,Feas,initSals,param);
            
            fprintf('integration ...\n')
% % %             SALS1 = obtainFBSal_SMI(initSalsF,initSalsB);
            SALS2 = integrateSals(initSals,forwardSals,backwardSals,frames);
            initSals = SALS2;

            save_finalSals2_New(SALS2,frame_names,saliencyMapPath_Our,iter);% 2017.3.27  20:46PM
            
            clear forwardSals backwardSals SALS2

        end
            fprintf('save ...\n')
% % %             forwardSals  = obtainWeakSal(INITSALS_F);
% % %             backwardSals = obtainWeakSal(INITSALS_B);
% % %             saveSals(SALS1,forwardSals,backwardSals,frame_names,saliencyMapPath_Our);
%             save_finalSals2(SALS2,frame_names,saliencyMapPath_Our);% 2017.3.26
            
            clear INITSALS_F INITSALS_B
            clear forwardSals backwardSals SALS1 SALS2
            clear saliencyMapPath_Models initSals 
            
        clear video_data Groundtruth_path 
        clear frames frame_names Feas spInfors
end