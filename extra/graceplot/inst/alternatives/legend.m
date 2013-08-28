## Copyright (C) 2001 Laurent Mazet
##
## This program is free software; it is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} legend (@var{st1}, @var{st2}, @var{st3}, @var{...})
## @deftypefnx {Function File} {} legend (@var{st1}, @var{st2}, @var{st3}, @var{...}, @var{pos})
## @deftypefnx {Function File} {} legend (@var{matstr})
## @deftypefnx {Function File} {} legend (@var{matstr}, @var{pos})
## @deftypefnx {Function File} {} legend (@var{cell})
## @deftypefnx {Function File} {} legend (@var{cell}, @var{pos})
## @deftypefnx {Function File} {} legend ('@var{func}')
##
## Legend puts a legend on the current plot using the specified strings
## as labels. Use independant strings (@var{st1}, @var{st2}, @var{st3}...), a
## matrix of strings (@var{matstr}), or a cell array of strings (@var{cell}) to
## specify legends. Legend works on line graphs, bar graphs, etc...
## Be sure to call plot before calling legend.
##
## @var{pos} optionally  places the legend in the specified location:
##
## @multitable @columnfractions 0.1 0.1 0.8
## @item @tab 0 @tab
##   Don't move the legend box (default)
## @item @tab 1 @tab
##   Upper right-hand corner
## @item @tab 2 @tab
##   Upper left-hand corner
## @item @tab 3 @tab
##   Lower left-hand corner
## @item @tab 4 @tab
##   Lower right-hand corner
## @item @tab -1 @tab
##   To the top right of the plot
## @item @tab -2 @tab
##   To the bottom right of the plot
## @item @tab -3 @tab
##   To the bottom of the plot
## @item @tab [@var{x}, @var{y}] @tab
##   To the arbitrary postion in plot [@var{x}, @var{y}]
## @end multitable
##
## Some specific functions are directely avaliable using @var{func}:
##
## @table @code
## @item show
##   Show legends from the plot
## @item hide
## @itemx off
##   Hide legends from the plot
## @item boxon
##   Draw a box around legends
## @item boxoff
##   Withdraw the box around legends
## @item left
##   Text is to the left of the keys
## @item right
##   Text is to the right of the keys
## @end table
##
## REQUIRES: unix piping functionality, grep, sed and awk
## @end deftypefn

## 2001-03-31 Paul Kienzle
##   * use tmpnam for temporary file name; unlink to remove
## 2001-09-28 Paul Söderlind <Paul.Soderlind@hhs.se>
##   * add a pause after save request to give gnuplot time to write the file
##   * add comment to call plot before legend.
## 2002-09-18 Paul Kienzle
##   * make the pause check every .1 seconds
## 2003-04-1 Laurent Mazet
##   * add new functions (boxon, boxoff...)
##   * rebuild help message
## 2003-06-12 Quentin Spencer
##   * add support for input in cell array format
## 2005-01-11 Teemu Ikonen
##   * modify to support Grace

function legend (varargin)

  args = nargin();

  str = "";
  if (args > 0)
    str = varargin{1};
  endif;

  __grcmd__("legend loctype view");                          
  
  ## Test for strings

  if (ischar(str)) && (args == 1)
    _str = tolower(deblank(str));
    _replot = 1;
    switch _str
      case {"off", "hide"}
        __grcmd__("legend off");
#        __gnuplot_set__ nokey;
      case "show"
        __grcmd__("legend on");        
#	__gnuplot_set__ key;
      case "boxon"
        __grcmd__("legend box on");          
#	__gnuplot_set__ key box;
      case "boxoff"
        __grcmd__("legend box off");            
#	__gnuplot_set__ key nobox;
      case "left"
        __grcmd__("legend 0.15,0.85");            
#        __gnuplot_set__ key Right noreverse;
      case "right"
        __grcmd__("legend 0.7,0.85");              
#        __gnuplot_set__ key Left reverse;
      otherwise
	_replot = 0;
    endswitch
    if _replot
      __grcmd__("redraw");
      return;
    endif
  endif


  if(ischar(str) && size(str,1) > 1)
    data = cellstr(str);
    args--;
  elseif(iscell(str))
    data = str;
    args--;
  else
    data = varargin;
    args = 0;
  endif
  nb_data = length(data);

  pos_leg = NaN;

  i = 1;
  while(i <= nb_data && ischar(data{i}))
    __grcmd__(sprintf("s%d legend \"%s\"", i-1, data{i}));
    i++;
  endwhile
  if(i <= nb_data && isreal(data{i}) )
    pos_leg = data{i};
  endif
  
  if(args > 0 && isreal(varargin{end}))
    pos_leg = varargin{end};
  endif


  if (isnan(pos_leg))
    ;
  elseif (isscalar (pos_leg) && isreal(pos_leg))
    switch (pos_leg)
      case 1
        __grcmd__("legend 0.7,0.85");
#        __gnuplot_set__ key right top;
      case 2
        __grcmd__("legend 0.15,0.85");
#        __gnuplot_set__ key left top;
      case 3
        __grcmd__("legend 0.15,0.20");              
#        __gnuplot_set__ key left bottom;
      case 4
        __grcmd__("legend 0.7,0.20");              
#        __gnuplot_set__ key right bottom;
      case -1
        __grcmd__("legend 0.7,0.95");              	
#        __gnuplot_set__ key right top outside;
      case -2
        __grcmd__("legend 0.7,0.10");              	
#        __gnuplot_set__ key right bottom outside;
      case -3
        __grcmd__("legend 0.15,0.10");              	
#        __gnuplot_set__ key below;
      otherwise
        warning ("incorrect pos");
    endswitch;
  elseif (isvector (pos_leg)) && (length (pos_leg) == 2) && ...
        (all(isreal(pos_leg)))
    __grcmd__(sprintf("legend %f,%f", pos_leg(1), pos_leg(2)));
  else
    warning ("pos must be a scalar");
  endif;

  ## Regenerate the plot
  
  __grcmd__("redraw");
  
endfunction;
