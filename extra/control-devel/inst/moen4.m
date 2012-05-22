## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{sys}, @var{x0}, @var{info}] =} moen4 (@var{dat}, @dots{})
## @deftypefnx {Function File} {[@var{sys}, @var{x0}, @var{info}] =} moen4 (@var{dat}, @var{n}, @dots{})
## @deftypefnx {Function File} {[@var{sys}, @var{x0}, @var{info}] =} moen4 (@var{dat}, @var{opt}, @dots{})
## @deftypefnx {Function File} {[@var{sys}, @var{x0}, @var{info}] =} moen4 (@var{dat}, @var{n}, @var{opt}, @dots{})
## Combined method:  MOESP  algorithm for finding the
## matrices A and C, and  N4SID  algorithm for
## finding the matrices B and D.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2012
## Version: 0.1

function [sys, x0, info] = moen4 (varargin)

  if (nargin == 0)
    print_usage ();
  endif

  [sys, x0, info] = __slicot_identification__ ("moen4", varargin{:});

endfunction


%!shared SYS, X0, INFO, Ae, Be, Ce, De, Ke, Qe, Rye, Se, X0e
%!
%! Y = [ 4.7661   5.5451   5.8503   5.3766   4.8833   5.4865   3.5378   5.3155   6.0530   4.3729
%!       4.7637   5.1886   5.9236   5.6818   4.8858   5.1495   3.5549   5.5329   6.0799   4.7417
%!       4.8394   4.8833   5.9212   5.8235   4.8931   4.8442   3.4938   5.4450   6.1287   5.0884
%!       5.0030   4.6000   5.9773   5.9529   4.7148   4.5414   3.4474   5.3961   6.0799   5.1861
%!       5.0176   4.2704   5.7405   6.0628   4.4511   4.2679   3.4401   5.2740   6.1678   5.0372
%!       5.0567   4.0384   5.3888   6.0897   4.2337   4.0604   3.4083   5.0274   6.1947   4.7856
%!       5.1544   3.8381   5.0005   6.0750   4.0433   3.9602   3.4108   4.7441   6.2362   4.5634
%!       5.3619   3.7112   4.8491   6.0262   3.8650   3.7893   3.4523   4.6684   6.0530   4.5341
%!       5.4254   3.5915   4.9444   5.9944   3.7576   3.6428   3.6818   4.6513   5.6525   4.7050
%!       5.5695   3.5353   5.1739   6.0775   3.6696   3.5256   4.0604   4.5146   5.2740   4.7417
%!       5.6818   3.4865   5.3693   5.8577   3.5939   3.4987   4.4413   4.2679   4.8589   4.6489
%!       5.7429   3.4767   5.4474   5.7014   3.5475   3.4547   4.8540   4.2606   4.5341   4.4315
%!       5.8039   3.4254   5.6037   5.7307   3.5060   3.4083   5.1544   4.2630   4.4560   4.2386
%!       5.9187   3.3815   5.7307   5.7844   3.4547   3.3790   5.4254   4.1898   4.6196   4.0652
%!       5.8210   3.3693   5.8503   5.8235   3.3986   3.3766   5.5964   4.2777   4.8662   3.9431
%!       5.4474   3.3644   5.9798   5.8943   3.3619   3.3619   5.5866   4.6000   5.1177   3.8113
%!       5.0616   3.3473   5.9920   5.7624   3.3400   3.3595   5.3546   4.9322   5.1666   3.6916
%!       4.6293   3.3815   6.0848   5.4157   3.3742   3.3693   5.0274   5.2838   5.0567   3.6525
%!       4.2679   3.4206   5.9407   4.9615   3.5207   3.3986   4.8638   5.5280   5.0030   3.8259
%!       4.0115   3.4132   5.8039   4.5952   3.7136   3.5793   4.7612   5.7405   5.0982   4.2240
%!       3.8503   3.4523   5.7917   4.3314   3.7576   3.9480   4.5707   5.8748   5.3253   4.4242
%!       3.7112   3.6355   5.6037   4.2972   3.7795   4.4120   4.3681   5.9554   5.5671   4.4291
%!       3.5695   4.0384   5.2643   4.5829   3.6965   4.5854   4.3974   5.9920   5.4670   4.3192
%!       3.5182   4.3754   4.9468   4.8613   3.7771   4.5146   4.5732   5.8455   5.2521   4.1385
%!       3.6525   4.7270   4.6196   5.1739   3.8870   4.3436   4.8418   5.5280   4.9468   3.9651
%!       3.8186   5.0567   4.5146   5.1666   3.9041   4.1556   5.2032   5.0616   4.8809   3.8870
%!       3.8626   5.2985   4.4340   4.9199   3.8503   3.9847   5.4523   4.7344   4.9810   3.8015
%!       4.0115   5.5329   4.2850   4.6074   3.9651   4.0433   5.6525   4.5341   5.2252   3.7014
%!       4.3534   5.4670   4.1214   4.3705   4.2826   4.3070   5.8552   4.5341   5.4596   3.6403
%!       4.7050   5.1959   3.9456   4.1825   4.5219   4.4218   5.9065   4.6977   5.7234   3.7673
%!       5.0836   4.8858   3.9847   4.0384   4.7148   4.3534   5.9529   4.7441   5.7917   4.1507
%!       5.3449   4.7637   4.2191   4.1458   4.9712   4.2240   5.8284   4.6196   5.9065   4.6489
%!       5.2740   4.8760   4.5463   4.4315   5.2203   4.0530   5.7917   4.6440   5.9920   4.9908
%!       5.1275   5.0420   4.8735   4.5561   5.5329   3.9407   5.7991   4.8320   5.8357   5.0884
%!       4.7612   5.2838   5.1544   4.4804   5.6525   3.8381   5.8137   5.1324   5.5280   5.0225
%!       4.4511   5.4914   5.3888   4.3754   5.7820   3.7307   5.8772   5.4108   5.1422   4.7832
%!       4.2215   5.5964   5.6135   4.3705   5.9554   3.6525   5.9554   5.6257   4.7759   4.6855
%!       4.0457   5.6721   5.8357   4.5585   6.0359   3.6110   5.7820   5.6037   4.4902   4.6660
%!       3.8748   5.7722   5.8845   4.8589   6.1190   3.5646   5.5182   5.3155   4.2362   4.7075
%!       3.7307   5.8308   5.9554   4.8955   6.1336   3.4963   5.1275   4.9615   4.0237   4.9126
%!       3.6623   5.9334   5.7624   4.7417   6.1532   3.4621   4.7637   4.6196   3.8870   5.1959
%!       3.5768   5.8992   5.4596   4.7441   6.1922   3.4547   4.4926   4.3583   3.7527   5.4157
%!       3.5427   5.9358   5.0616   4.8760   6.1434   3.4254   4.2337   4.1556   3.6818   5.6232
%!       3.4792   5.8943   4.7075   5.1055   6.1678   3.3790   4.0115   4.0335   3.8064   5.7405
%!       3.4547   5.9187   4.4584   5.2398   5.9920   3.4328   3.8552   3.8870   4.1458   5.8992
%!       3.3595   5.9944   4.2679   5.5182   5.6525   3.6232   3.6916   3.7722   4.6000   5.9285
%!       3.2985   5.9578   4.0530   5.6525   5.4596   3.9749   3.6355   3.6403   5.0030   6.0506
%!       3.2252   6.0311   3.9431   5.7234   5.4376   4.3803   3.8186   3.5329   5.3033   6.1532
%!       3.2008   6.0628   3.8259   5.8552   5.3400   4.7148   4.1556   3.4352   5.5524   5.9651
%!       3.2252   6.0408   3.9676   5.9627   5.0982   5.0738   4.5903   3.4279   5.6159   5.5866
%!       3.2276   6.0970   4.2801   5.9847   4.7856   5.3693   4.9883   3.4230   5.5231   5.3815
%!       3.2740   6.1239   4.4804   5.9847   4.4926   5.6037   5.0762   3.3986   5.6110   5.3717
%!       3.4572   6.1629   4.4926   6.0555   4.2362   5.7453   4.9077   3.6037   5.7136   5.4865
%!       3.8674   6.0408   4.3900   6.0628   4.0677   5.6525   4.6489   4.0237   5.8455   5.5671
%!       4.3217   5.8455   4.1971   6.0555   3.9334   5.4010   4.3778   4.4511   5.8992   5.8210
%!       4.4926   5.7722   4.1116   6.0701   3.8235   5.0152   4.2166   4.7930   5.9944   5.9138
%!       4.4315   5.7991   3.9822   5.7844   3.7307   4.7099   4.2875   4.9029   6.0921   5.9944
%!       4.2435   5.9236   3.8674   5.4401   3.6110   4.4169   4.5903   4.7808   6.0921   6.0115
%!       4.0506   5.9285   3.7673   5.0567   3.5646   4.2362   4.8467   4.5903   6.1434   5.9993
%!       3.8577   6.0018   3.8723   4.9419   3.5500   4.2362   5.1397   4.3363   6.1532   6.0188
%!       3.7307   6.0018   4.2362   5.0103   3.5573   4.2484   5.3888   4.1458   6.2337   5.8210
%!       3.7917   6.0604   4.6635   5.1348   3.5134   4.2215   5.6892   4.2166   6.1873   5.7282
%!       3.9212   5.8821   4.9712   5.3131   3.5158   4.2972   5.8845   4.4340   6.0140   5.7405
%!       3.9554   5.5109   5.0665   5.4792   3.6941   4.5903   6.0433   4.7148   5.8357   5.7649
%!       3.8479   5.3229   4.9029   5.6232   4.0726   4.8931   6.1703   5.0982   5.7746   5.8821
%!       3.7258   5.3717   4.6757   5.5622   4.4804   5.1348   6.2118   5.3595   5.6867   5.9260
%!       3.6110   5.4547   4.3925   5.3302   4.7050   5.4279   6.2508   5.5695   5.5378   5.7502
%!       3.7160   5.4376   4.0994   5.0103   4.6123   5.3790   6.2093   5.7722   5.3278   5.4157
%!       4.0921   5.1593   4.1141   4.6660   4.3851   5.3644   6.0140   5.9212   5.0543   4.9956
%!       4.4804   4.9029   4.3265   4.4145   4.2020   5.4523   5.7014   6.0555   4.7002   4.8613
%!       4.8149   4.5878   4.6440   4.2020   4.0262   5.5671   5.4694   5.9627   4.3949   4.9029
%!       5.0543   4.5024   4.9712   4.0482   3.9041   5.6721   5.4792   5.6428   4.1800   5.1031
%!       5.3033   4.5952   5.1593   4.0799   3.7746   5.7698   5.5573   5.4352   4.0433   5.3644
%!       5.4865   4.8247   5.3888   4.1898   3.6916   5.8308   5.7282   5.3888   3.8772   5.5964
%!       5.6721   5.0640   5.5768   4.1312   3.8455   5.9236   5.8821   5.5378   3.7527   5.7527
%!       5.7795   5.2716   5.6525   4.0042   4.2020   5.9651   5.9847   5.6818   3.7282   5.8455
%!       5.7991   5.4670   5.8039   3.9163   4.5854   6.0579   5.9016   5.7014   3.8699   5.9285
%!       5.6648   5.6159   5.9138   3.9602   4.9029   6.0506   5.5817   5.6159   4.2069   6.0066
%!       5.2911   5.5280   5.8870   4.1996   5.2569   6.0726   5.3717   5.6672   4.3558   5.8406
%!       4.8809   5.2545   5.7991   4.6245   5.5109   6.1116   5.4181   5.7405   4.4267   5.5182
%!       4.5585   4.8833   5.7307   4.8833   5.6403   6.0701   5.5109   5.8039   4.4535   5.1739
%!       4.1849   4.5170   5.7624   5.1373   5.8430   5.8967   5.6672   5.8821   4.5219   4.7392
%!       3.8894   4.1971   5.8137   5.3790   5.9749   5.7551   5.7917   5.9505   4.3925   4.4584
%!       3.7087   4.0018   5.8210   5.6232   5.9358   5.7185   5.6989   6.0726   4.1556   4.4267
%!       3.6232   3.8064   5.9285   5.7624   5.8210   5.8210   5.4840   6.1483   3.9651   4.6025
%!       3.5695   3.9041   6.0140   5.8333   5.5280   6.0018   5.1544   6.1165   3.8772   4.8223
%!       3.7185   3.9236   5.7649   5.6867   5.1715   6.0018   4.9810   6.1776   3.9700   5.1837
%!       4.0335   3.8699   5.4132   5.3668   4.8101   5.9016   5.0616   6.2020   4.2582   5.4303
%!       4.4120   3.8064   5.0982   5.2252   4.4535   5.5573   5.1959   6.2069   4.4218   5.6525
%!       4.6293   3.7209   4.6782   5.2398   4.3803   5.1739   5.3595   5.9920   4.3363   5.8210
%!       4.5585   3.8186   4.3729   5.3546   4.5659   4.8003   5.6159   5.5646   4.2997   5.7063
%!       4.3949   4.1409   4.3925   5.5085   4.8052   4.4315   5.7624   5.1788   4.3925   5.3693
%!       4.1800   4.5292   4.5903   5.5964   5.1251   4.1947   5.8577   4.9981   4.6757   5.0274
%!       4.1971   4.8052   4.9199   5.7527   5.3546   4.0066   5.9480   5.0518   4.7612   4.7050
%!       4.4315   5.0860   5.0176   5.8748   5.5891   3.8503   5.8357   5.2325   4.6587   4.4145
%!       4.7148   5.3400   4.8589   5.9065   5.7649   3.7478   5.7063   5.4840   4.4902   4.1458
%!       4.9615   5.5329   4.6757   5.8943   5.9236   3.6428   5.4987   5.6867   4.3070   3.9651
%!       5.3009   5.5768   4.6196   5.7429   5.9407   3.5915   5.1886   5.8992   4.1263   4.0335
%!       5.5671   5.6672   4.8345   5.4474   5.8577   3.5695   5.1177   5.8699   3.9724   4.3729
%!       5.6818   5.7917   5.0909   5.0250   5.6941   3.5280   5.1910   5.9773   4.0775   4.6831 ](:);
%!
%!
%!
%! U = [ 6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   3.4100
%!       3.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100
%!       6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100
%!       6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100
%!       6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100
%!       6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   6.4100
%!       6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100
%!       6.4100   3.4100   6.4100   3.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100
%!       6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100
%!       6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100
%!       3.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   3.4100
%!       3.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   3.4100
%!       3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   3.4100
%!       3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   3.4100
%!       3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   6.4100   6.4100
%!       3.4100   3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   6.4100   3.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   3.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   3.4100
%!       6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100
%!       3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100
%!       6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   3.4100   6.4100   3.4100
%!       6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   3.4100
%!       6.4100   3.4100   3.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100
%!       6.4100   6.4100   6.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   3.4100   3.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100
%!       3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100
%!       3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100   3.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   6.4100
%!       6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   6.4100
%!       6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100
%!       6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100
%!       6.4100   6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   3.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100   3.4100   6.4100
%!       3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100
%!       3.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   3.4100
%!       6.4100   3.4100   3.4100   3.4100   3.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100   3.4100
%!       6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100
%!       6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100
%!       3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100   3.4100
%!       3.4100   3.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100   6.4100   3.4100   3.4100
%!       3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100
%!       3.4100   3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100   6.4100
%!       6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100   6.4100
%!       6.4100   3.4100   3.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       6.4100   3.4100   3.4100   6.4100   3.4100   3.4100   6.4100   6.4100   3.4100   6.4100
%!       3.4100   3.4100   3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   6.4100
%!       3.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   3.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   3.4100
%!       3.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   6.4100   3.4100
%!       6.4100   6.4100   6.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   3.4100
%!       6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100
%!       6.4100   6.4100   3.4100   6.4100   6.4100   3.4100   3.4100   6.4100   3.4100   3.4100
%!       6.4100   6.4100   6.4100   3.4100   6.4100   3.4100   3.4100   6.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   3.4100   3.4100   6.4100   6.4100   3.4100   6.4100
%!       6.4100   6.4100   6.4100   3.4100   6.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   6.4100   3.4100   3.4100   6.4100   6.4100   6.4100   6.4100
%!       3.4100   6.4100   6.4100   3.4100   3.4100   3.4100   3.4100   6.4100   6.4100   6.4100 ](:);
%!
%!
%! DAT = iddata (Y, U);
%!
%! [SYS, X0, INFO] = moen4 (DAT, "s", 15, "rcond", 0.0, "tol", -1.0, "confirm", false);
%!
%! Ae = [  0.8924   0.3887   0.1285   0.1716
%!        -0.0837   0.6186  -0.6273  -0.4582
%!         0.0052   0.1307   0.6685  -0.6755
%!         0.0055   0.0734  -0.2148   0.4788 ];
%!
%! Ce = [ -0.4442   0.6663   0.3961   0.4102 ];
%!
%! Be = [ -0.2142
%!        -0.1968
%!         0.0525
%!         0.0361 ];
%! 
%! De = [ -0.0041 ];
%!
%! Ke = [ -1.9513
%!        -0.1867
%!         0.6348
%!        -0.3486 ];
%!
%! Qe = [  0.0052   0.0005  -0.0017   0.0009
%!         0.0005   0.0000  -0.0002   0.0001
%!        -0.0017  -0.0002   0.0006  -0.0003
%!         0.0009   0.0001  -0.0003   0.0002 ];
%!
%! Rye = [ 0.0012 ];
%!
%! Se = [ -0.0025
%!        -0.0002
%!         0.0008
%!        -0.0005 ];
%!
%! X0e = [ -11.496422
%!          -0.718576
%!          -0.014211
%!           0.500073 ];    # X0e is not from SLICOT
%!
%! ## The SLICOT test for IB01CD uses COMUSE=C, not COMUSE=U.
%! ## This means that they don't use the matrices B and D
%! ## computed by IB01BD.  They use only A and C from IB01BD,
%! ## while B and D are from SLICOT routine IB01CD.
%! ## Therefore they get slightly different matrices B and D
%! ## and finally a different initial state vector X0.
%!
%!assert (SYS.A, Ae, 1e-4);
%!assert (SYS.B, Be, 1e-4);
%!assert (SYS.C, Ce, 1e-4);
%!assert (SYS.D, De, 1e-4);
%!assert (INFO.K, Ke, 1e-4);
%!assert (INFO.Q, Qe, 1e-4);
%!assert (INFO.Ry, Rye, 1e-4);
%!assert (INFO.S, Se, 1e-4);
%!assert (X0, X0e, 1e-4);
