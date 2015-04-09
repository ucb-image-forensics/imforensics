function img = convert_matches_to_image( height, width, corresponding_points )
%CONVERT_MATCHES_TO_IMAGE Summary of this function goes here
%   Detailed explanation goes here
    img = zeros(height, width);
    for i=1:size(corresponding_points.source, 1)
        source = corresponding_points.source(i,:);
        target = corresponding_points.target(i,:);
        img(target(1), target(2)) = 1;
        img(source(1), source(2)) = 1;
    end
end

