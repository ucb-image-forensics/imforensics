function descriptors = get_multiscale_descriptors( im, interest_points )
%GET_MULTISCALE_DESCRIPTORS Summary of this function goes here
%   Detailed explanation goes here

    % TODO: Need to take care of reflective descriptors here..
    % descriptors = sift_keypoint_descriptor(im, interest_points);
    descriptors = box_descriptor_rotate(im, interest_points, 8, 5);
    % descriptors = sift_descriptor(im);
    % descriptors = struct('descriptors', [], 'points', []);
end

