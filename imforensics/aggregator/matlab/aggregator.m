function [X] = aggregator(X_cm, X_ela, X_ho)
    BLOCK_SIZE = 16;

    % Higer order stats
    X = X_ho;

    % Copy move
    X = cat(3, X, downsample(X_cm(:,:,1), BLOCK_SIZE));

    % ELA
    X = cat(3, X, downsample(X_ela(:,:,1), BLOCK_SIZE));
    X = cat(3, X, downsample(X_ela(:,:,2), BLOCK_SIZE));
    X = cat(3, X, downsample(X_ela(:,:,3), BLOCK_SIZE));
return
