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

## usage: legend (string1, string2, string3, ..., [pos])
##        legend ([string1; string2; string3; ...], [pos])
##        legend ("off")
##
## Legend puts a legend on the current plot using the specified strings
## as labels. Legend works on line graphs, bar graphs, etc...
## Be sure to call plot before calling legend.
##
## pos: places the legend in the specified location:
##      0 = Don't move the legend box (default)
##      1 = Upper right-hand corner
##      2 = Upper left-hand corner
##      3 = Lower left-hand corner
##      4 = Lower right-hand corner
##      -1 = To the right of the plot
##
## off will switch off legends from the plot
##
## REQUIRES: unix piping functionality, grep, sed and awk

## 2001-03-31 Paul Kienzle
##   * use tmpnam for temporary file name; unlink to remove
## 2001-09-28 Paul Söderlind <Paul.Soderlind@hhs.se>
##   * add a pause after save request to give gnuplot time to write the file
##   * add comment to call plot before legend.

function legend (...)

  gset key;
  
  ## Data type

  data_type = 0;
  va_start();
  str = "";
  if (nargin > 0)
    str = va_arg();
  endif;
      
  ## Test for off

  if ((isstr(str)) && (strcmp(tolower(deblank(str)),"off")) && (nargin == 1))
    gset nokey;
    replot;
    return;
  endif;

  ## Test for data type (0 -> list of string, 1 -> array of string)
  
  if (length(str) != 0) && (isstr(str(1,:))) && (rows(str) != 1)
    data_type = 1;
    va_start();
    data = va_arg();
    nb_data = rows(data);
    nargin--;
  endif;

  pos_leg = 0;
  
  ## Get the original plotting command
  
  tmpfilename=tmpnam;
  command=["save \"",tmpfilename,"\"\n"];
  graw(command);
  pause(2);

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
            
  shell_cmd=["grep \"^pl \" " tmpfilename " | " \
             "sed -e 's/,/ , /g' -e 's/\"/ \" /g'" " | " \
             "awk '" awk_prog "'"];
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
    if ((strcmp(line, "pl")) || (strcmp(line, ",")))
      nb_graph++;
    endif;
  endwhile;

  ## Change the legend of each graph
  
  new_plot = [];
  if (data_type == 0)
    va_start();
  endif;
  fig = 0;
  i = 1;
  while (fig < nb_graph)

    ## Get the legend string

    if (((data_type == 0) && (nargin <= 0)) || \
        ((data_type == 1) && (fig >= nb_data)))
      leg = "\"\"";
    else
      if (data_type == 0)
        leg = va_arg () ;
        nargin--;
      else
        leg = data(fig+1,:);
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

    new_line = [deblank(plot_cmd(i++,:)) " \"" deblank(plot_cmd(i++,:)) "\""];
    while ((i <= rows(plot_cmd)) && (!strcmp(deblank(plot_cmd(i,:)), ",")))
      if (strcmp(deblank(plot_cmd(i,:)), "t"))
        new_line = [new_line " t " leg];
        i++;
      else
        new_line = [new_line " " deblank(plot_cmd(i,:))];
      endif;
      i++;
    endwhile;

    if (length(new_plot))
      new_plot = [ new_plot new_line];
    else
      new_plot = new_line;
    endif;
    
    fig++;
  endwhile;

  ## Create a new ploting command

  new_plot = [new_plot "\n"];  
  graw(new_plot);

  ## Check for the last argument if we don't already get it
  
  while (nargin-- > 0)
    pos_leg = va_arg () ;
    if (isstr(pos_leg))
      pos_leg = 0;
    endif;
  endwhile;
  
  ## Change the legend position

  if ((is_scalar (pos_leg)) && (isreal(pos_leg)))
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
    endswitch;
  else
    warning ("pos must be a scalar");
  endif;

  ## Regenerate the plot
  
  replot;
  
endfunction;
