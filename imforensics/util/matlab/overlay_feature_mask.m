function overlay_feature_mask(feature_mask, img_path, suffix)
    E = imread(img_path);
    sz_E = size(E);
    block_size = 2^round(log2(max(max(sz_E))) - log2(max(max(size(feature_mask)))));

    scaled_up = repmat(im2colstep(feature_mask, [1 1], [1 1]), block_size*block_size, 1);
    scaled_up = scaled_up - min(min(scaled_up));
    scaled_up = scaled_up / max(max(scaled_up));
    
    scaled_up = col2imstep(scaled_up, size(feature_mask)*block_size, [block_size block_size], [block_size block_size]);
    sz_F = size(scaled_up);
    
    E = im_center_crop(E, sz_F(1), sz_F(2));
    imshow(E, 'InitialMag', 'fit');
    export_fig(gcf, [img_path suffix], '-native');
    clf
    red = cat(3, ones(sz_F), zeros(sz_F), zeros(sz_F));
    hold on
    h = imshow(red);
    hold off    
    set(h, 'AlphaData', scaled_up);
    export_fig(gcf, [img_path '.hover' suffix], '-native');
    
    
return