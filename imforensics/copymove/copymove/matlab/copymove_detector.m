function output = copymove_detector( image_path )
%COPYMOVE_DETECTOR Summary of this function goes here
%   Detailed explanation goes here
    % LOAD IMAGE
    im = im2single(imread(image_path));
    [h, w, d] = size(im);
    start_time = cputime;
    
    %% Resize
    if w > 1500
        disp('Resizing..');
        resize_factor = 1500 / w;
        im = imresize(im, resize_factor);
    else
        resize_factor = 1;
    end
    %% GATHER INTEREST POINTS
    disp('Gathering interest points..');
    MAX_INTEREST_PTS = 3000;
    interest_points = get_interest_points(im, MAX_INTEREST_PTS);
    % figure(1), imagesc(rgb2gray(im)); colormap(gray);
    % hold on; plot(interest_points(:,2),interest_points(:,1),'r.'); hold off;
    disp(strcat('Interest Point time: ', num2str(cputime - start_time)));
    %% DESCRIPTOR EXTRACTION
    start_time = cputime;
    disp('Getting feature descriptors..');
    descriptors = get_multiscale_descriptors(im, interest_points);
    % TODO: NEED REFLECTIVE DESCRIPTORS
    % reflect_h_descriptors = get_multiscale_descriptors(im, interest_points);
    disp(strcat('Descriptor time: ', num2str(cputime - start_time)));
    
    %% NN OUTLIER REJECTION
    disp('NN outlier rejection..');
    start_time = cputime;
    % Need to get all types of matches, including reflective
    NN_THRESHOLD = 0.55;
    % matches = nn_outlier_rejection(descriptors, descriptors, NN_THRESHOLD);
    matches = g2nn(descriptors, descriptors, NN_THRESHOLD);
    matches = filter_small_matches(matches, 40);
    % TODO: reflective matches
    disp(strcat('NN time: ', num2str(cputime - start_time)));
    
    %% Unique matches
    matches = unique_matches(matches);
    matches = partition_matches(matches);
    
    %% RANSAC ESTIMATION
    disp('RANSAC..');
    RANSAC_ITERS = 15000;
    start_time = cputime;
    RANSAC_ERR_THRESH = 3;
    
    r_matches = ransac_le_means(matches, RANSAC_ITERS, RANSAC_ERR_THRESH);
    disp(strcat('RANSAC time: ', num2str(cputime - start_time)));

    if resize_factor ~= 1
        % Resize back to original scale
        matches = struct('source', floor(matches.source / resize_factor) , 'target', floor(matches.target / resize_factor));
        r_matches = struct('source', floor(r_matches.source / resize_factor) , 'target', floor(r_matches.target / resize_factor));
    end
    output = struct( ...
        'nn_matches', matches, 'ransac_matches', r_matches, ...
        'nn_img', convert_matches_to_image(h, w, matches), ...
        'ransac_img', convert_matches_to_image(h, w, r_matches) ...
    );

end
