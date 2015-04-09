function [ r_im ] = get_rotated_image(y, x, theta, full_im, window_size)
%GET_ROTATED_IMAGE Summary of this function goes here
%   Detailed explanation goes here
    A = [cos(theta), -sin(theta); sin(theta) cos(theta);];
    [DX, DY] = meshgrid(-window_size:window_size, -window_size:window_size);
    query_points = cat(1, DX(:)', DY(:)');
    source_points = A * query_points;
    sX = x + source_points(1,:); sY = y + source_points(2,:);
    r_im = interp2(full_im, sX, sY);
    r_im = reshape(r_im, [window_size * 2 + 1, window_size * 2 + 1]);
end

