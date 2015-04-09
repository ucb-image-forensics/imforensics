function [ interest_points ] = get_interest_points( im, num_interest_pts )
%GET_INTEREST_POINTS Summary of this function goes here
%   Detailed explanation goes here
    % Find Harris corners
    interest_points_original = harris(im);
    interest_points = [];
    
    % Add adaptive non-maximal supression interest points
    interest_points = cat(1, interest_points, anms(interest_points_original, min(num_interest_pts, size(interest_points_original, 1)), 0.9));
    % Add highest harris corners
    interest_points = cat(1, interest_points, highest_corners(interest_points_original, min(num_interest_pts, size(interest_points_original, 1))));
    % Unique-ify the rows
    interest_points = unique(interest_points, 'rows');

    % Add orientation
    interest_points = find_orientations_opt(interest_points, im, 40);
end

