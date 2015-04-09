function [ highest_points ] = highest_corners( interest_points, n_ip )
%HIGHEST_CORNERS Summary of this function goes here
%   Detailed explanation goes here
    interest_points = sortrows(interest_points, -3);
    highest_points = interest_points(1:n_ip, :);
end

