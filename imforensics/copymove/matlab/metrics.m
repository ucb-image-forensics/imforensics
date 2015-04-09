function [num_points, frac_points] = metrics(mask, matches)

src_points = matches.source;
target_points = matches.target;
[n, ~] = size(target_points);

% Number of points in the mask
num_points = 0;
for i = 1:n
    point = src_points(i,:);
    x = point(2);
    y = point(1);
    if mask(y,x) > 0
        num_points = num_points+1;
    end
    point = target_points(i,:);
    x = point(2);
    y = point(1);
    if mask(y,x) > 0
        num_points = num_points+1;
    end
end

% Percentage of the points in the mask
frac_points = num_points/n;

end

