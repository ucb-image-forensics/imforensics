function overlay_feature_mask(feature_mask, img_path, suffix)
    E = imread(img_path);
    sz_E = size(E);
    block_size = ceil(max(max(sz_E))/max(max(size(feature_mask))));

    scaled_up = repmat(im2colstep(feature_mask, [1 1], [1 1]), block_size*block_size, 1);
    scaled_up = scaled_up - min(min(scaled_up));
    scaled_up = scaled_up / max(max(scaled_up));
    
    scaled_up = col2imstep(scaled_up, size(feature_mask)*block_size, [block_size block_size], [block_size block_size]);
    scaled_up = im_center_crop(scaled_up, sz_E(1), sz_E(2));
    

    imshow(E, 'InitialMag', 'fit');
    red = cat(3, ones(sz_E(1:2)), zeros(sz_E(1:2)), zeros(sz_E(1:2)));
    hold on
    h = imshow(red);
    hold off    
    set(h, 'AlphaData', scaled_up)
    export_fig(gcf, [img_path suffix]);
    
    
return