function result = featureExtract2(lowFea,spinfor,param)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% featureExtract
% 特征提取第一段之 mid level feature
% lowFea 表示低层次特征
% V1： 2016.07.20
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spnum = length(spinfor);
lfnum = length(lowFea);% 每一个lowlevel feature 是 12*8maps
gbscales = param.gbscales;
gborient = param.gborient;

[NO,NS] = size(lowFea{1,1});

result = cell(spnum,1);
for ss=1:spnum % 每个尺度下
    tmpSP = spinfor{ss,1};
    LLDS = [];
    for ll=1:lfnum % 每个lowlevel feature下 L A B 
        tmpLF = lowFea{1,ll};        
        GODS = [];
        for go=1:NO % 每个gb方向下  
            GSDS = [];
            for gs=1:2:NS% 每个gb 尺度下（相邻尺度处理机制）
                tmpOS1 = tmpLF{go,gs};
                tmpOS2 = tmpLF{go,gs+1}; 
                
                % 构建像素级的特征表示用于 COV提取
                cs1 = COVSEED(tmpOS1);
                cs2 = COVSEED(tmpOS2);
                
                % region covariance COV
                SGM1 = COVSIGMA(cs1,tmpSP.idxcurrImage,tmpSP.spNum);
                SGM2 = COVSIGMA(cs2,tmpSP.idxcurrImage,tmpSP.spNum);
                
                % 同一尺度下，对应区域的difference/similarity
                % revised in 2016.08.17 16:01PM 
                % 利用指数函数构造相似性度量
                CRSDist = sum(((SGM1-SGM2).^2),2);
                CRSDist = exp(-CRSDist);% 2*delta^2=1
                GSDS = [GSDS, CRSDist];
                clear CRSDist
            end
            GODS = [GODS,GSDS];
            clear GSDS
        end
        LLDS = [LLDS,GODS];
        clear GODS
    end
    
    result{ss,1} = LLDS;
    
    clear LLDS
end

%% clear variables
clear lowFea spinfor
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lowFea{1,1} = fmL;
% lowFea{1,2} = fma;
% lowFea{1,3} = fmb;
% spinfor{ss}.idxcurrImage = idxcurrImage;
% spinfor{ss}.adjmat = adjmat;
% spinfor{ss}.pixelList =pixelList;
% spinfor{ss}.area = area;
% spinfor{ss}.spNum = spNum;