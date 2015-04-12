function [im] = make_hos(im)
    load edges % Load W from trained FDA
    PYR_LEVELS = 4;
   
    [blocks, block_grid, ~] = photo_stats(im, PYR_LEVELS, 1, 1);
    X = W' * blocks;
    im = col2imstep(X, block_grid, [1 1]);
return