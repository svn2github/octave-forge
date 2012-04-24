## Copyright (C) 2012 Markus Bergholz <markuman at gmail dot com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} textable (@var{matrix}, @var{texfile})
## @deftypefnx {Function File} {} textable (@var{matrix}, @var{texfile}, @var{rlines})
## @deftypefnx {Function File} {} textable (@var{matrix}, @var{texfile}, @var{rlines}, @var{clines})
## @deftypefnx {Function File} {} textable (@var{matrix}, @var{texfile}, @var{rlines}, @var{clines}, @var{alignment})
## @deftypefnx {Function File} {} textable (@var{matrix}, @var{texfile}, @var{rlines}, @var{clines}, @var{alignment}, @var{matrixformat})
## Save matrix in Latex table (tabular) format.
##
## The generated latex file can be inserted in any latex document by using the
## @code{\input@{latex file name without .tex@}} statement.
##
## Allowed values:
## @itemize @bullet
## @item @var{matrix}: your matrix. doesn't matter if it comes from variable or not.
## @item @var{texfile}: location where you want to save your .tex file.
## @item @var{rlines}: 0 (false), 1 (true [default])
## @item @var{clines}: 0 (false), 1 (true [default])
## @item @var{alignment}: 0 (center), 1 (left), 2 (right [default])
## @item @var{matrixformat}: 0 [default], 1 [forces all other values to false/0]
## @end itemize
##
## The following example creates a LaTeX code with rows and columns lines and
## right alignment (default values).
##
## @example
## @group
## textable ([1 4; 7.5 2], "example.tex")
##
## ## will save on the example.tex file
## \begin@{tabular@}@{|r|r|@}
## \hline 
## 1 & 4 \\ 
## \hline 
## 7.5 & 2 \\ 
## \hline 
## \end@{tabular@}
## @end group
## @end example
##
## Creates a table from matrix A without rows lines, without columns lines and
## with center alignment:
## @example
## @group
## textable(A, "my-A-Matrix.tex",0,0,0)
## @end group
## @end example
##
##
## Creates a table from a random matrix without rows lines, but with columns
## lines and with left alignment:
## @example
## @group
## textable(rand(3,3), 'amazing-random-table.tex',0,1,1)
## @end group
## @end example
##
## @seealso{csv2latex, publish}
## @end deftypefn

## rlines = row lines = \hline
## clines = column lines = |
## alignment = center, left or right = c,l,r

function textable (data, filename, rlines = 1, clines = 1, alignment = "r", matrixformat = 0)

  if (nargin < 2 || nargin > 6)
    print_usage;
  endif

  if nargin >= 5
    if alignment == 0
      alignment = "c";
    elseif alignment == 1
      alignment = "l";
    elseif alignment == 2
      alignment = "r";
    else
      error ("unknown value for alignment");
    end
  end

  if exist ('matrixformat')
    clines = 0;
    rlines = 0;
    alignment = 0;
  else
    matrixformat = 0;
  endif

  ## print my tex file
  f = fopen(filename,"w");

  if matrixformat == 1
    fprintf(f,"\\begin{displaymath} \n");
    fprintf(f,"\\mathbf{X} = \n");
    fprintf(f,["\\left( \\begin{array} {*{ %d }{c}}\n"
               "  \n \\toprule \n"],\
               columns(data));
  else
    if clines == 1 
      fprintf(f, ["\\begin{tabular}{|%s}\n"], repmat (cstrcat(alignment,"|"),[1,columns(data)]));
    else
      fprintf(f, ["\\begin{tabular}{%s}\n"], repmat (alignment,[1,columns(data)]));
    endif
  endif

  if rlines == 1
    fprintf(f," \\hline \n");
  endif


  for ii = 1:rows(data)
    fprintf(f,"%g",data(ii,1));
    fprintf(f," & %g",data(ii,2:end));
    fprintf(f," \\\\ \n");
    if rlines == 1
      fprintf(f," \\hline \n");
    endif
  endfor
  if matrixformat == 1
    fprintf(f,"\\end{array}\\right)\n");
    fprintf(f,"\\end{displaymath}")
  else
    fprintf(f,"\\end{tabular}\n");
  endif
  fclose(f);
endfunction
