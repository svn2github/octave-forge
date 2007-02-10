## Copyright (C) 2007 Python Code Generator 
##
## -- WARNING -- Autogenerated  - DONOT EDIT -
##
## This code is released under GPL
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{Val},@var{unit},@var{uncertanity}] {} PROTON_GYROMAGN_RATIO() 
## Returns the proton gyromagn. ratio
## . Val=267522205e8  Units=s^-1 T^-1 Uncertanity=0.00000023e8. 
## @var{Val} is actual value of the constant.
## @var{Unit} is a Units string.
## @var{uncertanity} is +/- value to constant.
##
## Autogenerated on Sat Feb 10 02:48:24 2007
## from NIST database at  http://physics.nist.gov/constants 
## @end deftypefn

## Fundamental Physical Constants --- Complete Listing
## From:  http://physics.nist.gov/constants
## Source: Peter J. Mohr and Barry N. Taylor, CODATA Recommended Values of the 
## Fundamental Physical Constants: 2002, published in Rev. Mod. Phys.
## vol. 77(1) 1-107 (2005).
## Taken from: physics.nist.gov/cuu/Constants/Table/allascii.txt
##
    
function [Val,Unit,Uncertanity]=PROTON_GYROMAGN_RATIO()
	 Val = 267522205e8; 
	 Units = "s^-1 T^-1";
	 Uncertanity = 0.00000023e8;
endfunction
%
%!assert(PROTON_GYROMAGN_RATIO,267522205e8,eps)
%
