# Copyright (C) 1998,1999 Andy Adler
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#    This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#    You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# $Id$

# sphcat (x1,x2,x3,x4,x5)
# Concatenate sparse matrices, horizontally
# equivalent to: [x1,x2,x3,x4,x5]

function y=sphcat( varargin )
   ii=[]; jj=[];vv=[]; nnc=0; nnr=[];
   for i=1:length (varargin)
       [i,j,v,nr,nc]= spfind( varargin{i} );
       if isempty(nnr);
           nnr= nr;
       end
       if nnr ~= nr;
           error(sprintf(
               'error: number of columns must match (%d != %d)', nnr,nr ) );
       end
       ii= [ii;i];
       jj= [jj;j+nnc];
       vv= [vv;v];
       nnc= nnc+nc;
   end

   if isempty(nnc);
       y= [];
   else
       y= sparse(ii,jj,vv,nnr,nnc);
   end

endfunction
