function djc_detector(img_path)
    result = analyze_double_jpeg(img_path);
    E = imread(img_path);
    sz_E = size(E);
    
    aligned_up = repmat(im2colstep(result.aligned, [1 1], [1 1]), 8*8, 1);
    aligned_up = aligned_up - min(min(aligned_up));
    aligned_up = aligned_up / max(max(aligned_up));
    result.aligned = col2imstep(aligned_up, size(result.aligned)*8, [8 8], [8,8]);
    result.aligned = im_center_crop(result.aligned, sz_E(1), sz_E(2));
    
    unaligned_up = repmat(im2colstep(result.unaligned, [1 1], [1 1]), 8*8, 1);
    unaligned_up = unaligned_up - min(min(unaligned_up));
    unaligned_up = unaligned_up / max(max(unaligned_up));
    result.unaligned = col2imstep(unaligned_up, size(result.unaligned)*8, [8 8], [8 8]);
    result.unaligned = im_center_crop(result.unaligned, sz_E(1), sz_E(2));
        
    imshow(E, 'InitialMag', 'fit');
    % Make a truecolor all-green image.
    green = cat(3, ones(sz_E(1:2)), zeros(sz_E(1:2)), zeros(sz_E(1:2)));
    hold on
    h = imshow(green);
    hold off    
    set(h, 'AlphaData', result.aligned)
    saveas(gcf, [img_path '.djcu.png']);    

    clf
    
    imshow(E, 'InitialMag', 'fit');
    % Make a truecolor all-green image.
    green = cat(3, ones(sz_E(1:2)), zeros(sz_E(1:2)), zeros(sz_E(1:2)));
    hold on
    h = imshow(green);
    hold off    
    set(h, 'AlphaData', result.unaligned)
    saveas(gcf, [img_path '.djca.png']);
return
