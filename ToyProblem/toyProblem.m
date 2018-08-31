%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: toyPtoblem
% input:    none
% output:   none
% scope:    this function shows how to call simulate_snn_fm.m, which
%           computes the distribution of the estimated mu in our toy
%           problem.
% author:   Iuri Frosio, ifrosio@nvidia.com
% ref:      I. Frosio, J. Kautz, Statistical Neareast Neighbors for Image
%           Denoising, IEEE Trans. Image Processing, 2018.
% license:  Copyright (C) 2018 NVIDIA Corporation.  All rights reserved.
%           Licensed under the CC BY-NC-SA 4.0 license
%           (https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function toyProblem

    % Parameter for the toy problem (Fig. 6b in the paper)
    mu = 0;             % ground truth value of the reference patch
    sigma = 0.27;       % std of the noise
    mu_f = 0.7;         % value of the false-matching patches
    sigma_f = sigma;    % we assume the noise std is the same for the distribution of the patches in the reference cluster (sigma) and for the distribution of the patches in the false-matching cluster (sigma_f)
    p_r = 0.5;          % probability of finding patches from the correct cluster 
    p_f = 1 - p_r;      % probability of finding patches from the false-matching cluster 
    N_n = 8;            % number of neighbors used
    N = 100;            % total number of available patches
    steps = 100;        % numer of steps to divide the interval

    % simulate NN 
    o = 0;  % offset o = 0 allows simulating NN
    [mu_rs, nn_expected_value_mu_hats, nn_variance_mu_hats, p_mu_rs, ...
        nn_expected_value_deltas] = simulate_snn_fm(mu, sigma, N_n, N, o, ...
        p_r, mu_f, sigma_f, p_f, steps);
    
    % simulate SNN 
    o = 1;  % offset o = 1 allows simulating SNN - change this to try different offset parameters
    [~, snn_expected_value_mu_hats, snn_variance_mu_hats, ~, ...
        snn_expected_value_deltas] = simulate_snn_fm(mu, sigma, N_n, N, o, ...
        p_r, mu_f, sigma_f, p_f, steps);
    
    % compute errors 
    e2_bias_nn = sum(p_mu_rs.*((nn_expected_value_mu_hats-mu).^2))/sum(p_mu_rs);
    e2_var_nn = sum(p_mu_rs.*nn_variance_mu_hats)/sum(p_mu_rs);
    e2_nn = e2_bias_nn + e2_var_nn;
    e2_bias_snn = sum(p_mu_rs.*((snn_expected_value_mu_hats-mu).^2))/sum(p_mu_rs);
    e2_var_snn = sum(p_mu_rs.*snn_variance_mu_hats)/sum(p_mu_rs);
    e2_snn = e2_bias_snn + e2_var_snn;
        
    % plot time
    figure(1);
    clf;
    A = axes;
    plot(mu_rs, mu*ones(size(mu_rs)), 'k');
    hold on;
    plot(mu_rs, nn_expected_value_mu_hats, 'r');
    plot([mu_rs NaN mu_rs], [nn_expected_value_mu_hats - 3 * sqrt(nn_variance_mu_hats) NaN nn_expected_value_mu_hats + 3 * sqrt(nn_variance_mu_hats)], 'r:');
    plot(mu_rs, snn_expected_value_mu_hats, 'b');
    plot([mu_rs NaN mu_rs], [snn_expected_value_mu_hats - 3 * sqrt(snn_variance_mu_hats) NaN snn_expected_value_mu_hats + 3 * sqrt(snn_variance_mu_hats)], 'b:');
    hold off;
    grid on;
    xlabel('$$\mu_r$$', 'interpreter', 'latex');
    ylabel('$$E[\hat{\mu}(\mu_r)]$$', 'interpreter', 'latex');
    title({['$$NN, \varepsilon^2(' num2str(e2_nn) ') = \varepsilon_{bias}^2 (' num2str(e2_bias_nn) ') + \varepsilon_{var}^2 (' num2str(e2_var_nn)  ')$$'], ...
           ['$$SNN, \varepsilon^2(' num2str(e2_snn) ') = \varepsilon_{bias}^2 (' num2str(e2_bias_snn) ') + \varepsilon_{var}^2 (' num2str(e2_var_snn)  ')$$']}, ...
           'interpreter', 'latex');
    legend({'$$\mu$$ [ground truth value]', ...
         '$E[\hat{\mu}(\mu_r)]$ \ [NN]', ...
         '$E[\hat{\mu}(\mu_r)] \pm 3\sqrt{Var[\hat{\mu}(\mu_r)]}$ \ [NN]', ...
         '$E[\hat{\mu}(\mu_r)]$ \ [SNN]', ...
         '$E[\hat{\mu}(\mu_r)] \pm 3\sqrt{Var[\hat{\mu}(\mu_r)]}$ \ [SNN]'}, 'interpreter', 'latex');
     
end