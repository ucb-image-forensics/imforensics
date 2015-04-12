function [im] = hos_detector(im_path)
  im = make_hos(imread(im_path));
  overlay_feature_mask(im, im_path, '.hos.png');
  
return
