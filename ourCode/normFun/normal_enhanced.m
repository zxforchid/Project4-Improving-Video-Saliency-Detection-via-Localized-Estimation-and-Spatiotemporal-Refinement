function  result = normal_enhanced(sp_sal_prob)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 首先做一次归一化
% 接着做enhance
% 最后再做一次归一化
% 07/15/2014
% xiaofei zhou,shanghai university
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 归一化
% sp_sal_prob = (sp_sal_prob - min(sp_sal_prob(:))) /...
%       (max(sp_sal_prob(:)) - min(sp_sal_prob(:)) + eps);
   
alpha = 1.25;

% enhanced
sp_sal_prob = exp( alpha * sp_sal_prob );
% sp_sal_prob = exp( sp_sal_prob );
% 归一化
if max(sp_sal_prob(:)) == min(sp_sal_prob(:))% 防止数据过小
    result=(sp_sal_prob-min(sp_sal_prob(:)))/(max(sp_sal_prob(:))-min(sp_sal_prob(:))+eps);
else
    result=(sp_sal_prob-min(sp_sal_prob(:)))/(max(sp_sal_prob(:))-min(sp_sal_prob(:)));
end


clear sp_sal_prob

end