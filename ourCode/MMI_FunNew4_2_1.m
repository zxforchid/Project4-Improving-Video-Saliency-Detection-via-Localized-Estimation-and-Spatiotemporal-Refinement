function MMI_FunNew4_2_1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 DatasetName, videoNames,salModels,param,gg)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ȫ�¿�ܣ�����ѵ�����Զ�����һ֡֡��ѵ������
% 2017.03.24 16::42PM
% ���� co-map ����ʽ�ڶ�ģ��֮�ں�
% 2017.03.27 20:21PM
% ���� co-sample ��������
% 2017.03.28 9:06AM
% ������zhouzhihua�Ĺ����������� co-sample ����ʽ�����ں� 
% 2017.03.29 14:51PM
% ���ڳ���Ƶ֡���У������б䱣�棬�Խ�ʡ�ռ�
% 2017.04.03 13:35PM
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
        initSals = obtainWeakSal(INITSALS_ORI);% δ����gpϸ������ԭʼ��ƽ�����
        save_initSals(initSals,frame_names,saliencyMapPath_Our);
        clear initSals INITSALS_ORI
        
        initSals = obtainWeakSal(INITSALS);% GP���initsal,���ں����ں�
        
        fprintf('improving process ......')
%         for iter=1:param.iterNum % ���Խ��ж�ε���
            % initInfor: frames/Flows/spInfors/Feas/INITSALS ����,��Ϣ��Ӧ          
            fprintf('forward process ...\n')
            [INITSALS_F,~] = forwardProcess1_New1(frames,spInfors,Feas,INITSALS,param);
            INITSALS_F_SAL = obtainWeakSal(INITSALS_F);
            save_Sals_New(INITSALS_F_SAL,frame_names,saliencyMapPath_Our,'_foreward.png')
            clear INITSALS_F_SAL
            
            
            fprintf('backward process New ...\n')% ������ �߱���
            [~,~] = backwardProcess1_New1_1(frames,spInfors, ...
                         Feas,INITSALS,INITSALS_F,param,frame_names,saliencyMapPath_Our);
            clear INITSALS_F
            
%             fprintf('backward process ...\n')
%             [INITSALS_B,backwardSals] = backwardProcess1_New1(frames,spInfors,Feas,INITSALS,param); 
            
%             INITSALS_F_SAL = obtainWeakSal(INITSALS_F);
            clear INITSALS
            fprintf('integration ...\n')
            % ���ڵ�ǰ֡�ĸ�ģ�Ͷ�Ӧ��������ͼ�����ںϣ���ʱ��IINITSALS��Ȼ�� 1*modelNum/ 1*frameNum
            % �����ںϷ�ʽ
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