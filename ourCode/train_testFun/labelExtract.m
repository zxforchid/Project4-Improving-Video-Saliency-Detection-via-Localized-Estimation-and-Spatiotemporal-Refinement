function labelInfor = labelExtract(gt,spinfor,OBTHS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ��ǩ�����߶��¸������Ӧ�ı�ǩ��
% gt      ��ǰ֡��Ӧ��GT
% spinfor ��ǰ֡��Ӧ�Ķ�߶ȷָ���
% OBTHS   ѡȡ�����Ĳ���
% 100 �޶��� 50 ģ�������� 1 �������� 0 ������
% 2017.02.28  16:40PM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
objIndex = find(gt(:)==1);

OB_THL = OBTHS(1);
OB_THH = OBTHS(2);

SPSCALENUM = length(spinfor);
labelInfor = cell(SPSCALENUM,1);

for ss=1:SPSCALENUM % ÿ���߶���
    tmpSP = spinfor{ss,1};
    
    ISOBJ=[];
    for sp=1:tmpSP.spNum % ������
        TMP = find(tmpSP.idxcurrImage==sp);
        
        % 1���ж��Ƿ���Object�� 1/0
        if isempty(objIndex)
            ISOBJ = [ISOBJ;100];  
        else
            indSP_GT = ismember(TMP,objIndex);
            ratio_GT = sum(indSP_GT)/length(indSP_GT);
            
            % revised in 2016.10.12 20:25PM
            if ratio_GT<=OB_THL  % �޽������߽���С�ڵ���0.2 or 0�������ڵ���0.8��������
               ISOBJ = [ISOBJ;0];
            end
            if ratio_GT>=OB_THH  % �н����Ҵ��ڵ���0.8��ǰ��
               ISOBJ = [ISOBJ;1];
            end
            if ratio_GT>OB_THL && ratio_GT<OB_THH %�н���������0.2~0.8֮��
               ISOBJ = [ISOBJ;50];
            end
        end

        
    end
    labelInfor{ss,1} = ISOBJ;
    clear tmpSP
end

clear  objIndex spinfor gt

end