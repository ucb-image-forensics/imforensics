function output = ransac_le_means(matches, iters, error_threshold )
%RANSAC_LE_MEANS Summary of this function goes here
%   Detailed explanation goes here
    error_threshold = error_threshold ^ 2;
    O = ones(size(matches.source, 1), 1);
    sources = [];
    targets = [];
    for k=1:5
        display('Iterating over one ransac iteration...');
        if size(matches.source, 1) >= 8
            matches = partition_matches(matches);
            M = ransac_le_means_single(matches, iters, error_threshold);
            sources = [sources; M.source;];
            targets = [targets; M.target;];
            matches.source(M.indices, :) = [];
            matches.target(M.indices, :) = [];
        end
    end
    
    output = struct('source', sources, 'target', targets);
    output = unique_matches(partition_matches(unique_matches(output)));
end