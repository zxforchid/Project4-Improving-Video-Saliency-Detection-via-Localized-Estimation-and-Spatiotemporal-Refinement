function  result = normal_enhanced(sp_sal_prob)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ������һ�ι�һ��
% ������enhance
% �������һ�ι�һ��
% 07/15/2014
% xiaofei zhou,shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��һ��
% sp_sal_prob = (sp_sal_prob - min(sp_sal_prob(:))) /...
%       (max(sp_sal_prob(:)) - min(sp_sal_prob(:)) + eps);
   
alpha = 1.25;

% enhanced
sp_sal_prob = exp( alpha * sp_sal_prob );
% sp_sal_prob = exp( sp_sal_prob );
% ��һ��
if max(sp_sal_prob(:)) == min(sp_sal_prob(:))% ��ֹ���ݹ�С
    result=(sp_sal_prob-min(sp_sal_prob(:)))/(max(sp_sal_prob(:))-min(sp_sal_prob(:))+eps);
else
    result=(sp_sal_prob-min(sp_sal_prob(:)))/(max(sp_sal_prob(:))-min(sp_sal_prob(:)));
end


clear sp_sal_prob

end