## Copyright (C) 2000 Paul Kienzle
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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: stem(x, [,y] [, linetype])
##
## Draws struts for each point, overlaid on another line type. This is
## just:
##     plot(x, y, linetype, x, y, "^;;")
## but with the pointsize increased so that you can see the symbols
## clearly.  By default, linetype is "o;;" so that circles are
## connected to the x-axis with struts.
##
## Note that a plot can only support one point size, so if you are
## plotting multiple plots, do stem last to keep large points.
##
## Example
##    t=0:0.1:2*pi; x=sin(t); idx=1:4:length(t);
##    plot(t,x,"r-+;sin(x);"); hold on
##    stem(t(idx), x(idx),"bo;struts;"); hold off

function stem(x, y, linetype)
  if nargin < 1 || nargin > 3
    usage("stem(x [, y] [, linetype])");
  endif
  if nargin < 2, linetype=y=[]; endif
  if nargin < 3, linetype=[]; endif
  if isstr(y)
    linetype = y;
    y = [];
  endif
  if isempty(linetype), linetype="o;;"; endif

  ## scan the linetype parameter to see if a colour has been specified
  colour = '1'; title=0; ignoredigit=0;
  for i=1:length(linetype)
    if linetype(i) == ';'
      title = 1-title;
    elseif !title
      if !isempty(findstr("rgbmcw",linetype(i)))
	colour = linetype(i);
	ignoredigit=1;
      elseif !isempty(findstr("0123456789",linetype(i)))
	if !ignoredigit, colour = linetype(i); endif
	ignoredigit=1;
      endif
    endif
  endfor

  unwind_protect
    eval(sprintf("gset pointsize %d",2-min(2,fix(length(x)/100))));
    gset xzeroaxis
    if isempty(y)
      plot(x, linetype, x, [colour, "^;;"]);
    else
      plot(x, y, linetype, x, y, [colour, "^;;"]);
    endif
  unwind_protect_cleanup
    gset pointsize 1
    gset noxzeroaxis
  end_unwind_protect
endfunction

%!demo
%! t=0:0.1:2*pi; x=sin(t); idx=1:4:length(t);
%! plot(t,x,"+r-;sin(x);"); hold on;
%! stem(t(idx), x(idx),"bo;struts;"); hold off;
