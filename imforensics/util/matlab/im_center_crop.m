
%%% ----------------------------------------------------------------
%%% Crop central region of size w x h
%%%
function [im1] = im_center_crop(im,w,h)

   if( size(im,1) > size(im,2) )
      b = center_blk([size(im,1),size(im,2)],[max(h,w) min(h,w)]);
   else
      b = center_blk([size(im,1),size(im,2)],[min(h,w) max(h,w)]);
   end
   im1 = imcrop(im,b);
   return;
   
function [b] = center_blk(B,bs)
   B = B(:)';
   bs = bs(:)';
   
   if length(B) == 2
      B = [1 1 B(1) B(2)];
   end
   if length(B) ~= 4
      error('Specify the block please');
   end
   if length(bs) ~= 2
      error('Specify the width and height please');
   end
   
   ctry = round((B(3)-B(1))/2);
   ctrx = round((B(4)-B(2))/2);
   w    = ceil(bs(2)/2);
   h    = ceil(bs(1)/2);
   b    = [ max(1,ctrx-w) max(1,ctry-h) bs(2)-1 bs(1)-1 ];
   return;
   