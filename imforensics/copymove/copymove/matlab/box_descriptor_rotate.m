function output = box_descriptor_rotate(im, points, descriptor_size, descriptor_resolution)
%BOX_DESCRIPTOR Summary of this function goes here
%   Detailed explanation goes here
    %% Gaussian
    % Downsample the image
    g_im = gaussian_stacks(rgb2gray(im), 5, 1.0);
    % TODO: use color?
    
    %% Resample
    sample_size = descriptor_size * descriptor_resolution / 2;
    % sample each point for a 8x8 (really 40 x 40)
    A = []; points_usable = [];
    p = 1;
    for c=1:size(points, 1)
        % Find upper left corner
        y = points(c, 1);
        x = points(c, 2);
        theta = points(c, 3);
        box = get_rotated_image(y, x, theta, g_im(:,:,2), sample_size);
        box = downsample(box', descriptor_resolution);
        box = downsample(box', descriptor_resolution);
        normal_box = (box - mean(box(:))) / std(box(:));
        A(p, :) = normal_box(:);
        points_usable(p, :) = [y, x];
        p = p + 1;
    end
    output = struct('descriptors', A, 'points', points_usable);
end