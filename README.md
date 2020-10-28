# lhs-prcc-modified
This is a Matlab/Octave script for (Latin Hypercube Sampling-Partial Rank Correlation Coefficient) **LHS-PRCC** uncertainty and sensitivity analysis modified from 
[**http://malthus.micro.med.umich.edu/lab/usadata/**](http://malthus.micro.med.umich.edu/lab/usadata/)
## Modifications:
1. **Model_LHS.m** (Main file): 
A more concise initialization of parameters, variables, and function calling. PRCC.m and PRCC_PLOT.m are called.
The significant parameters and their values are displayed in the Command Window.
![Image of Output Results](https://github.com/BagaskaraPutra/lhs-prcc-modified/blob/master/figures/outputFigure.PNG)
1. **config.txt**: Contains parameter & and state variable names for easier indexing and calling.
1. **PRCCconfig.txt**: Contains parameter (minimum, baseline, maximum) and initial state values.
![Image of Config Contents](https://github.com/BagaskaraPutra/lhs-prcc-modified/blob/master/figures/configContents.PNG)
1. **ODE_LHS.m**: ODE function with parameter & variable indexing from config.txt
1. **loadModel.m**: Function to load model from config.txt
1. **loadPRCCconfig.m**: Function to load from PRCCconfig.txt
1. **extractCharBetween.m**: Function to extract substring between two specified characters from a string.
1. **getHeaderContentIndex.m**: Function to get the content index range of a header in a config file.\
\
Further documentation can be accessed from the [**original source**](http://malthus.micro.med.umich.edu/lab/usadata/).

## References:
1. Marino, Simeone & Hogue, Ian & Ray, Christian & Kirschner, Denise. (2008). 
A Methodology For Performing Global Uncertainty And Sensitivity Analysis In Systems Biology. 
Journal of Theoretical Biology. 254. 178-196. 10.1016/j.jtbi.2008.04.011.
1. [**http://malthus.micro.med.umich.edu/lab/usadata/**](http://malthus.micro.med.umich.edu/lab/usadata/)

