# glmnet_matlab
glmnet for MATLAB compiled for compatibility with 64-bit Windows 10 and Mac OS systems. Plug 'n play!
## Background
[glmnet](https://web.stanford.edu/~hastie/glmnet/glmnet_alpha.html) is an extremely efficient toolbox for fitting lasso and elastic-net [regularized](https://en.wikipedia.org/wiki/Regularization_(mathematics)) [generalized linear models](https://en.wikipedia.org/wiki/Generalized_linear_model). Unfortunately the [glmnet for MATLAB files](https://web.stanford.edu/~hastie/glmnet_matlab/) provided by the authors are not compatible with newer versions of MATLAB, Mac OS, and Windows 10. This is a shame, because glmnet for MATLAB is orders of magnitude faster than other similar packages. Thus I recompiled the mex files in this repository to be compatible with modern systems; I have tested them with MATLAB 2017a in Mac OS 12 and Windows 10.

glmnet for MATLAB is fast because the core function is implemented in [FORTRAN](https://en.wikipedia.org/wiki/Fortran), a language beloved for its use in [weather prediction](https://imgur.com/gallery/EeI8V3E) but divisive for its [one-based indexing](https://en.wikipedia.org/wiki/Zero-based_numbering). MATLAB can call FORTRAN (and C/C++) functions via [MEX](https://www.mathworks.com/help/matlab/matlab_external/introducing-mex-files.html) tools, but doing so requires a FORTRAN (or C/C++) compiler, which can be a hassle to obtain.
## Implementation
I installed [Virtual Studio 2015 Community](https://visualstudio.microsoft.com/vs/older-downloads/) (necessary on Windows 10 only) and then the [Intel Parallel Studio XE 2016](https://software.intel.com/en-us/parallel-studio-xe/choose-download) FORTRAN compiler (necessary on Windows 10 and Mac OS). I compiled the files in MATLAB on Windows 10 using the commmand:
```
mex -compatibleArrayDims glmnetMex.F GLMnet.f 
```
and on Mac OS 12 using the command:
```
mex FFLAGS='-fdefault-real-8 -ffixed-form -compatibleArrayDims' glmnetMex.F GLMnet.f
```
Note that these commands are different from the author-recommended commands for [Windows](https://web.stanford.edu/~hastie/glmnet_matlab/win64compile.html) and [Mac](https://web.stanford.edu/~hastie/glmnet_matlab/mac64compile.html). The 
```
-compatibleArrayDims
```
option compiles the FORTRAN code using the 32-bit API, which may be deprecated in future MATLAB releases. The permanent solution is to [modify the FORTRAN source to be 64-bit compliant](https://www.mathworks.com/help/matlab/matlab_external/upgrading-mex-files-to-use-64-bit-api.html), which you should do because you're a good person, or I should do if I have something extremely imposing to procrastinate on.

Please remember to cite the authors if you use glmnet:
```
Glmnet for Matlab (2013) Qian, J., Hastie, T., Friedman, J., Tibshirani, R. and Simon, N.
http://www.stanford.edu/~hastie/glmnet_matlab/
```
Also check out this [interesting speed comparison](https://modelingguru.nasa.gov/docs/DOC-2676) between MATLAB, Python, Julia, R, and a bunch other languages.
