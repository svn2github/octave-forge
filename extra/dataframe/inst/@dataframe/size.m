function [nrow, ncol] = size(df, varargin)
  %# function resu = end(df, varargin)
  %# This is size operator for a dataframe object.

  %% Copyright (C) 2009-2010 Pascal Dupuis <Pascal.Dupuis@uclouvain.be>
  %%
  %% This file is part of Octave.
  %%
  %% Octave is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 2, or (at your option) any later version.
  %%
  %% Octave is distributed in the hope that it will be useful,
  %% but WITHOUT ANY WARRANTY; without even the implied
  %% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  %% PURPOSE.  See the GNU General Public License for more
  %% details.
  %%
  %% You should have received a copy of the GNU General Public
  %% License along with Octave; see the file COPYING.  If not,
  %% write to the Free Software Foundation, 59 Temple Place -
  %% Suite 330, Boston, MA 02111-1307, USA.
  
  %#
  %# $Id: size.m 852 2010-07-22 10:47:55Z dupuis $
  %#

  switch nargin
    case 1
      switch nargout
	case {0 1}
	  nrow = df._cnt;
	case {2}
	  nrow = df._cnt(1); ncol = df._cnt(2);
	otherwise
	  error(print_usage());
      endswitch
    case 2
      switch nargout
	case {0 1}
	  nrow = df._cnt;
	  try
	    nrow = nrow(varargin{1});
	  catch
	    error(print_usage());
	  end_try_catch
	otherwise
	  error(print_usage());
      endswitch
    otherwise
      error(print_usage());
  endswitch

endfunction

function usage = print_usage()
  usage = strcat('Invalid call to size.  Correct usage is: ', ' ', ...
		  '-- Overloaded Function:  size (A, N)');
endfunction
