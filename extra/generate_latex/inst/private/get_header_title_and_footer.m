## Copyright (C) 2008 Soren Hauberg
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

function [header, title, footer] = get_header_title_and_footer (options, name = "", root = "")
  
  if (isfield (options, "header"))
    header = options.header;
  else
    header = "\\begin{verbatim}\n";
  endif
  
  header = strrep (header, "%root", root);
  title = "";
  
  if (isfield (options, "footer"))
    footer = options.footer;
  else
    footer = "\\end{verbatim}\n";
  endif  

endfunction
