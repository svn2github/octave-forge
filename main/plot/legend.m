## Copyright (C) 2001 Laurent Mazet
##
## This program is free software; it is distributed in the hope that it
## will be useful, but WITHOUT ANY WARRANTY; without even the implied
## warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
## the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

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

## PKG_ADD mark_as_command legend
function legend (varargin)

  ## Use the following for 2.1.39 and below
  # varargin = list(varargin, all_va_args);
  args = nargin; # silliness: nargin is now a function 

  ## Data type

  data_type = 0;
  va_arg_cnt = 1;

  str = "";
  if (args > 0)
    str = nth (varargin, va_arg_cnt++);
  endif;
      
  ## Test for strings

  if (isstr(str)) && (args == 1)
    _str = tolower(deblank(str));
    _replot = 1;
    switch _str
      case {"off", "hide"}
        gset nokey;
      case "show"
	gset key;
      case "boxon"
	gset key box;
      case "boxoff"
	gset key nobox;
      case "left"
        gset key Right noreverse;
      case "right"
        gset key Left reverse;
      otherwise
	_replot = 0;
    endswitch
    if _replot
      if automatic_replot
        replot
      endif
      return;
    endif
  endif

  ## Test for data type (0 -> list of string, 1 -> array of string)

  if (length(str) != 0) && (isstr(str(1,:))) && (rows(str) != 1) || iscell(str)
    data_type = 1;
    va_arg_cnt = 1;

    if (iscell(str))
      data = nth (varargin, va_arg_cnt++);
    else
      data = cellstr( nth (varargin, va_arg_cnt++));
    endif
    nb_data = length(data);
    args--;
  endif;

  pos_leg = 1;
  
  ## Get the original plotting command
  
  tmpfilename=tmpnam;
  command=["save \"",tmpfilename,"\"\n"];
  graw(command);

  awk_prog= \
      "BEGIN { \
        dq = 0; \
        format = \"%s\\n\"; \
       } \
       NF != 0 { \
        for (i=1;i<=NF;i++) { \
         if ($(i) == \"\\\"\") { \
          if (dp == 0) { \
           dp = 1; \
           if ($(i+1) != \"\\\"\") { \
            i++; \
            printf (\"%s\", $(i)); \
           } \
          format = \" %s\"; \
          } else { \
           dp = 0; \
           format = \"%s\\n\"; \
           printf (\"\\n\"); \
          } \
         } else { \
          printf (format, $(i)); \
         } \
        } \
       }";
            
  shell_cmd=["grep \"^", gnuplot_command_plot, " \" '", tmpfilename, "' | ", \
             "sed -e 's/,/ , /g' -e 's/\"/ \" /g'", " | ", \
             "awk '", awk_prog, "'"];

  # wait for the file to appear
  attempt=0;
  while (isempty(stat(tmpfilename))) 
    if (++attempt > 20) error("gnuplot is not responding"); endif
    usleep(1e5); 
  end
  plot_cmd = split(system(shell_cmd),"\n");

  if (~length(deblank(plot_cmd(rows(plot_cmd), :))))
    plot_cmd = plot_cmd ([1:rows(plot_cmd)-1],:);
  endif;
  unlink(tmpfilename);
  
  ## Look for the number of graph

  nb_graph = 0;
  i = 0;
  while (i++ < rows(plot_cmd))
    line = deblank(plot_cmd(i,:));
    if ((strcmp(line, gnuplot_command_plot)) || (strcmp(line, ",")))
      nb_graph++;
    endif;
  endwhile;

  ## Change the legend of each graph
  
  new_plot = [];
  if (data_type == 0)
    va_arg_cnt = 1;

  endif;
  fig = 0;
  i = 1;
  while (fig < nb_graph)

    ## Get the legend string

    if (((data_type == 0) && (args <= 0)) || \
        ((data_type == 1) && (fig >= nb_data)))
      leg = "\"\"";
    else
      if (data_type == 0)
        leg = nth (varargin, va_arg_cnt++);
        args--;
      else
        leg = data{fig+1};
      endif;
      if (!isstr(leg))
        pos_leg = leg;
        leg = "\"\"";
      elseif (length(deblank(leg)) == 0)
        leg = "\"\"";
      else
        leg=["\"" leg "\""];
      endif;
    endif;

    ## look for the end of the graph command i.e. ","

    new_line = [deblank(plot_cmd(i++,:)), " \"", \
                strrep(deblank(plot_cmd(i++,:)), "'", "") "\""];
    while ((i <= rows(plot_cmd)) && (!strcmp(deblank(plot_cmd(i,:)), ",")))
      if (strcmp(deblank(plot_cmd(i,:)), gnuplot_command_title))
        new_line = [new_line, " ", gnuplot_command_title, " ", leg];
        i++;
      else
        new_line = [new_line, " ", deblank(plot_cmd(i,:))];
      endif;
      i++;
    endwhile;

    if (length(new_plot))
      new_plot = [ new_plot, new_line];
    else
      new_plot = new_line;
    endif;
    
    fig++;
  endwhile;

  ## Create a new plotting command

  new_plot = [new_plot, "\n"];  
  graw(new_plot);

  ## Check for the last argument if we don't already get it
  
  while (args-- > 0)
    pos_leg = nth (varargin, va_arg_cnt++) ;
    if (isstr(pos_leg))
      pos_leg = 0;
    endif;
  endwhile;
  
  ## Change the legend position

  if ((isscalar (pos_leg)) && (isreal(pos_leg)))
    switch (pos_leg)
      case 1
        gset key right top;
      case 2
        gset key left top;
      case 3
        gset key left bottom;
      case 4
        gset key right bottom;
      case -1
        gset key right top outside;
      case -2
        gset key right bottom outside;
      case -3
        gset key below;
      otherwise
        warning ("incorrect pos");
    endswitch;
  elseif (isvector (pos_leg)) && (length (pos_leg) == 2) && \
        (all(isreal(pos_leg)))
    eval (sprintf ("gset key %e, %e", pos_leg(1), pos_leg(2)));
  else
    warning ("pos must be a scalar");
  endif;

  ## Regenerate the plot
  
  replot;
  
endfunction;

%!demo
%! close all;
%! plot(1:10, 1:10);
%! title("a very long label can sometimes cause problems");
%! legend({"hello world"}, -1)

%!demo
%! close all;
%! labels = {};
%! for i = 1:10
%!     plot(1:100, rand(1)*10 + rand(100,1)); hold on;
%!     labels = {labels{:}, strcat("Signal ", num2str(i))};
%! endfor; hold off;
%! title("Signals with random offset and uniform noise")
%! xlabel("Sample Nr [k]"); ylabel("Amplitude [V]");
%! legend(labels, -1)
%! legend("boxon")

