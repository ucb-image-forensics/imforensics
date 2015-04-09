function [ results ] = find_orientations( query_points, im , window_size)
%FIND_ORIENTATIONS Summary of this function goes here
%   STRONG ASSUMPTION: Every query point of x +/- 1 and y +/- 1 are valid!!

    window_size = ceil(window_size / 2);
    %% Initialization
    disp('Finding orientations..');
    % Note: Should try window size of 15 first
    thetas = [];
    L = gaussian_stacks(im2double(rgb2gray(im)), 2, 4.0);
    h = size(L, 1);  w = size(L, 2);
    W = fspecial('gaussian', window_size * 2 + 1, 1.5 * 5);
    angle_range = 0:2*pi/10:2*pi;
    
    %% Find magnitude of every pixel in image
    M = sqrt((L(1+1:h-1,1+2:w) - L(1+1:h-1, 1:w-2)) .^ 2 + (L(1+2:h, 1+1:w-1) - L(1:h-2,1+1:w-1)) .^ 2);
    %% Find angle of every pixel in image
    A = mod(atan2(L(1+2:h, 1+1:w-1) - L(1:h-2,1+1:w-1), L(1+1:h-1,1+2:w) - L(1+1:h-1, 1:w-2)), 2 * pi);
    %% Iterate through each point
    results = [];
    additional_orientations_added = 0;
    for idx=1:size(query_points, 1)
        y = query_points(idx, 1);
        x = query_points(idx, 2);
        % Check if point is within our magnitude and angle images
        if is_in_im(y - window_size - 1, x - window_size - 1, h-2, w-2) && is_in_im(y + window_size - 1, x + window_size - 1, h-2, w-2) 
            weights = W .* M(y - 1 - window_size: y - 1 + window_size, x - 1 - window_size: x - 1 + window_size);
            T = A(y - 1 - window_size: y - 1 + window_size, x - 1 - window_size: x - 1 + window_size);
            bins = {[],[],[],[],[],[],[],[],[],[]};
            % Place into bins
            for sidx=1:numel(weights)
                theta = T(sidx);  weight = weights(sidx);
                bin_idx = find(angle_range <= theta, 1, 'last');
                bins{bin_idx} = [bins{bin_idx}; [theta, weight]];
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
            
            % Calculate new theta from weighting
            max_bin = bins{max_idx};
            new_theta = sum(max_bin(:, 1) .* max_bin(:, 2)) / max_weight;
            magnitude = max_weight / size(max_bin, 1);
            % What the results look like
            results = [results; [y, x, new_theta, magnitude]];
            
            % Add maximas that are close
            local_maximas = find(values >= 0.8 * max_weight);
            for lidx=1:size(local_maximas, 2)
                if lidx ~= max_idx
                    bin = bins{local_maximas(lidx)};
                    weight = values(lidx);
                    new_theta = sum(bin(:, 1) .* bin(:, 2)) / weight;
                    magnitude = weight / size(bin, 1);
                    results = [results; [y, x, new_theta, magnitude]];
                    additional_orientations_added = additional_orientations_added + 1;
                end
            end            
        end
    end
    disp(strcat('Number of additional orientations added: ', num2str(additional_orientations_added)));
end