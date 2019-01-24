%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;clc;%close all

%% 1. Initilization &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
allRootPath = ['.\videoData\'];
rootFlow    = ['.\videoData\opticalFlow\'];% ME µçÄÔ
modelPath   = ['.\videoData\salData\'];

% DatasetNames = {'SegTrackv2','UVSD','DAVIS'};
salModels = {'SGSP'}; %GD,///,'RWRV','GD','SGSP',,'CVS','GD','RWRV','CVS'


param.spnumbers = [350:50:450];%350:50:450///400
param.OB_ths    = [0.2,0.8,0];
weights = [0.3,0.7;0.2,0.8;0.1,0.9;0,1];

param.weights = weights(3,:);
TreeNums = [100];
param.num_tree = TreeNums(1);
salPath = ['.\Results\'];% single model improvement
if( ~exist( salPath, 'dir' ) )
     mkdir( salPath );
end

%% begin &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
% for ds=3:length(DatasetNames)
%     fprintf( ['DatasetName: ',DatasetNames{1,ds},'--------------------\n']);
    root_videoDataSet=[allRootPath,'IMG\'];
    videoNames = dir(root_videoDataSet);
    videoNames = videoNames(3:end);
%     DatasetName = DatasetNames{1,ds};
    
%     for gg=10:length(videoNames)
        gg=1;
        SMI_FunNew2_1(root_videoDataSet,rootFlow,modelPath,salPath, ...
                 videoNames,salModels,param,gg);
%     end
    
    clear root_videoDataSet videoNames DatasetName
% end
% end
% end
%% end &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
msgbox('welldone boy!!!')