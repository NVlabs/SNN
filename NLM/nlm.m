%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: img_f = nlm(img_n, halfPatchSize, windowHalfSearchSize, N_n, 
%           sigma, h, offset)
% input:    img_n, double image (single or multi channel) corrupted by iid
%           Gaussian noise with std sigma;
%           halfPatchSize, half size of the patch used by NLM;
%           windowHalfSearchSize, half size of the windows used to search
%           for neighbors;
%           N_n, number of neighbors used by NLM;
%           sigma, std of the noise;
%           h, filtering parameter for NLM;
%           offset, offset parameter (0 for NN, 1 for SNN).
% output:   img_f, filtered image.
% scope:    this function shows NLM denoising with the NN / SNN sampling
%           strategies; it is not designed to be computationally efficient.
% author:   Iuri Frosio, ifrosio@nvidia.com
% ref:      I. Frosio, J. Kautz, Statistical Neareast Neighbors for Image
%           Denoising, IEEE Trans. Image Processing, 2018.
% license:  Copyright (C) 2018 NVIDIA Corporation.  All rights reserved.
%           Licensed under the CC BY-NC-SA 4.0 license
%           (https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function img_f = nlm(img_n, halfPatchSize, windowHalfSearchSize, N_n, sigma, h, offset)

    % init
    [ys, xs, cs] = size(img_n);
    patchSize = 2 * halfPatchSize + 1;
    P = cs * patchSize^2;
    expected_squared_distance = 2 * sigma^2;

    % Init buffers
    neighbors_indexes = zeros(ys, xs, N_n);
    neighbors_d2 = ones(ys, xs, N_n) * inf;
    padded_img_n = padarray(img_n, [windowHalfSearchSize windowHalfSearchSize 0], 'symmetric');
    
    % For each shift
    index = 0;
    for dy = -windowHalfSearchSize:windowHalfSearchSize
        for dx = -windowHalfSearchSize:windowHalfSearchSize
            
            % shift index
            index = index + 1;
            
            % shifted image (with mirroring)
            shifted_img_n = padded_img_n((windowHalfSearchSize + 1 + dy):(windowHalfSearchSize + ys + dy), ...
                (windowHalfSearchSize + 1 + dx):(windowHalfSearchSize + xs + dx), ...
                :);
            
            % squared distance between the shifted and the reference image
            current_d2 = imfilter(sum((shifted_img_n - img_n).^2, 3), ones(patchSize)/P, 'symmetric');
            current_indexes = ones(ys, xs) * index;
            
            % update neighbors
            for n = 1 : N_n
                
                % is the current neighbor closer than the stored one?
                swap = abs(current_d2 - offset * expected_squared_distance) < abs(neighbors_d2(:, :, n) - offset * expected_squared_distance);
                
                % swap (indexes, distances)
                neighbors_indexes_n = neighbors_indexes(:, :, n);
                buffer_indexes_n = neighbors_indexes_n;
                neighbors_indexes_n(swap) = current_indexes(swap);
                current_indexes(swap) = buffer_indexes_n(swap);
                neighbors_indexes(:, :, n) = neighbors_indexes_n;
                
                neighbors_d2_n = neighbors_d2(:, :, n);
                buffer_d2_n = neighbors_d2_n;
                neighbors_d2_n(swap) = current_d2(swap);
                current_d2(swap) = buffer_d2_n(swap);
                neighbors_d2(:, :, n) = neighbors_d2_n;               
                
            end
        end
    end
    
    % init num / den
    num = zeros(ys, xs, cs);
    den = zeros(ys, xs, cs);
    
    % do another loop on the possible neighbors to filter
    index = 0;
    for dy = -windowHalfSearchSize:windowHalfSearchSize
        for dx = -windowHalfSearchSize:windowHalfSearchSize
            
            % shift index
            index = index + 1;
            
            % shifted image (with mirroring)
            shifted_img_n = padded_img_n((windowHalfSearchSize + 1 + dy):(windowHalfSearchSize + ys + dy), ...
                (windowHalfSearchSize + 1 + dx):(windowHalfSearchSize + xs + dx), ...
                :);
            
            % For every neighbors
            for n = 1 : N_n
            
                % weights
                buffer_weights = (neighbors_indexes(:, :, n) == index) .* exp(-(max(0, neighbors_d2(:, :, n) - 2 * sigma^2))/(h^2));
                weights = repmat(imfilter(buffer_weights, ones(patchSize), 'symmetric'), [1 1 cs]);
                num = num + weights .* shifted_img_n;
                den = den + weights;
                
            end
        end
    end

    % filtered image
    img_f = num./den;

end