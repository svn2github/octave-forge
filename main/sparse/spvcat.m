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

# spvcat (x1,x2,x3,x4,x5)
# Concatenate sparse matrices, vertically
# equivalent to: [x1;x2;x3;x4;x5]

function y=spvcat( varargin )
   ii=[]; jj=[];vv=[]; nnr=0; nnc=[];
   for i=1:length (varargin)
       [i,j,v,nr,nc]= spfind( varargin{i} );
       if isempty(nnc);
           nnc= nc;
       end
       if nnc ~= nc;
           error(sprintf(
               'error: number of columns must match (%d != %d)', nnc,nc ) );
       end
       ii= [ii;i+nnr];
       jj= [jj;j];
       vv= [vv;v];
       nnr= nnr+nr;
   end

   if isempty(nnc);
       y= [];
   else
       y= sparse(ii,jj,vv,nnr,nnc);
   end

endfunction
