function [im_d] = downsample(im, BLOCK_SIZE)
    MULT_OF =  8*BLOCK_SIZE; % block of 8 at lowest level needed to compute relation

    %% Resize image for featurization
    % For LEVELS image pyramids to be calculated, the image needs to be
    % modulo MULT_OF, so center and crop
    sz_im = size(im);
    sz_centered = floor(sz_im(1:2) / MULT_OF) * MULT_OF; 
    
    im = im_center_crop(im, sz_centered(1), sz_centered(2));
    
    im_cols = im2colstep(im, [BLOCK_SIZE BLOCK_SIZE], [BLOCK_SIZE BLOCK_SIZE]);
    im_cols_d = mean(im_cols,1);
    im_d = col2imstep(im_cols_d, size(im)/BLOCK_SIZE, [1 1]);
    
    % There is a loss on each image layer of one pixel on each size since we
    % cant reference surrounding neighbors needed so that amounts to
    % 2*blocksize loss on all sides of the image
    mask_sz_centered = size(im_d) - 2;
    im_d = im_center_crop(im_d, mask_sz_centered(1), mask_sz_centered(2));
return