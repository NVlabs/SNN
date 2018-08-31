%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:img_f = bilateralFilter(img_n, halfFilterSize, sigma_r, sigma_s,
%           sigma, offset)
% input:    img_n, double image (single or multi channel) corrupted by iid
%           Gaussian noise with std sigma;
%           halfFilterSize, half size of the filter;
%           sigma_s, sigma (spatial);
%           sigma_r, sigma (range);
%           sigma, noise std;
%           offset, offset parameter (0 for NN, 1 for SNN).
% output:   img_f, filtered image.
% scope:    this function shows bilteral filter denoising with the NN / SNN
%           sampling strategies; it is not designed to be computationally 
%           efficient.
% author:   Iuri Frosio, ifrosio@nvidia.com
% ref:      I. Frosio, J. Kautz, Statistical Neareast Neighbors for Image
%           Denoising, IEEE Trans. Image Processing, 2018.
% license:  Copyright (C) 2018 NVIDIA Corporation.  All rights reserved.
%           Licensed under the CC BY-NC-SA 4.0 license
%           (https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function img_f = bilateralFilter(img_n, halfFilterSize, sigma_r, sigma_s, sigma, offset)

    % init
    filterSize = 2 * halfFilterSize + 1;
    padded_img_n = padarray(img_n, [halfFilterSize halfFilterSize 0],'symmetric');
    [ys, xs, cs] = size(img_n);
    expected_squared_distance = 2 * sigma^2;
    P = cs;
    num = zeros(ys + 2 * halfFilterSize, xs + 2 * halfFilterSize, cs);
    den = zeros(ys + 2 * halfFilterSize, xs + 2 * halfFilterSize, cs);
    img_f = zeros(ys, xs, cs);

    % spatial weights - these are fixed
    [xxs,yys] = meshgrid(-halfFilterSize:halfFilterSize);
    w_s = exp(-0.5 * (xxs.^2 + yys.^2) / (sigma_s^2));   
    
    % loop over all the pixels of the image
    for y = halfFilterSize + 1 : ys + halfFilterSize
        for x = halfFilterSize + 1 : ys + halfFilterSize
            
            % compute sqaured distance from the central pixels
            d2 = zeros(filterSize);
            for c = 1 : cs
                d2 = d2 + (padded_img_n(y-halfFilterSize:y+halfFilterSize, x-halfFilterSize:x+halfFilterSize, c) - ...
                    padded_img_n(y, x, c)).^2;
            end
            d2 = d2 / P; 
            
            % compute the range weights
            w_r = exp(-0.5 * (abs(d2 - offset * expected_squared_distance)) / (sigma_r^2));
            
            % weights
            w = w_r .* w_s;
            w = w / sum(w(:));

            % filter
            for c = 1 : cs
                img_f(y - halfFilterSize, x - halfFilterSize, c) = sum(sum(w.*padded_img_n(y-halfFilterSize:y+halfFilterSize, x-halfFilterSize:x+halfFilterSize, c)));
            end                        
        end
    end
   

end