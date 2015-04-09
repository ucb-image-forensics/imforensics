function output = nn_outlier_rejection(descriptors1, descriptors2, nn_threshold)
%NN_OUTLIER_REJECTION Summary of this function goes here
%   Detailed explanation goes here
    % For matching descriptors of 1 to descriptors of 2
    distances = dist2(descriptors1.descriptors, descriptors2.descriptors);
   
    % don't allow matches on same pixels
    for i=1:size(distances, 1)
        distances(i, i) = Inf;
    end
    
    % Proceed with matching
    corresponding1 = []; corresponding2 = [];
    c = 1;

    for i=1:size(distances, 1)
        ds = distances(i, :);
        nn1 = min(ds);
        matching_indices = find(ds == nn1);
        % If only one match, just look for 
        j = matching_indices(1);
        if i <= j
            if numel(matching_indices) == 1
                ds(matching_indices) = []; % delete the row so we can find th next min
                nn2 = min(ds);
                if (nn1 / nn2) < nn_threshold
                    % Keep this point if lower than threshold
                    corresponding1(c, :) = descriptors1.points(i, :);
                    corresponding2(c, :) = descriptors2.points(j, :);
                    c = c + 1;
                end
            else
                % If more than one, see if the threshold is 1.0
                if 1.0 <= nn_threshold
                    % We would want to keep this point
                    corresponding1(c, :) = descriptors1.points(i, :);
                    corresponding2(c, :) = descriptors2.points(j, :);
                    c = c + 1;
                end
            end
        end
    end
    
    % we need to return correspondences
    output = struct('source', corresponding1, 'target', corresponding2);
end

