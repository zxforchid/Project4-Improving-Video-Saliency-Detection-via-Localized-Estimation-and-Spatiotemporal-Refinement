function INITSALS = weak_strong_fusionNew(INITSALS,f,strongSal)
% 用于更新各模型的初始显著性图
% 2017.03.24  20:29PM
% 
% sal=normalizeSal(weakSal*0.3+strongSal*0.7);
% sal=normalizeSal(weakSal+strongSal);
% clear weakSal strongSal


modelNum = length(INITSALS);
for mm=1:modelNum
    initSals = INITSALS{1,mm};
    weakSal = initSals{1,f};
%     initSals{1,f} = normalizeSal(weakSal+strongSal);
    initSals{1,f} = normalizeSal(0.3*weakSal+0.7*strongSal);
    INITSALS{1,mm} = initSals;
    clear initSals weakSal
end


end