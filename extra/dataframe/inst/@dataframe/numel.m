function n = numel(df, varargin)
  %# function resu = end(df, varargin)
  %# This is the numel operator for a dataframe object, returning the
  %# product of the  number of rows by the number of columns

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
  %# $Id: numel.m 981 2010-07-26 16:23:08Z dupuis $
  %#

if 1 == nargin,
  n = prod(df._cnt([1 end]));
else
  error(print_usage());
endif

endfunction

function usage = print_usage()
  usage = strcat('Invalid call to numel.  Correct usage is: ', ' ', ...
		  '-- Overloaded Function:  numel (A)');
endfunction
