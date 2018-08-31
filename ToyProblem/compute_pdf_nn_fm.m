%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:  pdf_nn = compute_pdf_nn_fm(ds, mu, sigma, mu_r, N_n, N, p_r, 
%            mu_f, sigma_f, p_f)
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
function pdf_nn = compute_pdf_nn_fm(ds, mu, sigma, mu_r, N_n, N, p_r, mu_f, sigma_f, p_f)

    p_in = Phi_mix_(mu_r + ds, p_r, mu, sigma, p_f, mu_f, sigma_f) - ...
        Phi_mix_(mu_r - ds, p_r, mu, sigma, p_f, mu_f, sigma_f);
    p_bou = phi_mix(mu_r - ds, p_r, mu, sigma, p_f, mu_f, sigma_f) + ...
        phi_mix(mu_r + ds, p_r, mu, sigma, p_f, mu_f, sigma_f);
    pdf_nn = (p_in.^(N_n-1)).*(p_bou).*((1-p_in).^(N-N_n));
    
end