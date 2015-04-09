function output = is_in_im(i, j, h, w)
%IS_IN_IM Summary of this function goes here
%   Detailed explanation goes here
    output = ~(i > h || j > w || i < 1 || j < 1);
end

