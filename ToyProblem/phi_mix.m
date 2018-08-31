%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: y = phi_mix(x, p_r, mu, sigma, p_f, mu_f, sigma_f)
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
function y = phi_mix(x, p_r, mu, sigma, p_f, mu_f, sigma_f)
    y = (p_r / sigma) * phi((x - mu)/sigma) + (p_f / sigma_f) * phi((x - mu_f)/sigma_f);
end