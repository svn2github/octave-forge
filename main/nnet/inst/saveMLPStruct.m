## Copyright (C) 2005 Michel D. Schmid
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} saveMLPStruct (@var{net},@var{strFileName})
## @code{saveStruct} saves a neural network structure to *.txt files
##
## @example
##  noch nicht geschrieben
## @end example
##
##
## @noindent
## and
##
## @example
## noch nicht geschrieben
## @end example
##
## @noindent
## noch nicht geschrieben
## @end deftypefn

## Author: mds

function saveMLPStruct(net,strFileName)

  ## the variable net holds the neural network structure..
  # check if it is structure type
  if !isstruct(net)
    error("net is not of the type structure!")
  endif

  # open the first level file
  fid1 = fopen(strFileName,"w+t","ieee-le");

  if (fid1 < 0)
    error ("Can not open %s", strFileName);
  endif

  ## print header
  try
    printMLPHeader(fid1);
  catch
    ## Add saveMLPStructure directory to the path and try again
    addpath ([fileparts(mfilename()),"/saveMLPStructure"]);
    printMLPHeader(fid1);
  end_try_catch
  
  ## check for field "numInputs"
  printNumInputs(fid1,net);

  ## check for field "numLayers"
  printNumLayers(fid1,net)

  ## check for field "biasConnect"
  printBiasConnect(fid1,net)
  
  ## check for field "inputConnect"
  printInputConnect(fid1,net)
  
  ## check for field "layerConnect"
  printLayerConnect(fid1,net)
  
  ## check for field "outputConnect"
  printOutputConnect(fid1,net)
  
  ## check for field "targetConnect"
  printTargetConnect(fid1,net)
  
  ## print one empty line
  fprintf(fid1,"\n");

  ## check for numOutputs
  printNumOutputs(fid1,net);
  
  ## check for numTargets
  printNumTargets(fid1,net);
  
  ## check for numInputDelays
  printNumInputDelays(fid1,net);
  
  ## check for numLayerDelays
  printNumLayerDelays(fid1,net);
  
  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print subobject structures:
  fprintf(fid1,"  subobject structures:\n");
  
  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print inputs
  printInputs(fid1,net);
  
  ## print layers
  printLayers(fid1,net);
  
  ## print outputs
  printOutputs(fid1,net);
  
  ## print targets
  printTargets(fid1,net);
  
  ## print biases
  printBiases(fid1,net);
  
  ## print inputweights
  printInputWeights(fid1,net);
  
  ## print layerweights
  printLayerWeights(fid1,net);
  
  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print subobject structures:
  fprintf(fid1,"  functions:\n");

  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print adaptFcn
  printAdaptFcn(fid1,net);
  
  ## print initFcn
  printInitFcn(fid1,net);
  
  ## print performFcn
  printPerformFcn(fid1,net);
  
  ## print performFcn
  printTrainFcn(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");

  ## print subobject structures:
  fprintf(fid1,"  parameters:\n");
  
  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print adaptParam
  printAdaptParam(fid1,net);
  
  ## print initParam
  printInitParam(fid1,net);
  
  ## print performParam
  printPerformParam(fid1,net);
  
  ## print trainParam
  printTrainParam(fid1,net);

  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print subobject structures:
  fprintf(fid1,"  weight & bias values:\n");
  
  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print IW
  printIW(fid1,net);
  
  ## print LW
  printLW(fid1,net);
  
  ## print b
  printB(fid1,net);
  
  ## print one empty line
  fprintf(fid1,"\n");
  
  ## print subobject structures:
  fprintf(fid1,"  other:\n");


  fclose(fid1);

endfunction
