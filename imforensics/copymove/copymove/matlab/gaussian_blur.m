function blurredImage=gaussian_blur(image, sigma)
    blurredImage = imfilter(image, fspecial('gaussian', ceil(sigma * 4), sigma));
end