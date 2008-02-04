## Copyright (C) 2005 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
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
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{pn},@var{meanp},@var{stdp},@var{tn},@var{meant},@var{stdt}] =prestd(@var{p},@var{t})
## @code{prestd} preprocesses the data so that the mean is 0 and the standard deviation is 1.
## @end deftypefn

## @seealso{trastd}

## Author: Michel D. Schmid

function [pn,meanp,stdp,tn,meant,stdt] = prestd(Pp,Tt)

  ## inital description
  ## prestd(p,t)
  ##  * p are the general descriptions for the inputs of
  ##    neural networks
  ##  * t is written for "targets" and this are the outputs
  ##    of a neural network

  ## check range of input arguments
  error(nargchk(1,2,nargin))

  ## do first inputs
  meanp = mean(Pp')';
  stdp = std(Pp')';
  [nRows,nColumns]=size(Pp);
  rowOnes = ones(1,nColumns);

  ## now set all standard deviations which are zero to 1
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
  
  ## calculate the standardized inputs
  pn = (Pp-meanpZero*rowOnes)./(stdpZero*rowOnes);

  ## do also targets
  if ( nargin==2 )
    meant = mean(Tt')';
    stdt = std(Tt')';

    ## now set all standard deviations which are zero to 1
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

    ## calculate the standardized targets
    tn = (Tt-meantZero*rowOnes)./(stdtZero*rowOnes);
  endif
  
endfunction