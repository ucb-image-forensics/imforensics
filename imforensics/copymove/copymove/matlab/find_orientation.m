function [ theta, magnitude ] = find_orientation(point, blur_im)
%FIND_ORIENTATION Summary of this function goes here
%   Detailed explanation goes here
%%
    % Check out: http://en.wikipedia.org/wiki/Scale-invariant_feature_transform#Orientation_assignment
    % 1) for each point in neighbor hood, find magnitude and direction
    % 2) place into buckets separated by 10 deg, weighted by magnitude and
    % a gaussian of 1.5 from key point
    % 3) get the largest magnitude angle
    x = point(1);  y = point(2);
    WINDOW_SIZE = 15;
    weights = fspecial('gaussian', WINDOW_SIZE * 2 + 1, 1.5 * 5);
    
    bins = {[],[],[],[],[],[],[],[],[],[]};
    angle_range = 0:2 * pi / 10:2*pi;
    
    for b=(-WINDOW_SIZE):(WINDOW_SIZE)
        for a=(-WINDOW_SIZE):(WINDOW_SIZE)
            i = y + a;  j = x + b;
            if is_in_im(i-1, j-1, size(blur_im, 1), size(blur_im, 2)) && is_in_im(i+1, j+1, size(blur_im, 1), size(blur_im, 2))
                % Find magnitude
                m = sqrt((blur_im(i+1, j) - blur_im(i-1, j)) ^ 2 + (blur_im(i, j+1) - blur_im(i, j-1)) ^ 2);
                % Find orientation
                theta = atan2(blur_im(i+1, j) - blur_im(i-1, j), blur_im(i, j+1) - blur_im(i, j-1));
                % Get weight
                w = weights(a + WINDOW_SIZE + 1, b + WINDOW_SIZE + 1);
                % Get bucket index
                bin_idx = find(angle_range <= mod(theta, 2*pi), 1, 'last');
                bins{bin_idx} = [bins{bin_idx}; [theta, w * m]];
            end
        end
    end
    
    % Find best orientation
    values = zeros(1, 10);
    i = 1;
    for bin=bins
        b = bin{1};
        if numel(b) > 0
            values(i) = sum(b(:,2));
        end
        i = i + 1;
    end
    [max_weight, max_idx] = max(values);
    
    % Calculate theta by weighting
    max_bin = bins{max_idx};
    total_theta = 0.0;
    for idx=1:size(max_bin, 1)
        theta = max_bin(idx, 1); w = max_bin(idx, 2);
        total_theta = total_theta + theta * w;
    end
    theta = total_theta / max_weight;
    magnitude = max_weight / size(max_bin, 1);
end