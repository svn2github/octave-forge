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

## text(x,y[,z],'text','property',value,...)
##    Add 'text' to the plot at position (x,y,z). 
##
## text('property',value,...)
##    Property controls the features of the text:
##    'HorizontalAlignment': value is 'left' (default), 'right' or 'center'
##        where to locate the text relative to (x,y)
##    'Units': value is 'data' (default), 'normalized' or 'screen'
##        data uses the coordinate system of the axes.
##        normalized uses x,y,z values in the range [0,1] for the axes.
##        screen uses x,y values in the range [0,1] for the window/page.
##            note that this only works if called after the last subplot.
##    'Rotation' : value is degrees
##    'FontName' : value is the name of the font (terminal dependent)
##    'FontSize' : value is the size of the font (terminal dependent)
##    'Position' : value is [x, y] or [x, y, z]
##    'String': value is 'text'
##
## text();
##    Clear all text from the plot (must be used before the next plot
##    since the labels persist from plot to plot).
##
##
## Example
##    text(0.5,0.50,'Graph center',...
##         'HorizontalAlignment','center','Units','normalized');
##    plot(linspace(-pi,pi),linspace(0,e));

## TODO: label property should be automatically cleared in plot
## TODO:   if hold is not on.  Same for title, xlabel, ylable, etc.,
## TODO:   so handle text in the same way, by requiring text with no
## TODO:   to clear all the labels for the next graph.
## TODO: several properties missing
## TODO: permit text(blah,'units','screen') before subplot as well as after
function text(varargin)
  usage_str = "text(x,y[,z],'text', 'property',value...)";
  if nargin == 0, gset nolabel; return; endif

  position=[0, 0, 0];
  text="";
  rotate="norotate";
  align="left";
  fontname=fontsize=[];
  units="first";

  ## Process text(x,y[,z],'text') forms
  va_arg_cnt = 1; n=1;

  arg = nth (varargin, va_arg_cnt++); n=n+1;
  if is_scalar(arg),
    position(1) = arg;
    if nargin < 2, usage(usage_str); endif
    arg = nth (varargin, va_arg_cnt++); n=n+1;
    if !is_scalar(arg), usage(usage_str); endif
    position(2) = arg;

    if nargin < 3, usage(usage_str); endif
    arg = nth (varargin, va_arg_cnt++); n=n+1;
    if isstr(arg)
      text=arg;
    else
      position(3) = arg;
      if nargin < 4, usage(usage_str); endif
      text=nth (varargin, va_arg_cnt++); n=n+1; 
    endif
    if !isstr(text), usage(usage_str); endif
  endif

  ## Process text('property',value) forms
  if rem(nargin-n+1, 2) != 0, error(usage_str); endif
  for i=n:2:nargin
    prop=nth (varargin, va_arg_cnt++); val=nth (varargin, va_arg_cnt++);
    if !isstr(prop), error(usage_str); endif
    prop = tolower(prop);
    if strcmp(prop, "fontname"),
      if !isstr(val), 
	error("text 'FontName' expects a string"); endif
      fontname = val;
    elseif strcmp(prop, "fontsize"),
      if !is_scalar(val), 
	error("text 'FontSize' expects a scalar"); endif
      fontsize = val;
    elseif strcmp(prop, "horizontalalignment"),
      if isstr(val), val=tolower(val); endif
      if !isstr(val) || ...
	    !(strcmp(val,"left")||strcmp(val,"right")||strcmp(val,"center"))
	error("text 'HorizontalAlignment' expects 'right','left' or 'center'");
      endif
      align = val;
    elseif strcmp(prop, "units")
      if isstr(val), val=tolower(val); endif
      if !isstr(val)
	error("text 'Units' expects 'data' or 'normalized'");
      elseif strcmp(val,"data")
	units="first";
      elseif strcmp(val,"normalized")
	units="graph";
      elseif strcmp(val,"screen")
	units="screen";
      else
	warning(["text('Units','", val, "') ignored"]);
      endif
    elseif strcmp(prop, "position")
      if is_vector(val) || !(length(val)>=2 && length(val)<=3)
	error("text 'Position' expects vector of x,y and maybe z"); 
      elseif length(val)==2, position=postpad(val,3);
      else position = val;
      endif
    elseif strcmp(prop, "rotation")
      if !is_scalar(val), error("text 'Rotation' expects scalar"); endif
      if mod(val+45,180)<=90
	rotate="norotate";
      else
	rotate="rotate";
      endif
    elseif strcmp(prop, "string")
      if !isstr(val), error("text 'String' expects a string"); endif
      text = val;
    else
      warning(["ignoring property ", prop]);
    endif
  endfor
  if !isempty(fontname) || !isempty(fontsize)
    font = sprintf(' font "%s,%d"', fontname, fontsize);
  else
    font = "";
  endif
  if position(3)!=0,
    atstr = sprintf("%f,%f,%f", position(1),position(2),position(3));
  else
    atstr = sprintf("%f,%f", position(1),position(2));
  endif
  command = sprintf('gset label "%s" at %s %s %s %s%s',
		    text, units, atstr, align, rotate, font);
  eval(command);

endfunction

%!demo
%! subplot(211);
%! title("Data coordinates");
%! text( 0,1,'bl');
%! text( 5,1,'bc','HorizontalAlignment','center');
%! text(10,1,'br','HorizontalAlignment','right');
%! text( 0,5,'ml');
%! text( 5,5,'mc','HorizontalAlignment','center');
%! text(10,5,'mr','HorizontalAlignment','right');
%! text( 0,9,'tl');
%! text( 5,9,'tc','HorizontalAlignment','center');
%! text(10,9,'tr','HorizontalAlignment','right');
%! text( 2,4,'rotated','Rotation',90);
%! plot(0:10,0:10,";;");
%! text; title("");
%!
%! subplot(212);
%! title("Normalized coordinates");
%! text(0.0,0.05,'bl','Units','normalized');
%! text(0.5,0.05,'bc','Units','normalized','HorizontalAlignment','center');
%! text(1.0,0.05,'br','Units','normalized','HorizontalAlignment','right');
%! text(0.0,0.50,'ml','Units','normalized');
%! text(0.5,0.50,'mc','Units','normalized','HorizontalAlignment','center');
%! text(1.0,0.50,'mr','Units','normalized','HorizontalAlignment','right');
%! text(0.0,0.95,'tl','Units','normalized');
%! text(0.5,0.95,'tc','Units','normalized','HorizontalAlignment','center');
%! text(1.0,0.95,'tr','Units','normalized','HorizontalAlignment','right');
%! text(0.2,0.40,'rotated','Rotation',90,'units','normalized');
%! plot(linspace(-pi,pi),linspace(0,e),";;");
%! text; title("");
%! oneplot();
%! %----------------------------------------------------------------
%! % graph will show labels inserted at various points with various
%! % justifications. b=bottom,m=middle,t=top,l=left,c=center,r=right
%! % The rotated text will not show up as rotated on x11 gnuplot

%!demo
%! subplot(211); title("graph 1"); 
%! plot(0:10,0:10,";;"); title("");
%! subplot(212); title("graph 2"); 
%! text(0.0,0.05,'bl','Units','screen');
%! text(0.5,0.05,'bc','Units','screen','HorizontalAlignment','center');
%! text(1.0,0.05,'br','Units','screen','HorizontalAlignment','right');
%! text(0.0,0.50,'ml','Units','screen');
%! text(0.5,0.50,'mc','Units','screen','HorizontalAlignment','center');
%! text(1.0,0.50,'mr','Units','screen','HorizontalAlignment','right');
%! text(0.0,0.95,'tl','Units','screen');
%! text(0.5,0.95,'tc','Units','screen','HorizontalAlignment','center');
%! text(1.0,0.95,'tr','Units','screen','HorizontalAlignment','right');
%! text(0.2,0.40,'rotated','Rotation',90,'units','screen');
%! plot(linspace(-pi,pi),linspace(0,e),";;"); title("");
%! text;
%! oneplot();
%! %----------------------------------------------------------------
%! % graph will show labels inserted at various points with various
%! % justifications. b=bottom,m=middle,t=top,l=left,c=center,r=right
%! % The rotated text will not show up as rotated on x11 gnuplot

