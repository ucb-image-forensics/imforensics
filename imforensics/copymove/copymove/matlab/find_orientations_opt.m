function [ results ] = find_orientations_opt( query_points, im , w )
%FIND_ORIENTATIONS_OPT Summary of this function goes here
%   Detailed explanation goes here
    start_time = cputime;
    %%
    pts = cat(2, query_points(:,2), query_points(:,1));
    [features, validPoints] = extractHOGFeatures(im, pts, 'CellSize', [35 35], 'BlockSize', [1 1]);
    
    % Generate the angles
    results = [];
    ref_angles = (0:8) .* (pi / 9 * ones(1, 9));
    
    for idx=1:size(validPoints, 1)
        x = validPoints(idx, 1); y = validPoints(idx, 2);
        max_angle = max(features(idx, :));
        [R, C] = find(0.95 * max_angle < features(idx, :));
        if size(C, 2) <= 4
            for jdx=1:size(C, 2)
                f_idx = C(jdx);
                angle = ref_angles(f_idx);
                results = [results; y, x, angle;];
            end
        else
            results = [results; y, x, ref_angles(C(1,1));];
        end
    end
    display(cputime - start_time);
end

