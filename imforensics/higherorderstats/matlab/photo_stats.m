function [blocks, block_grid, bs] = photo_stats(im, levels, include_error, include_pyramid)
    BLOCK_SIZE = 2^levels;
    MULT_OF =  8*BLOCK_SIZE;
    sz_im = size(im);
    sz_centered = floor(sz_im(1:2) / MULT_OF) * MULT_OF; 
    im = im_center_crop(im, sz_centered(1), sz_centered(2));

    im  = double( im );
    sz  = size(im);
    min_sz = 8*2^(levels+1);
    if sum(mod(sz(1:2),8*2^(levels)))~=0
      error( ['Image dimensions must be divisible by ' int2str(8*2^(levels))]);
      return;
    elseif min(sz(1,2))<min_sz
      error( ['Image must be in size at least ' int2str(min_sz) ' by ' int2str(min_sz)] );
      return;
    end

    if( ndims(im) == 3 )
      TYPE = 'c'; % color image
    else
      TYPE = 'g'; % grayscale image
    end

    if nargin < 3
        % dont include pyramid
        include_error = 1; 
    end

    if nargin < 4
        % dont include pyramid
        include_pyramid = 1; 
    end

    [p,e] = wvltftr(im,levels,TYPE);

    % Compute pyramid block sizes
    MIN_LAYER = 2; % Smallest block should have at at least MIN_LAYER^4 pixels.. no less than 16 per sample plz
    block_sizes = bsxfun(@power,2,[levels-1:-1:MIN_LAYER]');
    % Smallest pyramid / number of output blocks
    block_grid = size(e{1, end});
    block_grid = block_grid(1:2);
    % Final output dimensions
    bs = block_sizes(1) * 2; % times two b/c level 2 is downsampled by a factor of 2

    % Feature vector
    blocks = ones(0, prod(block_grid));

    % Collect error
    for  level = length(block_sizes):-1:1
        for channel = 1:ndims(im);
            block_size = block_sizes(level);
            centered_sz = block_grid*block_size;
            if include_error
                centered_ftr = im_center_crop(e{channel, level}, centered_sz(1), centered_sz(2));
                for orientation = 1:3
                    orientation_blocks = im2colstep(centered_ftr(:,:,orientation), [block_size block_size], [block_size block_size]);
                    orientation_block_stats = [mean(orientation_blocks); var(orientation_blocks); kurtosis(orientation_blocks); skewness(orientation_blocks)];
                    blocks = vertcat(blocks, orientation_block_stats);
                end
            end
            if include_pyramid
                centered_ftr = im_center_crop(p{channel, level}, centered_sz(1), centered_sz(2));
                for orientation = 1:3
                    orientation_blocks = im2colstep(centered_ftr(:,:,orientation), [block_size block_size], [block_size block_size]);
                    orientation_block_stats = [mean(orientation_blocks); var(orientation_blocks); kurtosis(orientation_blocks); skewness(orientation_blocks)];
                    blocks = vertcat(blocks, orientation_block_stats);
                end
            end
        end
    end 


    return;
   
%%% ----------------------------------------------------------------
%%% Collect either grayscale or color statistics
%%%
function [p, e] = wvltftr(im,lev,type)

   if type == 'g' % graylevel image features
      W = wvlt_decompose(im,lev+1); % wavelet decomposition
      [p,e] = extract_channels(W); % statistical feature vector
   elseif type == 'c' % color image features
      W(1) = wvlt_decompose(im(:,:,1),lev+1); % wavelet decomposition
      W(2) = wvlt_decompose(im(:,:,2),lev+1);
      W(3) = wvlt_decompose(im(:,:,3),lev+1);
      [p,e] = extract_channels(W); % error feature vector
   end
   return;
   
%%% ----------------------------------------------------------------
%%% Wavelet decomposition
%%%
function [W] = wvlt_decompose(im,lev)

   im        = im - min(im(:));
   im        = 255 / max(im(:)) * im; % normalize into [0,255]
   [pyr,ind] = buildWpyr(im,lev); % build wavelet pyramid
   
   for k = 1:lev
      [lev,sz]  = wpyrLev(pyr,ind,k);
      dim1v     = sz(1,1)*sz(1,2);
      dim1h     = sz(2,1)*sz(2,2);
      dim1d     = sz(3,1)*sz(3,2);
      W.HP(k).V = reshape(lev(1:dim1v),sz(1,1),sz(1,2));
      W.HP(k).H = reshape(lev(dim1v+1:dim1v+dim1h),sz(2,1),sz(2,2));
      W.HP(k).D = reshape(lev(dim1v+dim1h+1:dim1v+dim1h+dim1d),sz(3,1),sz(3,2));
   end
      
   sz   = ind(length(ind),:);
   lev  = pyr(length(pyr)-sz(1)*sz(2)+1:length(pyr));
   W.LP = reshape(lev, sz(1)*sz(2),1); % lowpass subband
   return;
   
%%% ----------------------------------------------------------------
%%% Extract channels from pyramid decomposition and linear predicitons
%%% of each channel's coefficient magnitudes
%%%
function [Pyr, Err] = extract_channels(W)

   lev = length(W(1).HP);
   ftr = [];
   
   Pyr = {};
   Err = {};
      for k = 1:lev-1
         for l = 1:length(W) % color
             VERT = get_neighbor(W(l),k,'v');
             HORIZ = get_neighbor(W(l),k,'h');
             DIAG = get_neighbor(W(l),k,'d');

             V = VERT(:,1);
             H = HORIZ(:,1);
             D = DIAG(:,1);

             %%% Linear predictor of coefficient magnitude
             V = abs(V);
             Qv = abs(VERT(:,[2:8]));
             v(:,k) = inv(Qv'*Qv) * Qv' * V;

             H = abs(H);
             Qh = abs(HORIZ(:,[2:8]));
             h(:,k) = inv(Qh'*Qh) * Qh' * H;

             D = abs(D);
             Qd = abs(DIAG(:,[2:8]));
             d(:,k) = inv(Qd'*Qd) * Qd' * D;

             %%% Difference between actual and predicted coefficients
             Vp = Qv * v(:,k);
             Hp = Qh * h(:,k);
             Dp = Qd * d(:,k);
             Ev = (log2(V) - log2(abs(Vp)));
             Eh = (log2(H) - log2(abs(Hp)));
             Ed = (log2(D) - log2(abs(Dp)));

             % Pyramid channels
             P = zeros([size(W(l).HP(k).V) - 2, 3]);
             P(:,:,1) = reshape(V, size(W(l).HP(k).V) - 2);
             P(:,:,2) = reshape(H, size(W(l).HP(k).H) - 2);
             P(:,:,3) = reshape(D, size(W(l).HP(k).D) - 2);
             Pyr(l,k) = {P};
             
             % Linear coefficient reconstruction error
             E = zeros([size(W(l).HP(k).V) - 2, 3]);
             E(:,:,1) = reshape(Ev, size(W(l).HP(k).V) - 2);
             E(:,:,2) = reshape(Eh, size(W(l).HP(k).H) - 2);
             E(:,:,3) = reshape(Ed, size(W(l).HP(k).D) - 2);
             Err(l,k) = {E};
         end
      end
return;
      
%%% ----------------------------------------------------------------
%%% Helper function for extract_channels() -- extract spatial/scale/orientation
%%% neighbors
%%%
function [nb] = get_neighbor(W,lev,band)
   
   if lev >= length(W.HP)
      lev = num2str(length(W.HP)-1);
      error(['Up to ' lev 'levels are permitted']);
   end
   
   [ydim,xdim] = size(W.HP(lev).V);
   nb = zeros((xdim-2)*(ydim-2), 8);
   xlim = [2:xdim-1];
   ylim = [2:ydim-1];
   dim = prod((xdim-2)*(ydim-2));
   
   switch band
    case 'v',
     nb(:,1) = reshape(W.HP(lev).V(ylim,xlim), dim, 1);
     nb(:,2) = reshape(W.HP(lev).V(ylim-1,xlim), dim, 1);
     nb(:,3) = reshape(W.HP(lev).V(ylim,xlim-1), dim, 1);
     nb(:,4) = reshape(W.HP(lev+1).V(round(ylim/2), round(xlim/2)), dim, 1);
     nb(:,5) = reshape(W.HP(lev).D(ylim,xlim), dim, 1);
     nb(:,6) = reshape(W.HP(lev+1).D(round(ylim/2), round(xlim/2)), dim, 1);
     nb(:,7) = reshape(W.HP(lev).V(ylim+1,xlim), dim, 1);
     nb(:,8) = reshape(W.HP(lev).V(ylim,xlim+1), dim, 1);
    case 'h',
     nb(:,1) = reshape(W.HP(lev).H(ylim,xlim), dim, 1);
     nb(:,2) = reshape(W.HP(lev).H(ylim-1,xlim), dim, 1);
     nb(:,3) = reshape(W.HP(lev).H(ylim,xlim-1), dim, 1);
     nb(:,4) = reshape(W.HP(lev+1).H(round(ylim/2), round(xlim/2)), dim, 1);
     nb(:,5) = reshape(W.HP(lev).D(ylim,xlim), dim, 1);
     nb(:,6) = reshape(W.HP(lev+1).D(round(ylim/2), round(xlim/2)), dim, 1);
     nb(:,7) = reshape(W.HP(lev).H(ylim+1,xlim), dim, 1);
     nb(:,8) = reshape(W.HP(lev).H(ylim,xlim+1), dim, 1);
    case 'd',
     nb(:,1) = reshape(W.HP(lev).D(ylim,xlim), dim, 1);
     nb(:,2) = reshape(W.HP(lev).D(ylim-1,xlim), dim, 1);
     nb(:,3) = reshape(W.HP(lev).D(ylim,xlim-1), dim, 1);
     nb(:,4) = reshape(W.HP(lev+1).D(round(ylim/2), round(xlim/2)), dim, 1);
     nb(:,5) = reshape(W.HP(lev).H(ylim,xlim), dim, 1);
     nb(:,6) = reshape(W.HP(lev).V(ylim,xlim), dim, 1);
     nb(:,7) = reshape(W.HP(lev).D(ylim+1,xlim), dim, 1);
     nb(:,8) = reshape(W.HP(lev).D(ylim,xlim+1), dim, 1);
    otherwise,
     error('Bad subband label');
   end
   return;
%%% ----------------------------------------------------------------

