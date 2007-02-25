## Copyright (C) 2006 Michel D. Schmid   <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{Pp},@var{Tt}] = poststd(@var{Pn},@var{meanp},,@var{stdP},@var{Tn},@var{meanT},@var{stdT})
## @code{poststd} postprocesses the data which has been preprocessed by @code{prestd}.
## @end deftypefn

## @seealso{prestd,trastd}

## Author: Michel D. Schmid <michaelschmid@users.sourceforge.net>
## $LastChangedDate: 2006-08-20 21:47:51 +0200 (Sun, 20 Aug 2006) $
## $Rev: 38 $

function [Pp,Tt] = poststd(Pn,meanp,stdp,Tn,meant,stdt)

  ## check range of input arguments
  error(nargchk(3,3,nargin)) | error(nargchk(6,6,nargin))

  ## do first inputs
  ## set all standard deviations which are zero to 1
  [nRowsII, nColumnsII] = size(stdp);
  rowZeros = zeros(nRowsII,1);
  findZeros = find(stdp==0);
  rowZeros(findZeros)=1;
  equal = rowZeros;
  nequal = !equal;
  if (sum(equal) != 0)
    warning("Some standard deviations are zero. Those inputs won't be transformed.");
    meanpZero = meanp.*nequal;
    stdpZero = stdp.*nequal + 1*equal;
  else
    meanpZero = meanp;
    stdpZero = stdp;
  endif
  
  ## calculate the postprocessed inputs
  nColumnsIIone = ones(1,nColumnsII);
  Pp = (stdpZero*nColumnsIIone).*Pn + meanpZero*nColumnsIIone;

  ## do also targets
  if ( nargin==6 )
    # now set all standard deviations which are zero to 1
    [nRowsIII, nColumnsIII] = size(stdt);
    rowZeros = zeros(nRowsIII,1);
    findZeros = find(stdt==0);
    rowZeros(findZeros)=1;
    equal = rowZeros;
    nequal = !equal;
    if (sum(equal) != 0)
      warning("Some standard deviations are zero. Those targets won't be transformed.");
      meantZero = meant.*nequal;
      stdtZero = stdt.*nequal + 1*equal;
    else
      meantZero = meant;
      stdtZero = stdt;
    endif

    ## calculate the postprocessed targets
    nColumnsIIIone = ones(1,nColumnsIII);
    Tt = (stdtZero*nColumnsIIIone).*Tn + meantZero*nColumnsIIIone;
  endif

endfunction