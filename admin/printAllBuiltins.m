## Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

# This scripts prints all builtin functions in a plain text file named builtin.txt
# Global variables and private functions are placed in globalvar.txt and private.txt
# respectively. Octave functions are placed in functions.txt

1;
function printfunc (file, x)
  fprintf (file, "'%s', ", x);
endfunction

function y = isglobalvar (x)
  y = strcmp (toupper (x),x);
endfunction

function y = isprivfun (x)
  try
   y = strcmp (x(1:2),'__');
  catch "Octave:index-out-of-bounds";
   y = false;
  end
endfunction

builtinfun = __builtins__;

idx    = cellfun (@isglobalvar, builtinfun);
glovar = builtinfun(idx);
builtinfun(idx) = [];

idx    = cellfun (@isprivfun, builtinfun);
privfun = builtinfun(idx);
builtinfun(idx) = [];

fid = fopen ('builtin.txt','w');
cellfun (@(x)printfunc (fid,x), builtinfun);
fclose (fid);

fid = fopen ('globalvar.txt','w');
cellfun (@(x)printfunc (fid,x), glovar);
fclose (fid);

fid = fopen ('private.txt','w');
cellfun (@(x)printfunc (fid,x), privfun);
fclose (fid);

pkg unload all
octfun = __list_functions__;
idx    = cellfun (@isprivfun, octfun);
privfun = octfun(idx);
octfun(idx) = [];

fid = fopen ('functions.txt','w');
cellfun (@(x)printfunc (fid,x), octfun);
fclose (fid);
fid = fopen ('fun_private.txt','w');
cellfun (@(x)printfunc (fid,x), privfun);
fclose (fid);

keywords = __keywords__;
fid = fopen ('keywords.txt','w');
cellfun (@(x)printfunc (fid,x), keywords);
fclose (fid);

op = __operators__;
fid = fopen ('operators.txt','w');
cellfun (@(x)printfunc (fid,x), op);
fclose (fid);

clear all
