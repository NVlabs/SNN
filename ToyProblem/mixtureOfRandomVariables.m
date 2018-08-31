%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function: [expected_value, variance] = mixtureOfRandomVariables(
%           probabilities, expected_values, variances)
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
function [expected_value, variance] = mixtureOfRandomVariables(probabilities, expected_values, variances)

    % return the expected value and variance of a mixture of independent
    % ranomd variables, each with the given expected value and variance
    
    expected_value = sum(probabilities .* expected_values);
    variance = sum(probabilities .* variances) + ...
        sum(probabilities .* (expected_values.^2)) - ...
        sum(probabilities .* expected_values)^2;

end