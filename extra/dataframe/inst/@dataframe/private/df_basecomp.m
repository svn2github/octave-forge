function [A, B, C] = df_basecomp(A, B);

  %# function [A, B, C] = df_basecomp(A, B)
  %# Basic size and metadata compatibility verifications for
  %# two-arguments operations on dataframe. Returns a scalar, a matrix,
  %# or a dataframe. Cell arrays are converted to df. Third output
  %# contains a merge of the metadata.

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
  %# $Id$
  %#

  if !(isscalar(A) || isscalar(B))
    if (iscell(A)), A = dataframe(A); endif
    if (iscell(B)), B = dataframe(B); endif
    
    if (any(size(A) - size(B))),
      %# disp([size(A) size(B)])
      error("Non compatible sizes");
    endif
   
    if (isa(A, 'dataframe')) 
      if (nargout > 2), C = df_allmeta(A); endif         
      if (isa(B, 'dataframe')),
	%# compare indexes if both exist
	if (!isempty(A._ridx))
	  if (!isempty(B._ridx))
	    if (any(A._ridx-B._ridx)),
	      error("Non compatible indexes");
	    endif
	  endif
	else
	  if (nargout > 2), C._ridx = B._ridx; endif
	endif
	
	if (!isempty(A._name{1})) 
	  if (!isempty(B._name{1}))
	    if (!any(strcmp(cellstr(A._name{1}), cellstr(B._name{1})))),
	      error("Incompatible row names");
	    endif
	  endif
	else
	  if (nargout > 2), 
	    C._name{1} = B._name{1}; C._over{1} = B._over{1};
	  endif
	endif
	
	if (!isempty(A._name{2}))
	  if (!isempty(B._name{2}))
	    if (!any(strcmp(cellstr(A._name{2}), cellstr(B._name{2})))),
	      error("Incompatible column names");
	    endif
	  endif
	else
	  if (nargout > 2), 
	    C._name{2} = B._name{2}; C._over{2} = B._over{2}; 
	  endif
	endif
	
	if (isempty(A._src) && nargout > 2), 
	  C._src = B._src;
	endif
      endif
    else
      if (nargout > 2), C = df_allmeta(B); endif         
    endif
  else
    if (isa(A, 'dataframe')) 
      if (nargout > 2), C = df_allmeta(A); endif         
    else
      if (nargout > 2), C = df_allmeta(B); endif    
    endif
  endif

endfunction
