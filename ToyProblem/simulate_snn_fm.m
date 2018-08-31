%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: [mu_rs, expected_value_mu_hats, variance_mu_hats, p_mu_rs, 
%           expected_value_deltas] = simulate_snn_fm(mu, sigma, N_n, N, o, 
%           p_r, mu_f, sigma_f, p_f, steps)
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
function [mu_rs, expected_value_mu_hats, variance_mu_hats, p_mu_rs, expected_value_deltas] = simulate_snn_fm(mu, sigma, N_n, N, o, p_r, mu_f, sigma_f, p_f, steps)

    % input
    if nargin==9
        steps = 100;
    end

    % for any significant value of mu_r...
    min_mu_rs = min(mu - 5 * sigma, mu_f - 5 * sigma_f);
    max_mu_rs = max(mu + 5 * sigma, mu_f + 5 * sigma_f);
    mu_rs = min_mu_rs: (max_mu_rs - min_mu_rs) / (steps-1) : max_mu_rs;
    
    % init
    expected_value_mu_hats = zeros(1, numel(mu_rs));
    variance_mu_hats = zeros(1, numel(mu_rs));
    p_mu_rs = normpdf(mu_rs, mu, sigma);
    expected_value_deltas = zeros(1, numel(mu_rs));

    % estimate error for each mu_r
    for n_mu_r = 1 : numel(mu_rs)
        
        % reference (noisy) value
        mu_r = mu_rs(n_mu_r);
        
        % display time
        display(['computing mu_r = ' num2str(mu_r) ' (step ' num2str(n_mu_r) '/' num2str(numel(mu_rs)) ')']);
        
        % max interval for finding neighbors around mu_r
        max_ds = max(abs(mu_r - min_mu_rs), abs(max_mu_rs - mu_r));
        ds = 0 : max_ds / 999 : max_ds;
        
        % probability density function for d, p(d)
        p_deltas = compute_pdf_snn_fm(ds, mu, sigma, mu_r, N_n, N, o, p_r, mu_f, sigma_f, p_f);
        xi = 1 / (sum(p_deltas) * (ds(2) - ds(1)));
        p_deltas = xi * p_deltas;
        
        %if (mu_r > -1.5)
        %    keyboard
        %end
       
        % expected value for delta
        expected_value_deltas(n_mu_r) = sum(p_deltas .* ds) / sum(p_deltas);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % expected value of mu hat (for the given mu_r) left and right
        
        % init
        num = 0;
        den = 0;
        delta_d = ds(2) - ds(1);
        
        num1 = 0;
        num2 = 0;
        den1 = 0;
        den2 = 0;
        
        % numerical integration
        e_avg_gamma_ks = zeros(1, numel(ds));
        var_avg_gamma_ks = zeros(1, numel(ds));
        expected_variance_truncated_gaussian0s = zeros(1, numel(ds));
        for n = 1 : numel(ds)
            
            % expected value of the first N_n-1 neighbors in the interval
            d = ds(n);

            % correct with the expected value of the neighbor at distance d
            if (d >= (2 * o * sigma))
                
                % The first N_n-1 neighbors come either from the reference
                % or from the false matching distribution
                [e_gamma_k_d_r, var_gamma_k_d_r, p_gamma_k_d_r] = expectedValueTruncatedGaussian(mu, sigma, mu_r - d, mu_r + d);
                p_gamma_k_d_r = p_gamma_k_d_r * p_r;
                [e_gamma_k_d_f, var_gamma_k_d_f, p_gamma_k_d_f] = expectedValueTruncatedGaussian(mu_f, sigma_f, mu_r - d, mu_r + d);
                p_gamma_k_d_f = p_gamma_k_d_f * p_f;
                [e_gamma_k_d, var_gamma_k_d] = mixtureOfRandomVariables([p_gamma_k_d_r, p_gamma_k_d_f] / sum([p_gamma_k_d_r, p_gamma_k_d_f]), ...
                    [e_gamma_k_d_r, e_gamma_k_d_f],...
                    [var_gamma_k_d_r, var_gamma_k_d_f]);

                % Now compute the expected value and variance for the
                % N_n-th neighbor
                [e_gamma_N_n_d_r, var_gamma_N_n_d_r] = mixtureOfRandomVariables([normpdf(mu_r - d, mu, sigma), normpdf(mu_r + d, mu, sigma)] / sum([normpdf(mu_r - d, mu, sigma), normpdf(mu_r + d, mu, sigma)]), ...
                    [mu_r - d, mu_r + d], ...
                    [0 0]);
                p_gamma_N_n_d_r = (normpdf(mu_r - d, mu, sigma) + normpdf(mu_r + d, mu, sigma)) * p_r;
                [e_gamma_N_n_d_f, var_gamma_N_n_d_f] = mixtureOfRandomVariables([normpdf(mu_r - d, mu_f, sigma_f), normpdf(mu_r + d, mu_f, sigma_f)] / sum([normpdf(mu_r - d, mu_f, sigma_f), normpdf(mu_r + d, mu_f, sigma_f)]), ...
                    [mu_r - d, mu_r + d], ...
                    [0 0]);
                p_gamma_N_n_d_f = (normpdf(mu_r - d, mu_f, sigma_f) + normpdf(mu_r + d, mu_f, sigma_f)) * p_f;
                [e_gamma_N_n_d, var_gamma_N_n_d] = mixtureOfRandomVariables([p_gamma_N_n_d_r, p_gamma_N_n_d_f]/sum([p_gamma_N_n_d_r, p_gamma_N_n_d_f]), ...
                    [e_gamma_N_n_d_r, e_gamma_N_n_d_f], ...
                    [var_gamma_N_n_d_r, var_gamma_N_n_d_f]);
                
                % put together all the neighbors
                [e_avg_gamma_k, var_avg_gamma_k] = linearMixOfRandomVariables(ones(1,N_n)/N_n, ...
                    [ones(1,N_n-1)*e_gamma_k_d e_gamma_N_n_d], ...
                    [ones(1,N_n-1)*var_gamma_k_d var_gamma_N_n_d]);     
                
                e_avg_gamma_ks(n) = e_avg_gamma_k;
                var_avg_gamma_ks(n) = var_avg_gamma_k;
                
                num1 = num1 + e_avg_gamma_ks(n) * p_deltas(n);
                den1 = den1 + p_deltas(n);
                
            else
                
                % two interval case
                
                % First N_n-1 neighbors
                [e_gamma_k_d_rL, var_gamma_k_d_rL, p_gamma_k_d_rL] = expectedValueTruncatedGaussian(mu,   sigma,   mu_r - o * sigma - d/2, mu_r - o * sigma + d/2);
                p_gamma_k_d_rL = p_gamma_k_d_rL * p_r;
                [e_gamma_k_d_fL, var_gamma_k_d_fL, p_gamma_k_d_fL] = expectedValueTruncatedGaussian(mu_f, sigma_f, mu_r - o * sigma - d/2, mu_r - o * sigma + d/2);
                p_gamma_k_d_fL = p_gamma_k_d_fL * p_f;
                [e_gamma_k_d_rR, var_gamma_k_d_rR, p_gamma_k_d_rR] = expectedValueTruncatedGaussian(mu,   sigma,   mu_r + o * sigma - d/2, mu_r + o * sigma + d/2);
                p_gamma_k_d_rR = p_gamma_k_d_rR * p_r;
                [e_gamma_k_d_fR, var_gamma_k_d_fR, p_gamma_k_d_fR] = expectedValueTruncatedGaussian(mu_f, sigma_f, mu_r + o * sigma - d/2, mu_r + o * sigma + d/2);
                p_gamma_k_d_fR = p_gamma_k_d_fR * p_f;
                probabilities = [p_gamma_k_d_rL p_gamma_k_d_fL p_gamma_k_d_rR p_gamma_k_d_fR];
                probabilities = probabilities / sum(probabilities);
                expected_values = [e_gamma_k_d_rL e_gamma_k_d_fL e_gamma_k_d_rR e_gamma_k_d_fR];
                variances = [var_gamma_k_d_rL var_gamma_k_d_fL var_gamma_k_d_rR var_gamma_k_d_fR];
                [e_gamma_k_d, var_gamma_k_d] = mixtureOfRandomVariables(probabilities, expected_values, variances);
                
                % N_n-th neighbor 
                probabilities = [normpdf(mu_r - o * sigma - d/2, mu, sigma) * p_r + normpdf(mu_r - o * sigma - d/2, mu_f, sigma_f) * p_f, ...
                                 normpdf(mu_r - o * sigma + d/2, mu, sigma) * p_r + normpdf(mu_r - o * sigma + d/2, mu_f, sigma_f) * p_f, ...
                                 normpdf(mu_r + o * sigma - d/2, mu, sigma) * p_r + normpdf(mu_r + o * sigma - d/2, mu_f, sigma_f) * p_f, ...
                                 normpdf(mu_r + o * sigma + d/2, mu, sigma) * p_r + normpdf(mu_r + o * sigma + d/2, mu_f, sigma_f) * p_f];
                probabilities = probabilities / sum(probabilities);             
                expected_values = [mu_r - o * sigma - d/2, mu_r - o * sigma + d/2, mu_r + o * sigma - d/2, mu_r + o * sigma + d/2];
                variances = [0 0 0 0];
                [e_gamma_N_n_d, var_gamma_N_n_d] = mixtureOfRandomVariables(probabilities, expected_values, variances);
                
                % mix all neighbors
                [e_avg_gamma_k, var_avg_gamma_k] = linearMixOfRandomVariables(ones(1,N_n)/N_n, ...
                    [ones(1,N_n-1)*e_gamma_k_d e_gamma_N_n_d], ...
                    [ones(1,N_n-1)*var_gamma_k_d var_gamma_N_n_d]);
                
                e_avg_gamma_ks(n) = e_avg_gamma_k;
                var_avg_gamma_ks(n) = var_avg_gamma_k;                
                
                num2 = num2 + e_avg_gamma_ks(n) * p_deltas(n);
                den2 = den2 + p_deltas(n);
                
            end
            
            % numerical integration
            num = num + e_avg_gamma_ks(n) * p_deltas(n);
            den = den + p_deltas(n);
            
        end
        expected_value_mu_hats(n_mu_r) = num / den;
        
        % dDelta_NN = 2 dDeltaSNN
        %expected_value_mu_hats(n_mu_r) = (2*num1+num2)/(2*den1+den2);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % variance of mu hat (for the given mu_r)
        
        % numerical integration
        num = 0;
        for n = 1 : numel(ds)
            d = ds(n);
            num = num + var_avg_gamma_ks(n) * p_deltas(n);
            % have to add this - the former one is only the variance of the
            % neighbors, does not include the fact that for every d
            num = num + ((e_avg_gamma_ks(n) - expected_value_mu_hats(n_mu_r))^2) * p_deltas(n);    
        end
        variance_mu_hats(n_mu_r) = num / den;
        
    end
    
end