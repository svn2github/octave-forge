## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{rval}= {} cstrcmp(@var{string1},@var{string2})
## compares the  @var{string1} and @var{string2} like the C-library
## function, returning 0 on match, +1 if @var{string1} > @var{string2}
## and -1 if @var{string1} < @var{string2}.
## This operation is asymmetrical. If either @var{string1} or
## @var{string2} are cell-arrays (not both simultaneously), then the
## return value @var{rval} will be a similar cell-array of strings.
##
## @example
## @group
##           cstrcmp('marry','marie') 
##           ##returns value +1
## @end group
## @end example
## @end deftypefn
## @seealso {strcmp}
##


function rval=cstrcmp(s1,s2)
  if nargin < 2
    print_usage();
  end
  v1=iscell(s1);
  v2=iscell(s2);

  if (v1+v2) == 2;
    error(' Only one argument can be a cell-array; see help cstrcmp;');
  end

  if (v1+v2) == 0
    rval=do_cstrcmp(s1,s2);
    return;
  end

  if(v2)
    [s1,s2]=swap(s1,s2);
  end

  L=length(s1);
  rval=zeros(1,L);
  for idx=1:L
    rval(idx)=do_cstrcmp(s1{idx},s2);
  end

  return;
end
%!
%!assert(cstrcmp("hello","hello"),0,0)
%!assert(cstrcmp('marry','marie'),+1,0)
%!assert(cstrcmp('Matlab','Octave'),-1,0)
%!assert(cstrcmp('Matlab',{'Octave','Scilab','Lush','Yorick'}),[-1,-1,+1,-1],[])
%!assert(cstrcmp({'Octave','Scilab','Lush','Yorick'},'Matlab'),[+1,+1,-1,+1],[])
%!

function v=do_cstrcmp(s1,s2)
 L2=length(s2);
 L1=length(s1);
 L=min(L1,L2);
 for idx=1:L
   p=s1(idx);
    q=s2(idx);
    if ( p ~= q )
     v=sign(p-q);
     return
   end
 end
 v=sign(L1-L2);
 return	   
end
