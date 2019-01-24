function sigmapoints = COVSIGMA(G,idxcurrImage,spNum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COV��������ȡ����������
% G COVSEED��� (height*width)*size(F,3)
% idxcurrImage �����طָ���ͼ
% spNum �����طָ��������
%
% V1�� 2016.07.20
%
% Copyright by xiaofei zhou, IVPLab, shanghai univeristy,shanghai, china
% http://www.ivp.shu.edu.cn
% email: zxforchid@163.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigmapoints = [];
NNN = size(G,2);
for sp=1:spNum
    Ind = find(idxcurrImage==sp); 
     
    if isnan(cov(G(Ind,:)))
        cov1 = 0.001*eye(NNN);
    else
        cov1 = cov(G(Ind,:)) + 0.001*eye(NNN); % Add very small values to diagonal entries
    end                                              % in order to cope with homogeneous regions
    
    m = mean(G(Ind,:));
    covC = cov1;
    covC = 2.0*(size(covC,1)+0.1)*covC;
    L = chol(covC);
    
    li = L(:);
    for k=1:NNN*NNN
        li(k) = li(k)+m(mod(k-1,NNN)+1);
    end
    lj = L(:);
    for k=1:NNN*NNN
        lj(k) = m(mod(k-1,NNN)+1)-lj(k);
    end
    resRef = [m li' lj'];
%     currImgsigmapoints(sp,:) = resRef; 
    sigmapoints = [sigmapoints;resRef];
    clear resRef m L
    
end


clear  G idxcurrImage spNum
end