function [initSals,Flows] = obtainInitSal_Flows(OPTICALFLOW,frame_names,saliencyMapPath)
%% 获取全部initSal & optical flow &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
initSals = cell(1,length(frame_names)-1);
Flows = cell(1,length(frame_names)-1);
for f = 1:(length(frame_names)-1) 
     tmpInitSal = imread([saliencyMapPath,frame_names{1,f}(1:end-4),'_init.png']);
     tmpInitSal = normalizeSal(tmpInitSal);
     initSals{1,f} = tmpInitSal;
     clear tmpInitSal
     
     load ([OPTICALFLOW,'opf_',num2str(f),'.mat'],'MVF_Foward_f_fp')
     Flows{1,f} = MVF_Foward_f_fp;
     clear MVF_Foward_f_fp
end
clear OPTICALFLOW frame_names saliencyMapPath

end