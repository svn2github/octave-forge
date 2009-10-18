## Copyright (C) 2009   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Block diagonal concatenation of two LTI models.
## This file is part of the Model Abstraction Layer.
## For internal use only.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: September 2009
## Version: 0.1

function retlti = __ltigroup__ (lti1, lti2)

  retlti = lti ();

  retlti.inname = [lti1.inname;
                   lti2.inname];

  retlti.outname = [lti1.outname;
                    lti2.outname];

  if (lti1.tsam == lti2.tsam)
    retlti.tsam = lti1.tsam;
  elseif (lti1.tsam == -1)
    retlti.tsam = lti2.tsam;
  elseif (lti2.tsam == -1)
    retlti.tsam = lti1.tsam;
  else
    error ("ltigroup: systems must have identical sampling times");
  endif

endfunction