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
## @deftypefn {Function File} [@var{Val},@var{unit},@var{uncertanity}] {} KELVIN_ELECTRON_VOLT() 
## Returns the kelvin-electron volt relationship
## . Val=8617343e-5  Units=eV Uncertanity=0.000015e-5. 
## @var{Val} is actual value of the constant.
## @var{Unit} is a Units string.
## @var{uncertanity} is +/- value to constant.
##
## Autogenerated on Sat Feb 10 02:48:25 2007
## from NIST database at  http://physics.nist.gov/constants 
## @end deftypefn

## Fundamental Physical Constants --- Complete Listing
## From:  http://physics.nist.gov/constants
## Source: Peter J. Mohr and Barry N. Taylor, CODATA Recommended Values of the 
## Fundamental Physical Constants: 2002, published in Rev. Mod. Phys.
## vol. 77(1) 1-107 (2005).
## Taken from: physics.nist.gov/cuu/Constants/Table/allascii.txt
##
    
function [Val,Unit,Uncertanity]=KELVIN_ELECTRON_VOLT()
	 Val = 8617343e-5; 
	 Units = "eV";
	 Uncertanity = 0.000015e-5;
endfunction
%
%!assert(KELVIN_ELECTRON_VOLT,8617343e-5,eps)
%
