function MMI_FunNew4_1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ���� co-map ����ʽ�ڶ�ģ��֮�ں�
% 2017.03.27 20:21PM
% ������zhouzhihua�Ĺ�����������co-map����ʽ�����ں� 
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
            INITSALS_ORI{1,vv} = initSals;
            INITSALS{1,vv} = initSals_GP;
            clear initSals initSals_GP
        end
        fprintf('obtain the initSal ......\n')
        initSals = obtainWeakSal(INITSALS_ORI);% δ����gpϸ������ԭʼ��ƽ�����
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear initSals INITSALS_ORI
        
        initSals = obtainWeakSal(INITSALS);% GP���initsal�����ں�����improve
        clear INITSALS
        
        fprintf('improving process ......')
%             for iter=1:param.iterNum % ���Խ��ж�ε���
            % initInfor: frames/Flows/spInfors/Feas/initSals ����
            fprintf('forward process ...\n')
            [initSalsF] = forwardProcess1_New(frames,spInfors,Feas,initSals,param);
            
            fprintf('backward process ...\n')
            [initSalsB] = backwardProcess1_New(frames,spInfors,Feas,initSals,param);
            
            fprintf('integration ...\n')% ���ֲ�ͬ���ںϷ�ʽ
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