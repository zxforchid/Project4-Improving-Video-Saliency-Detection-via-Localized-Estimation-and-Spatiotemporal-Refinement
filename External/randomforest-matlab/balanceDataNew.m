% function [outdata, outlab] = balanceDataNew( indata, inlab, neg_lab)
function [outdata, outlab] = balanceDataNew( indata, inlab, beta)
% 每次随机抽样，抽样多者的2/3
% 2016.12.16 
% 
%     if nargin == 2
%         neg_lab = 0;
%     end
    
    pos_ind = find(inlab == 1);
    neg_ind = find(inlab == 0);
    
%     alpha = 1.2;
%     beta = 2/3; % 2017.3.14 21:01PM
    if length(pos_ind) < length(neg_ind)% 负样本多
        length_neg_ind1 = round(beta * length(neg_ind));% 每次抽取的样多者的数量
%         length_neg_ind1 = round(length(pos_ind)*alpha);
%         if length_neg_ind1>length(neg_ind)
%             length_neg_ind1 = length(pos_ind);
%         end
        neg_ind1 = randperm(length(neg_ind));% 随机抽样
        neg_ind1 = neg_ind1(1:length_neg_ind1);
        x = [indata(pos_ind,:); indata(neg_ind(neg_ind1), :)];
        y = [inlab(pos_ind); inlab(neg_ind(neg_ind1))];
    else  % 正样本多
        length_pos_ind1 = round(beta * length(pos_ind));
%         length_pos_ind1 = round(length(neg_ind)*alpha);
%         if length_pos_ind1>length(pos_ind)
%             length_pos_ind1 = length(neg_ind);
%         end
        pos_ind1 = randperm(length(pos_ind));% 随机抽样
        pos_ind1 = pos_ind1(1:length_pos_ind1);
        x = [indata(pos_ind(pos_ind1), :); indata(neg_ind, :)];
        y = [inlab(pos_ind(pos_ind1)); inlab(neg_ind)];
    end
    
    [outdata, outlab] = randomize( x, y );% 打乱顺序
    
    clear x y indata inlab neg_lab
end