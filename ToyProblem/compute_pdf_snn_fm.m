%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function:  pdf_snn_fm = compute_pdf_snn_fm(deltas, mu, sigma, mu_r, N_n, 
%            N, o, p_r, mu_f, sigma_f, p_f)
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
function pdf_snn_fm = compute_pdf_snn_fm(deltas, mu, sigma, mu_r, N_n, N, o, p_r, mu_f, sigma_f, p_f)

    % find max index for computing two intervals
    max_delta_two_intervals = 2 * o * sigma;
        
    % two intervals computation
    indexes = find(deltas < max_delta_two_intervals);
    if (~isempty(indexes))
        
        p_in(indexes) = Phi_mix_(mu_r - o*sigma + deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f) - ...
            Phi_mix_(mu_r - o*sigma - deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f) + ...
            Phi_mix_(mu_r + o*sigma + deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f) - ...
            Phi_mix_(mu_r + o*sigma - deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f);
        p_bou(indexes) = phi_mix(mu_r - o*sigma - deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f) + ...
            phi_mix(mu_r - o*sigma + deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f) + ...
            phi_mix(mu_r + o*sigma - deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f) + ...
            phi_mix(mu_r + o*sigma + deltas(indexes)/2, p_r, mu, sigma, p_f, mu_f, sigma_f);
        pdf_snn_fm(indexes) = (p_in(indexes).^(N_n-1)).*(p_bou(indexes)).*((1-p_in(indexes)).^(N-N_n));
                      
        pdf_snn_fm(indexes) = 0.5 * pdf_snn_fm(indexes);
        
    end
    
    % one interval computation (boils down to nn)
    indexes = find(deltas >= max_delta_two_intervals);
    if (~isempty(indexes))
        pdf_snn_fm(indexes) = compute_pdf_nn_fm(deltas(indexes), mu, sigma, mu_r, N_n, N, p_r, mu_f, sigma_f, p_f);
    end    
    
end