function labelInfor = labelExtract1(gt,spinfor,OBTHS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 提取标签（各尺度下各区域对应的标签）
% 用于 bootstrap 二次训练
% 2017.03.01  19:16PM
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
objIndex = find(gt(:)==1);

OB_THL = OBTHS(3);% 0 注意区别！！！
OB_THH = OBTHS(2);% 0.8

SPSCALENUM = length(spinfor);
labelInfor = cell(SPSCALENUM,1);

for ss=1:SPSCALENUM % 每个尺度下
    tmpSP = spinfor{ss,1};
    
    ISOBJ=[];
    for sp=1:tmpSP.spNum % 各区域
        TMP = find(tmpSP.idxcurrImage==sp);
        
        % 1、判断是否在Object中 1/0
        if isempty(objIndex)
            ISOBJ = [ISOBJ;100];  
        else
            indSP_GT = ismember(TMP,objIndex);
            ratio_GT = sum(indSP_GT)/length(indSP_GT);
            
            % revised in 2016.10.12 20:25PM
            if ratio_GT<=OB_THL  % 无交集或者交集小于等于0.2 or 0（即大于等于0.8），背景
               ISOBJ = [ISOBJ;0];
            end
            if ratio_GT>=OB_THH  % 有交集且大于等于0.8，前景
               ISOBJ = [ISOBJ;1];
            end
            if ratio_GT>OB_THL && ratio_GT<OB_THH %有交集，介于0.2~0.8之间
               ISOBJ = [ISOBJ;50];
            end
        end

        
    end
    labelInfor{ss,1} = ISOBJ;
    clear tmpSP
end

clear  objIndex spinfor gt

end