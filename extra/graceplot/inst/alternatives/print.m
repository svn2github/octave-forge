
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
##
## Copyright (C) 1999 Daniel Heiserer

## usage: print (filename, options)
##
## Print a graph, or save it to a file
##
## filename: 
##   File to receive output.  If no filename is specified, output is
##   sent to the printer.
##
## options:
##   -Pprinter
##      Printer to which the graph is sent if no filename is specified.
##
##   -color | -mono
##      Monochrome or colour lines.
##
##   -portrait | -landscape
##      Plot orientation, as returned by "orient".
##
##   -dDEVICE
##      Output device, where DEVICE is one of:
##
##        ps,ps2,psc,psc2      
##             Postscript (level 1 and 2, mono and color)
##        eps,eps2,epsc,epsc2  
##             Encapsulated postscript (level 1 and 2, mono and color)
##        png  Portable network graphics
##        svg  Scalable vector garphics
##        jpg  JPEG image
##        pbm  1-bit portable graphics 
##        pgm  grayscale portable graphics 
##        ppm  full-color portable graphics
##        mif  FrameMaker Interchange Format
##        gmf  CGM Graphics Metafile
##
##      Other devices are supported by "convert" from ImageMagick.  Type
##      system("convert") to see what formats are available.
##
##      If the device is omitted, it is inferred from the file extension,
##      or if there is no filename it is sent to the printer as postscript.
##
## The filename and options can be given in any order.
##
## See also: orient

##   -solid | -dashed
##      Solid or dashed lines.

##        ill,aifm 
##             Adobe Illustrator
##        cdr,corel
##             CorelDraw
##        hpgl HP plotter language
##        fig  XFig
##        dxf  AutoCAD
##        mf   Metafont
##        pbm  PBMplus

##   -Ffontname, -Ffontname:size, -F:size
##      Postscript font (for use with postscript, aifm, corel and fig)
##      "Helvetica" by default for PS/Aifm, "SwitzerlandLight" for Corel
##      Can also be "Times-Roman".  The font size is given in points.
##      The fontname is ignored for the fig device.
##

## Author: Daniel Heiserer <Daniel.heiserer@physik.tu-muenchen.de>
## 2001-03-23  Laurent Mazet <mazet@crm.mot.com>
##     * simplified interface: guess the device from the extension
##     * font support
## 2001-03-25  Paul Kienzle <pkienzle@users.sf.net>
##     * add unwind_protect
##     * use tmpnam to generate temporary name
##     * move "set term" before "set output" as required by gnuplot
##     * more options, and flexible options
## 2001-03-29  Laurent Mazet <mazet@crm.mot.com>
##     * add solid and dashed options
##     * change PBMplus device
##     * add Corel device
##     * take care of the default terminal settings to restore them.
##     * add color, mono, dashed and solid support for printing and convert.
##     * add orientation for printing.
##     * create a .ps for printing (avoid some filtering problems).
##     * default printing is mono, default convert is color.
##     * add font size support.
## 2001-03-30  Laurent Mazet <mazet@crm.mot.com>
##     * correct correl into corel
##     * delete a irrelevant test
##     * check for convert before choosing the ouput device
## 2001-03-31  Paul Kienzle <pkienzle@users.sf.net>
##     * use -Ffontname:size instead of -F"fontname size"
##     * add font size support to fig option
##     * update documentation
## 2003-08-08  Teemu Ikonen <tpikonen@pcu.helsinki.fi>
##     * Adapted to work with Grace


function print(varargin)

  orientation = orient;
  use_color = 0; # 0=default, -1=mono, +1=color
  force_solid = 0; # 0=default, -1=dashed, +1=solid
  fontsize = font = name = devopt = printer = "";
  
  va_arg_cnt = 1;

  for i=1:nargin
    arg = varargin{va_arg_cnt++}; 
    if ischar(arg)
      if strcmp(arg, "-color")
	use_color = 1;
      elseif strcmp(arg, "-mono")
	use_color = -1;
      elseif strcmp(arg, "-solid")
        force_solid = 1;
      elseif strcmp(arg, "-dashed")
        force_solid = -1;
      elseif strcmp(arg, "-portrait")
	orientation = "portrait";
      elseif strcmp(arg, "-landscape")
	orientation = "landscape";
      elseif length(arg) > 2 && arg(1:2) == "-d"
	devopt = arg(3:length(arg));
      elseif length(arg) > 2 && arg(1:2) == "-P"
	printer = arg;
      elseif length(arg) > 2 && arg(1:2) == "-F"
	idx = rindex(arg, ":");
	if (idx)
	  font = arg(3:idx-1);
	  fontsize = arg(idx+1:length(arg));
	else
	  font = arg(3:length(arg));
	endif
      elseif length(arg) >= 1 && arg(1) == "-"
	error([ "print: unknown option ", arg ]);
      elseif length(arg) > 0
	name = arg;
      endif
    else
      error("print: expects string options");
    endif
  endfor

#  doprint = isempty(name);
#   if doprint
#     if isempty(devopt)
#       printname = [ tmpnam, ".ps" ]; 
#     else
#       printname = [ tmpnam, ".", devopt ];
#     endif
#     name = printname;
#   endif

  doprint = isempty(name);
  if(doprint)
    dev = "ps";
    printname = [ tmpnam, ".ps" ]; 
    name = printname;
  endif

  if isempty(devopt)
    dot = rindex(name, ".");
    if (dot == 0) 
      error ("print: no format specified");
    else
      dev = tolower(name(dot+1:length(name)));
    endif
  else
    dev = devopt;
  endif

#   if strcmp(dev, "ill")
#     dev = "aifm";
#   elseif strcmp(dev, "cdr")
#     dev = "corel";
#   endif


  ## check if we have to use convert
#  dev_list = [" aifm corel fig png pbm dxf mf hpgl", ...
#	      " ps ps2 psc psc2 eps eps2 epsc epsc2 " ];
  ## Grace formats 
  dev_list = [" png mif gmf svg pnm pbm pgm ppm jpeg jpg", ...
	      " ps ps2 psc psc2 eps eps2 epsc epsc2 " ];
  convertname = "";
  if(!doprint && isempty(findstr(dev_list , [ " ", dev, " " ])) )
    if !isempty(devopt)
      convertname = [ devopt ":" name ];
    else
      convertname = name;
    endif
    dev = "epsc";
    name = [ tmpnam, ".eps" ];
  endif
  
  unwind_protect
#    automatic_replot = 0;

    if( strcmp(dev, "ps") || strcmp(dev, "ps2") ...
	  || strcmp(dev, "psc")  || strcmp(dev, "psc2") )
      ## Various postscript options

#       __gnuplot_set__ term postscript;
#       terminal_default = gget ("terminal");
      
#       if dev(1) == "e"
# 	options = "eps ";
#       else
# 	options = [ orientation, " " ];
#       endif
#       options = [ options, "enhanced " ];
      
#       if any( dev == "c" ) || use_color > 0
#         if force_solid < 0
# 	  options = [ options, "color dashed " ];
# 	else
#           options = [ options, "color solid " ];
#         endif
#       else
#         if force_solid > 0
# 	  options = [ options, "mono solid " ];
# 	else
# 	  options = [ options, "mono dashed " ];
#         endif
#       endif

#       if !isempty(font)
# 	options = [ options, "\"", font, "\" " ];
#       endif
#       if !isempty(fontsize)
# 	options = [ options, " ", fontsize ];
#       endif

#       eval (sprintf ("__gnuplot_set__ term postscript %s;", options));

      grdevname = "PostScript";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname));
      if(strcmp(orientation, "landscape"))
	__grcmd__("page layout landscape");
      else
	__grcmd__("page layout portrait");
      endif
      if(any( dev == "c" ) || use_color > 0)
	__grcmd__(sprintf("device \"%s\" op \"color\"", grdevname));
      elseif(use_color < 0)
	__grcmd__(sprintf("device \"%s\" op \"grayscale\"", grdevname));
      endif
      
    elseif( strcmp(dev, "epsc") || strcmp(dev, "epsc2") ... 
	  || strcmp(dev, "eps")  || strcmp(dev, "eps2") )

      grdevname = "EPS";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname));
      if(any( dev == "c" ) || use_color > 0)
	__grcmd__(sprintf("device \"%s\" op \"color\"", grdevname));
      elseif(use_color < 0)
	__grcmd__(sprintf("device \"%s\" op \"grayscale\"", grdevname));
      endif

#     elseif strcmp(dev, "aifm") || strcmp(dev, "corel")
#       ## Adobe Illustrator, CorelDraw
#       eval(sprintf ("__gnuplot_set__ term %s;", dev));
#       terminal_default = gget ("terminal");
#       if (use_color >= 0)
# 	options = " color";
#       else
# 	options = " mono";
#       endif
#       if !isempty(font)
# 	options = [ options, " \"" , font, "\"" ];
#       endif
#       if !isempty(fontsize)
# 	options = [ options, " ", fontsize ];
#       endif

#       eval (sprintf ("__gnuplot_set__ term %s %s;", dev, options));

#     elseif strcmp(dev, "fig")
#       ## XFig
#       __gnuplot_set__ term fig;
#       terminal_default = gget ("terminal");
#       options = orientation;
#       if (use_color >= 0)
# 	options = " color";
#       else
# 	options = " mono";
#       endif
#       if !isempty(fontsize)
# 	options = [ options, " fontsize ", fontsize ];
#       endif
#       eval (sprintf ("__gnuplot_set__ term fig %s;", options));

    elseif strcmp(dev, "png")
      ## Portable network graphics      

#       if (use_color >= 0)
#       	eval (sprintf ("__gnuplot_set__ terminal png medium;"));
#       else
#         eval (sprintf ("__gnuplot_set__ terminal png medium;"));
#       endif      

      grdevname = "PNG";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname));      

#     elseif strcmp(dev, "pbm")
#       ## PBMplus
#       eval(sprintf ("__gnuplot_set__ term %s;", dev));
#       terminal_default = gget ("terminal");
#       if (use_color >= 0)
#       	eval (sprintf ("__gnuplot_set__ term %s color medium;", dev));
#       else
#         eval (sprintf ("__gnuplot_set__ term %s mono medium;", dev));
#       endif

#     elseif strcmp(dev,"dxf") || strcmp(dev,"mf") || strcmp(dev, "hpgl")
#       ## AutoCad DXF, METAFONT, HPGL
#       eval (sprintf ("__gnuplot_set__ terminal %s;", dev));

    elseif strcmp(dev, "svg")
      grdevname = "SVG";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname));      

    elseif strcmp(dev, "jpg")
      grdevname = "JPEG";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname));      
      if(any( dev == "c" ) || use_color > 0)
	__grcmd__(sprintf("device \"%s\" op \"color\"", grdevname));
      elseif(use_color < 0)
	__grcmd__(sprintf("device \"%s\" op \"grayscale\"", grdevname));
      endif

    elseif( strcmp(dev, "pnm") || strcmp(dev, "pbm") \
	   || strcmp(dev, "pgm") || strcmp(dev, "ppm") )
      grdevname = "PNM";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname));      
      __grcmd__(sprintf("device \"%s\" op \"rawbits:off\"", grdevname));
      if(strcmp(dev, "pbm"))
	__grcmd__(sprintf("device \"%s\" op \"format:pbm\"", \
			  grdevname));
      elseif(strcmp(dev, "pgm"))
	__grcmd__(sprintf("device \"%s\" op \"format:pgm\"", \
			  grdevname));
      elseif(strcmp(dev, "ppm"))
	__grcmd__(sprintf("device \"%s\" op \"format:ppm\"", \
			  grdevname));
      endif

    elseif strcmp(dev, "mif")
      grdevname = "MIF";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname)); 

    elseif strcmp(dev, "gmf")
      grdevname = "Metafile";
      __grcmd__(sprintf("hardcopy device \"%s\"", grdevname)); 

    endif;
    
#    eval (sprintf ("__gnuplot_set__ output \"%s\";", name));
#    replot;

    __grcmd__(sprintf("print to \"%s\"; print", name));
   
  unwind_protect_cleanup

    ## Restore init state
#     if ! isempty (terminal_default)
#       #      eval (sprintf ("__gnuplot_set__ terminal %s;", terminal_default));
#       duh = sprintf("set terminal %s\n", terminal_default);
#       __gnuplot_raw__(duh);
#     endif
#     eval (sprintf ("__gnuplot_set__ terminal %s;", origterm));
#     if isempty (origout)
#       __gnuplot_set__ output;
#     else
#       eval (sprintf ("__gnuplot_set__ output \"%s\";", origout));
#     end
#     replot;
    
#     automatic_replot = _automatic_replot ;

  end_unwind_protect

  if(doprint)
    system(sprintf ("lpr %s %s", printer, printname));
    unlink(printname);
  elseif(!isempty(convertname))
    command = [ "convert ", name, " ", convertname ];
    [errcode, output] = system (command);
    unlink (name);
    if (errcode)
      error ("print: could not convert");
    endif
  endif

endfunction

