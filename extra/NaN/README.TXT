NaN-Tb: A statistics toolbox 
------------------------------------------------------------
Copyright (C) 2000-2004 Alois Schloegl <a.schloegl@ieee.org>


FEATURES of the NaN-tb:
-----------------------
 - implements statistical tools
 - NaN's are treated as missing values 
 - less but more powerful functions (no nan-FUN needed)
 - fixes known bugs 
 - compatible to Matlab and Octave
 - easy to use
 - supports DIM argument 
 - supports unbiased estimation; 
 - The toolbox was tested with
   Matlab 5.2, 5.3, 6.1, 6.5 and Octave 2.0.14, 2.0.16.92, 2.1.35-40, 2.1.50
 
 
Currently are implemented:
-------------------------- 
	SUMSKIPNAN 	SUM is a built-in function and cannot not be replaced, 
			For this reason, a different name (than SUM) had to be chosen. 
			SUMSKIPNAN is central, it implements skipping NaN's, the 
			DIM-argument and returns the number of valid elements, too.
	MEAN	 	mean (options: arithmetic, geometric, harmonic)
	SEM		standard error of the mean (does not depend on distribution)
	VAR 		variance
	STD 		standard deviation
	MEDIAN		median (currently only for 2-dim matrices)
	MEANSQ		mean square
	RMS		root mean square
	STATISTIC	estimates various statistics at once
	MOMENT		moment 	
	SKEWNESS	skewness
	KURTOSIS	excess 
	MAD		mean absolute deviation
	CENTER		removes mean
	ZSCORE		normalizes x with z = (x-mean)/std 
	HARMMEAN	harmonic mean
	GEOMEAN		geometric mean
	NANTEST		checks whether all functions have been replaced
	DETREND		detrending of data with missing values and non-equidistant sampled data
	COVM		covariance estimation (several modes)
	COR		correlation matrix
	CORRCOEF	correlation coefficient, inluding rank correlation, 
				significance test and confidence intervals 
	SPEARMAN, RANKCORR spearman's rank correlation coefficient. They might be replaced by CORRCOEF. 
	COV		covariance matrix
	RANKS		calculates ranks for non-parametric statistics 
	TRIMEAN		trimean
	QUANTILE	q-th quantile 
	PERCENTILE	p-th percentile
	NORMPDF		normal probability distribution
	NORMCDF		normal cumulative distribution 
	NORMINV		inverse of the normal cumulative distribution
	TPDF		student probability distribution
	TCDF		student cumulative distribution 
	TINV		inverse of the student cumulative distribution
	NANSUM, NANSTD	fixes for buggy versions included
	MOD		modulus 
	REM		remainder
		
	
REFERENCE(S):
----------------------------------
[1] http://www.itl.nist.gov/
[2] http://mathworld.wolfram.com/


What is the difference to previous implementations?
===================================================
1) The default behavior of previous implementations is that NaNs in the input 
data results in NaNs in the output data. In many applications is this behavior 
quite borring. In this implementation, NaNs are handled as missing values and 
are skipped. 

2) In previous implementations the workaround was using different functions 
like NANSUM, NANMEAN etc. In this toolbox, the same routines can be applied to
data with and without NaNs. This enables more natural (better read- and 
understandable) applications. 

3) SUMSKIPNAN is central to the other functions. 
It implements 
- the DIMENSION-argument, 
- handles NaNs as missing values or as exception signal (depending on a 
  hidden FLAG), 
- and returns the number of valid elements (which are not NaNs) in the 
  second output argument.
(Note, NANSUM from Matlab does not support the DIM-argument, and NANSUM(NaN)
gives NaN instead of 0);

4) Defining the estimation mode (biased or unbiased) 
This feature is removed. 
Unbiased estimates are provided.

5) The DIMENSION argument is implemented in most routines. 
These should work in all Matlab and Octave versions. A workaround for a bug in 
Octave versions <=2.1.35 is implemented. Also several functions from Matlab 
have no support for the DIM argument (e.g. SKEWNESS, KURTOSIS, VAR)

6) Compatible to previous Octave implementation
MEAN implements also the GEOMETRIC and HARMONIC mean. Handling of some special 
cases has been removed because its not necessary, anymore. 
MOMENT implements Mode 'ac' (absolute and/or central) moment as implemented
in Octave. 

7) Performance increase
In most numerical applications, NaN's should be simply skipped. Therefore, 
it is efficient to skip NaN's in the default case. 
In case an explicit check for NaN's is necessary, implicit exception 
handling could be avoided. Eventually the overall performance could increase. 

8) More readable code
An explicit check for NaN's display the importance of this special case. 
Therefore, the application program might be more readable.

9) ZSCORE, MAD, HARMMEAN and GEOMEAN
DIM-argument and skipping of NaN's implemented. None of these features is
implemented in the Matlab versions.

10a) NANMEAN, NANVAR, NANMEDIAN
These are not necessary anymore. They are implemented in SUMSKIPNAN, MEAN, 
VAR, STD and MEDIAN, respectively. 

10b) NANSUM, NANSTD
These functions are obsolete, too. However, previous implementations 
do not always provide the expected result. Therefore, a correct
version is included for backward compatibility. 

11) GPL license
Permits to implement useful modifications. 

12) NORMPDF, NORMCDF, NORMINV
In the Matlab statistics toolbox V 3.0, NORMPDF, NORMCDF and NORMINV give 
incorrect results for SIGMA=0; A Similar problem was observed in Octave 
with NORMAL_INV, NORMAL_PDF, and NORMALCDF. 

The problem is fixed with this version. Furthermore, the check of the input 
arguments is implemented simpler and easier in this versions. 

13) TPDF, TCDF, TINV
In the Matlab statistics toolbox V3.0(12.1) and V4.0(13), TCDF and TINV do not handle NaNs 
correctly. TINV returns 0 instead of NaN, TCDF stops with an error message. 
In Stats-tb V2.2(R11) TINV has also the same problem.

For these reasons, the NaN-tb is a bug fix. Furthermore, the check of the input 
arguments is implemented simpler. Overall, the code is cleaner and leaner. 


Q: WHY SKIPPING NaN's?:
------------------------
A: Usually, NaN means that the value is not available. This meaning is most 
common, even many different reasons might cause NaN's. In statistics, NaN's 
represent missing values, in biosignal processing such missing values might 
have been caused by some recording error. Other reasons for NaN's are, 
indetermined expressions like e.g. 0/0, data not available, unknown value, 
not a numeric value, etc. 

If NaN has the meaning of a missing value, it is only consequent to say, the 
sum of NaN's should be zero. Similar arguments hold for the other functions. 
The mean of X is undefined if and only if X contains no numbers. The 
implementation sum(X)/sum(~isnan(X)) gives 0/0=NaN, which is the desired 
result. The variance of X is undefined if and only if X contains less than 
2 numbers.  

In most numerical applications, NaN's should be simply skipped. Therefore, 
it is efficient to skip NaN's in the default case. In the other cases, the 
NaN's can still be checked explicitely. This could eventually result in a 
more readable code and in improved performance, too.  


Installing the NaN-tb with Octave:
----------------------------------
a) You need repmat.m (e.g. from P.Kienzle's MATCOMPAT) 
    If you havenot installed it yet, you should do it now. 

b) extract files from NaNnnn.tar.gz and move them into 
.../octave/.../m/statistics/base/ 

c) Alternatively, the files can be moved into any other directory; but you 
must remove from .../octave/.../m/statistics/base/ 
mean.m, meansq.m, median.m, moment.m, skewness.m, kurtosis.m, std.m, var.m
and from .../source_forge/.../statistics/*
zscore.m, mad.m, geomean.m, harmmean.m 

d) (re-)start Octave and run NANINSTTEST. 
This checks whether all previous functions have been replaced


Installing the NaN-tb for Matlab:
----------------------------------
Ensure that the NaN-directory is first in your path. This should override any 
alternative function definition (except built-in's) with the same name. 

(re-)start Matlab or clear functions and run NANINSTTEST. 
This checks whether all previous functions have been replaced


	$Revision$
	$Id$
	Version 1.53 	Date: 31 Oct 2003
	Copyright (C) 2000-2004 by  Alois Schloegl <a.schloegl@ieee.org>	
	WWW: http://www.dpmi.tu-graz.ac.at/~schloegl/matlab/NaN/


LICENSE:
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
