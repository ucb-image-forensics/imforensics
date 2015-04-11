function [X] = analyze_double_jpeg(img_path)
    %
    % Hyper params
    %
    ncomp = 1; % Color component (1 = Y, 2 = Cb, 3 = Cr)
    c2 = 6; % use DCT components 1-6 (1 <= c2 <= 64)
    
    im_jpg = jpeg_read(img_path);
    [LLRmap, LLRmap_s, q1table, alphat] = getJmap_EM(im_jpg, ncomp, c2);
    X.aligned = imfilter(sum(LLRmap,3), ones(3), 'symmetric', 'same');
    [LLRmap, LLRmap_s, q1table, k1e, k2e, alphat] = getJmapNA_EM(im_jpg, ncomp, c2);
    X.unaligned = smooth_unshift(sum(LLRmap,3),k1e,k2e);
return