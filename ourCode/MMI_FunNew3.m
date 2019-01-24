function MMI_FunNew3(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ���� co-map ����ʽ�ڶ�ģ��֮�ں�
% 2017.03.27 20:21PM
% ���� co-sample ��������
% 2017.03.28 9:06AM
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
        
%         initSals = obtainWeakSal(INITSALS);% GP���initsal
        
        fprintf('improving process ......')
        for iter=1:param.iterNum % ���Խ��ж�ε���
            % initInfor: frames/Flows/spInfors/Feas/INITSALS ����,��Ϣ��Ӧ
            fprintf('forward process ...\n')
            [INITSALS_F,forwardSals] = forwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            
            fprintf('backward process ...\n')
            [INITSALS_B,backwardSals] = backwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            clear INITSALS
            
            fprintf('integration ...\n')
            % ���ڵ�ǰ֡�ĸ�ģ�Ͷ�Ӧ��������ͼ�����ںϣ���ʱ��IINITSALS��Ȼ�� 1*modelNum/ 1*frameNum
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