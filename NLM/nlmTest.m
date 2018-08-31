%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: nlmTest
% input:    none
% output:   none
% scope:    this function shows how to call nlm.m. It gives an example of
%           denoising using the NLM filter with the NN / SNN sampling
%           strategies.
% author:   Iuri Frosio, ifrosio@nvidia.com
% ref:      I. Frosio, J. Kautz, Statistical Neareast Neighbors for Image
%           Denoising, IEEE Trans. Image Processing, 2018.
% license:  Copyright (C) 2018 NVIDIA Corporation.  All rights reserved.
%           Licensed under the CC BY-NC-SA 4.0 license
%           (https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nlmTest

    % parameters
    sigma = 0.3;                % noise std
    halfPatchSize = 3;          % half size of the patch
    windowSearchHalfSize = 6;   % half size for searching the neighbors
    N_n = 16;                   % numer of neighbors
    h = 0.3 * sigma^2;          % nlm filtering parameter

    % create an image to denoise
    [x,y] = meshgrid(1:512);
    img = sin(1.4*x/512*pi) + cos((1.3*(x+y)/512*pi).^2) - cos((0.34*(2*x+y)/512*pi).^4);
    img = (img - min(img(:)));
    img = img/max(img(:));
    img = imresize(img, 0.25);
    img(:,:,2) = 0.25 + 0.25*img(:,:,1);
    img(:,:,3) = 0.9 - 0.7* img(:,:,1);
    img_n = img + randn(size(img)) * sigma;
    
    
    % denoise (nn, offset = 0)
    offset = 0;
    img_f_nn = nlm(img_n, halfPatchSize, windowSearchHalfSize, N_n, sigma, h, offset);
    
    % denoise (snn, offset = 0.8)
    offset = 0.8;
    img_f_snn = nlm(img_n, halfPatchSize, windowSearchHalfSize, N_n, sigma, h, offset);
    
    % errors
    mse_n = mean((img(:)-img_n(:)).^2);
    mse_nn = mean((img(:)-img_f_nn(:)).^2);
    mse_snn = mean((img(:)-img_f_snn(:)).^2);

    figure(1);
    clf;
    subplot(221);
    imshow(img);
    title('Image');
    subplot(222);
    imshow(img_n);
    title(['Noisy image - MSE = ' num2str(mse_n)]);
    subplot(223);
    imshow(img_f_nn);
    title(['Filtered image [NN] - MSE = ' num2str(mse_nn)]);
    subplot(224);
    imshow(img_f_snn);
    title(['Filtered image [SNN] - MSE = ' num2str(mse_snn)]);

end