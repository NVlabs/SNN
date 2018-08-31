%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: [expectedValue, expectedVariance, prob] = 
%           expectedValueTruncatedGaussian(mu, sigma, xMin, xMax)
% input:    
% output:   
% scope:    
% author:   Iuri Frosio, ifrosio@nvidia.com
% ref:      I. Frosio, J. Kautz, Statistical Neareast Neighbors for Image
%           Denoising, IEEE Trans. Image Processing, 2018.
% license:  Copyright (C) 2018 NVIDIA Corporation.  All rights reserved.
%           Licensed under the CC BY-NC-SA 4.0 license
%           (https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [expectedValue, expectedVariance, prob] = expectedValueTruncatedGaussian(mu, sigma, xMin, xMax)

    % prob is the percentage of area in the restriced interval (wrt the non truncated gaussian)
    prob = 0.5*(erf((xMax-mu)/(sqrt(2)*sigma)) - erf((xMin-mu)/(sqrt(2)*sigma)));
    prob = max(eps, prob);

    expectedValue = mu + sigma / sqrt(2*pi) *(exp(-0.5*((xMin - mu)/sigma)^2) - exp(-0.5*((xMax - mu)/sigma)^2)) / prob;

    phiMin = phi((xMin-mu)/sigma);
    phiMax = phi((xMax-mu)/sigma);

    PhiMin = Phi_((xMin-mu)/sigma);
    PhiMax = Phi_((xMax-mu)/sigma);
        
    expectedVariance = (sigma^2) * (1 + ((xMin-mu).*phiMin/sigma - (xMax-mu).*phiMax/sigma)./max(eps,PhiMax-PhiMin) - ((phiMin-phiMax)./max(eps,PhiMax-PhiMin)).^2);    
        
end