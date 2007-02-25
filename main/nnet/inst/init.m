## Copyright (C) 2005 Michel D. Schmid   <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {} @var{net} = init (@var{net})
## @code{init} initializes a neural network. This will be done
## with the function @code{rand} from octave.
##
## @example
## net = init(net);
## @end example
##
## This function takes the octave function "rand" to init the 
## neural network weights.
##
## @noindent
## @end deftypefn

## @seealso{}

## Author: Michel D. Schmid <michaelschmid@users.sourceforge.net>
## $LastChangedDate: 2006-08-20 21:47:51 +0200 (Sun, 20 Aug 2006) $
## $Rev: 38 $
function net=init(net)

  ## check number of inputs
  error(nargchk(1,1,nargin));

  ## check input
  if ( !isstruct(net) )
    error("init: wrong argument type, must be a structure!");
  endif

  ## init with random numbers between +-1
  ## input weight layer
  mRand = rand(net.layers{1}.size,net.inputs{1}.size);
  net.IW{1} = mRand*2-1;

  ## hidden layers
  nLayers = net.numLayers;
  for i=2:nLayers
    mRand = rand(net.layers{i}.size,net.layers{i-1}.size);
    net.LW{i,i-1} = mRand*2-1;
  endfor
  for i=1:nLayers
    mRand = rand(net.biases{i}.size,1);
    net.b{i} = mRand*2-1;
  endfor

  ## warn user of constant inputs
  for i=1:net.numInputs
    prange = net.inputs{i}.range;
    if (any(prange(:,1) == prange(:,2)))
      fprintf("\n")
      fprintf("** Warning in INIT\n")
      fprintf("** Network net.inputs{%g}.range has a row with equal min and max values.\n",i)
      fprintf("** Constant inputs do not provide useful information.\n")
      fprintf("\n")
    end
  end

endfunction