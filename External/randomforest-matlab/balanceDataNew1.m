function [outdata, outlab] = balanceDataNew1( indata, inlab, neg_lab )
% ÿ�������ȡ����������beta�������Ķ���������
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
    if length(pos_ind) < length(neg_ind)% ��������
%         length_neg_ind1 = round(beta * length(neg_ind));% ÿ�γ�ȡ�������ߵ�����

        length_neg_ind1 = round(beta * length(pos_ind));% ��������beta��
        % ��������������Ŀ����������飬��ȡǰ length_neg_ind1 ����Ϊ�²�������
        neg_ind1 = randperm(length(neg_ind));
        neg_ind1 = neg_ind1(1:length_neg_ind1);
        x = [indata(pos_ind,:); indata(neg_ind(neg_ind1), :)];
        y = [inlab(pos_ind);    inlab(neg_ind(neg_ind1))];
        
    else  % ��������
%         length_pos_ind1 = round(beta * length(pos_ind));
        length_pos_ind1 = round(beta * length(neg_ind));
        pos_ind1 = randperm(length(pos_ind));
        pos_ind1 = pos_ind1(1:length_pos_ind1);
        x = [indata(pos_ind(pos_ind1), :); indata(neg_ind, :)];
        y = [inlab(pos_ind(pos_ind1)); inlab(neg_ind)];
    end
    
    [outdata, outlab] = randomize( x, y );% ����˳��
    
    clear x y indata inlab neg_lab
end