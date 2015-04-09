function h = plot_matches( im, corresponding_points)
%PLOT_MATCHES Summary of this function goes here
%   Detailed explanation goes here
    h = figure;
    imshow(im);
    axis image; hold on;
    for i=1:size(corresponding_points.source, 1)
        ll = cat(1, corresponding_points.source(i,:), corresponding_points.target(i,:));
        plot(ll(:,2), ll(:,1), 'y-');
        plot(corresponding_points.source(i,2), corresponding_points.source(i,1), 'ro');
        plot(corresponding_points.target(i,2), corresponding_points.target(i,1), 'bo');
    end
    hold off;
end