function output = box_descriptor(im, points, descriptor_size, descriptor_resolution)
%BOX_DESCRIPTOR Summary of this function goes here
%   Detailed explanation goes here
    %% Gaussian
    % Downsample the image
    g_im = gaussian_stacks(rgb2gray(im), 4, 1.0);
    % TODO: use color?
    
    %% Resample
    sample_size = descriptor_size * descriptor_resolution / 2;
    % sample each point for a 8x8 (really 40 x 40)
    A = []; points_usable = [];
    p = 1;
    for c=1:size(points, 1)
        % Find upper left corner
        y = points(c, 1) - ceil(sample_size / 2);
        x = points(c, 2) - ceil(sample_size / 2);
        % Get the descriptor
        if 0 < y && (y+sample_size-1) < size(im, 1) && 0 < x && (x+sample_size-1) < size(im, 2)
            box = g_im(y:y+sample_size-1, x:x+sample_size-1, 2);
            % Downsize the descriptor
            box = downsample(box', descriptor_resolution);
            box = downsample(box', descriptor_resolution);
            % Normalize and store
            normal_box = (box - mean(box(:))) / std(box(:));
            A(p, :) = normal_box(:);
            points_usable(p, :) = [points(c, 1), points(c, 2)];
            p = p + 1;
        end
    end
    output = struct('descriptors', A, 'points', points_usable);
end