function [ims segmentation_ims_GT image_names]=readAllFrames_Li(dataset_path,groundTruth_path)
    %% Read Frames

    image_list=dir(dataset_path);
    image_names={};
    for image_index=1:length(image_list)
        if ~strcmp(image_list(image_index).name,'.')...
                &&~strcmp(image_list(image_index).name,'..')...
                &&(strcmp(image_list(image_index).name(end-2:end),'bmp')...
                ||strcmp(image_list(image_index).name(end-2:end),'png')...
                ||strcmp(image_list(image_index).name(end-2:end),'jpg'))
                  image_names{length(image_names)+1}=image_list(image_index).name;
        end
        preName = image_list(image_index).name;
    end
    image_names=sort(image_names);
    ims={};
    segmentation_ims_GT={};
    for image_index=1:length(image_names)
        ims{image_index}=imread([dataset_path image_names{image_index}]);     
        single_groundTruth_path=[groundTruth_path ,'\', image_names{image_index}(1:end-3) 'png'];
%         single_groundTruth_path=[groundTruth_path,'\',sprintf('%02d.png',image_index)];
        if exist(single_groundTruth_path)
            im_groundTruth=im2double(imread(single_groundTruth_path));
            im_groundTruth=im_groundTruth(:,:,1);
            segmentation_ims_GT{image_index}=im_groundTruth;
        end
    end
    
end