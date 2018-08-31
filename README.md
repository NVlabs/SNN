# SNN (Statistical Nearest Neighbors)

Matlab code implementation of the modified Non Local Means and Bilateral filters, as described in I. Frosio, J. Kautz, Statistical Nearest Neighbors for Image Denoising, IEEE Trans. Image Processing, 2018. The repository also includes the Matlab code to replicate the results of the toy problem described in the paper.

# License

Copyright (C) 2018 NVIDIA Corporation.  All rights reserved.
Licensed under the CC BY-NC-SA 4.0 license (https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode). 

# Usage

**/NLM/nlm.m**: Matlab code to filter a user defined image thorugh the modified Non Local Means filter (accordinagly to the SNN approach) and user defined filtering parameters. The traditional Non Local Means filter is achieved passing offset = 0 in input.

**/NLM/runme.m**: example usage of /NLM/nlm.m.

**/BilateralFilter/bilateralFilter.m**: Matlab code to filter a user defined image thorugh the modified Bilateral filter (accordinagly to the SNN approach) and user defined filtering parameters. The traditional Bilateral filter is achieved passing offset = 0 in input.

**/BilateralFilter/runme.m**: example usage of /BilateralFilter/bilateralFilter.m.

**/ToyProblem/toyProblem.m**: Matlab code to replicate the results on the toy problem described in our paper.

**/ToyProblem/runme.m**: example usage of ToyProblem/toyproblem.m.

# References

I. Frosio, J. Kautz, Statistical Nearest Neighbors for Image Denoising, IEEE Trans. Image Processing, 2018.
```
@article{Fro18,
  title={Statistical Nearest Neighbors for Image Denoising},
  author={Frosio, Iuri and Kautz, Jan},
  journal={IEEE Trans. Image Processing},
  year={2018},  
}
```
