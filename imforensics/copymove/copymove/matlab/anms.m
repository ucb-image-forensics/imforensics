function [I_r] = anms(I, n_ip, c_robust)
%ANMS Summary of this function goes here
%   Detailed explanation goes here
    % Sort by descending values
    I = sortrows(I, -3); 
    R = zeros(size(I, 1), 1);
    for i=1:size(I, 1)
         f_xi = I(i, 3);
         [indices, values] = find(f_xi < I(1:i, 3) * c_robust);
         I_j = I(indices, :);
         if numel(I_j) > 0
             y = I(i, 1);  x = I(i, 2);
             ys = (y - I_j(:, 1)) .^ 2;
             xs = (x - I_j(:, 2)) .^ 2;
             R(i) = min(sqrt(ys + xs));
         else
             R(i) = -1;
         end
     end
     I_r = cat(2, I, R);
     I_r = sortrows(I_r, -4);
     I_r = I_r(1:n_ip, 1:3);
end