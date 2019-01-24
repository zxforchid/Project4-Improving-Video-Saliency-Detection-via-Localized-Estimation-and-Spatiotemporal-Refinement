function [outdata, outlab] = balanceDataNew1( indata, inlab, neg_lab )
% 每次随机抽取少数类样本beta倍数量的多数类样本
% 2017.03.01
% 
    if nargin == 2
        neg_lab = 0;
    end
    
    pos_ind = find(inlab == 1);
    neg_ind = find(inlab == neg_lab);
    
%     alpha = 1.2;
%     beta = 2/3;
    beta = 1.5;
    if length(pos_ind) < length(neg_ind)% 负样本多
%         length_neg_ind1 = round(beta * length(neg_ind));% 每次抽取的样多者的数量

        length_neg_ind1 = round(beta * length(pos_ind));% 正样本的beta倍
        % 将负样本的总数目构成随机数组，提取前 length_neg_ind1 个作为下采样数据
        neg_ind1 = randperm(length(neg_ind));
        neg_ind1 = neg_ind1(1:length_neg_ind1);
        x = [indata(pos_ind,:); indata(neg_ind(neg_ind1), :)];
        y = [inlab(pos_ind);    inlab(neg_ind(neg_ind1))];
        
    else  % 正样本多
%         length_pos_ind1 = round(beta * length(pos_ind));
        length_pos_ind1 = round(beta * length(neg_ind));
        pos_ind1 = randperm(length(pos_ind));
        pos_ind1 = pos_ind1(1:length_pos_ind1);
        x = [indata(pos_ind(pos_ind1), :); indata(neg_ind, :)];
        y = [inlab(pos_ind(pos_ind1)); inlab(neg_ind)];
    end
    
    [outdata, outlab] = randomize( x, y );% 打乱顺序
    
    clear x y indata inlab neg_lab
end