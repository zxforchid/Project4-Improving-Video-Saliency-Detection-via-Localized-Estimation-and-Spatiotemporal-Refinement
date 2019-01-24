function hist_result=hist_dong(data,bin_size,range,b_debug)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Add range feature to Matlab function "hist"
    %% Dong Zhang, UCF Computer Vision Lab, 6/2/2012
    %%
    %% ATTENTION!!!
    %%
    %% There's a serious problem for MATLAB's hist function!
    %%  "hist" calculate histgrams within the range of the input data,
    %% however, usually we need the histgram for images in the range of [0,255].
    %% It may cause serious error if two regions are of similar color hisgrams
    %% but use MATLAB function. e.g. two data [1 2 3 4], [1 2 3 4 255] are actually
    %% similar, but if use MATLAB "hist" function, the hists are totally dissimilar!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Dong Zhang, Center for Research in Computer Vision, UCF 1/10/2014
    %% Copyright (2014), UCF CRCV
    
    data=double(data);
    
    if nargin<3
        range=[0 255];
        b_debug=0;
    end
    if nargin==0
        data=[1 2 3 4];
        bin_size=30;
        b_debug=1;
    end
    
    if size(data,1)==1
        data=data';
    end
    data=[data;
        repmat(range(1),[1 size(data,2)]);
        repmat(range(2),[1 size(data,2)])];
    hist_temp=hist(data,bin_size);
    hist_temp(1)=hist_temp(1)-1;
    hist_temp(end)=hist_temp(end)-1;
    hist_result=hist_temp;
    if b_debug
        close all;
        bar(hist_result);
    end