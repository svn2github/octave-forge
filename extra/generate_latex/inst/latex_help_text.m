## Copyright (C) 2012 Carlo de Falco
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

## -*- texinfo -*-
## @deftypefn {Function File} latex_help_text (@var{name}, @var{outname}, @var{options})
## Writes a function help text to disk formatted as @t{LaTeX}.
##
## The help text of the function @var{name} is written to the file @var{outname}
## formatted as @t{LaTeX}. The design of the generated @t{LaTeX} page is controlled
## through the @var{options} variable. This is a structure with the following
## optional fields.
##
## @table @samp
## @item header
## This field contains the @t{LaTeX} header of the generated file.
## @item footer
## This field contains the @t{LaTeX} footer of the generated file. This should
## match the @samp{header} field to ensure all opened tags get closed.
## @end table
##
## @var{options} structures for various projects can be with the @code{get_latex_options}
## function. As a convenience, if @var{options} is a string, a structure will
## be generated by calling @code{get_latex_options}.
##
## @seealso{get_latex_options, generate_package_latex}
## @end deftypefn

function latex_help_text (name, outname, options = struct (), root = "")

  ## Get the help text of the function
  [text, format] = get_help_text (name);
  
  ## If options is a string, call get_latex_options
  if (ischar (options))
    options = get_latex_options (options);
  endif
  

  ## Take action depending on help text format
  switch (lower (format))
    case "plain text"

      header = "";
      text = sprintf ("\n%s\n", text);
      footer = "";
      
    case "texinfo"

      ## Add easily recognisable text before and after real text
      start = "###### OCTAVE START ######";
      stop  = "###### OCTAVE STOP ######";
      text = sprintf ("%s\n%s\n%s\n", start, text, stop);
      
      ## Handle @seealso
      if (isfield (options, "seealso"))
        seealso = @(args) options.seealso (root, args);
      else
        seealso = @(args) latex_see_also_with_prefix (root, args {:});
      endif

      ## Run makeinfo
      [text, status] = __makeinfo__ (text, "plain text", seealso);
      if (status != 0)
        error ("latex_help_text: couln't parse file '%s'", name);
      endif
      
      ## Split text into header, body, and footer using the text we added above
      start_idx = strfind (text, start);
      stop_idx = strfind (text, stop);
      header = text (1:start_idx - 1);
      footer = text (stop_idx + length (stop):end);
      text = text (start_idx + length (start):stop_idx - 1);
      
    case "not found"
      error ("latex_help_text: `%s' not found\n", name);
    otherwise
      error ("latex_help_text: internal error: unsupported help text format: '%s'\n", format);
    endswitch

    ## Read 'options' input argument
    [header, title, footer] = get_header_title_and_footer (options, name, root);
    
    ## Add demo:// links if requested
    if (isfield (options, "include_demos") && options.include_demos)

      ## Determine if we have demos
      [code, idx] = test (name, "grabdemo");

      ## Demos to the main text
      demo_text = "";
      if (length (idx) > 1)
        
        outdir = fileparts (outname);
        imagedir = "images";
        full_imagedir = fullfile (outdir, imagedir);
        num_demos = length (idx) - 1;
        demo_num = 0;

        for k = 1:num_demos

          ## Run demo
          code_k = code (idx (k):idx (k+1)-1);

          try
            [output, images] = get_output (code_k, imagedir, full_imagedir, name);
          catch
            lasterr ()
            continue;
          end_try_catch

          has_text = ! isempty (output);
          has_images = ! isempty (images);

          if (length (images) > 1)
            ft = "s";
          else
            ft = "";
          endif
          
          ## Create text
          demo_num ++;

          demo_header  = "\\begin{demo}\\centering\n";
          demo_footer  = "\\end{demo}\n";

          demo_out_header  = "\\begin{demoout}\\centering\n";
          demo_out_footer  = "\\end{demoout}\n";

          fig_header  = "\\begin{figure}\\centering\n";
          fig_footer  = "\\end{figure}\n";
          
          demo_label   = sprintf ("\\label{fig:%s_demo_%d}\n", name, demo_num);
          demo_caption = sprintf ("\\caption{Demo number %d for function %s}\n", demo_num, __ec__ (name));

          output_label   = sprintf ("\\label{fig:%s_output_%d}\n", name, demo_num);
          output_caption = sprintf ("\\caption{Output from demo number %d for function %s}\n", demo_num, __ec__ (name));

          figure_label   = sprintf ("\\label{fig:%s_figure_%d}\n", name, demo_num);
          figure_caption = sprintf ("\\caption{Figure%s produced by demo number %d for function %s}\n", ft, demo_num, __ec__ (name));

          indx = 1;
          demo_k {indx++} = strcat ("\n\n\n", demo_header, "\\begin{verbatim}\n", code_k, "\n\\end{verbatim}\n", demo_caption, demo_label, demo_footer);
          
          if (has_text)

            demo_k {indx++} = sprintf ("\n\n%s\n%s\n%s\n%s\n%s\n\n", 
                                       demo_out_header, output, 
                                       output_caption, output_label, demo_out_footer);
          endif

          if (has_images) 

            imgtxt          = sprintf ("\\includegraphics[width=.7\\linewidth]{%s%s%s}\n", "function", filesep (), images {:});
            demo_k {indx++} = strcat (fig_header, imgtxt, figure_caption, figure_label, fig_footer);
            
          endif

          demo_text = strcat (demo_text, demo_k {:});

        endfor
              
    endif

    ## Write result to disk
    fid = fopen (outname, "w");
    
    if (fid < 0)
      error ("latex_help_text: could not open '%s' for writing", outname);
    endif
    
    fprintf (fid, "%s\n%s\n%s\n%s\\clearpage\n", header, text, footer, demo_text);
    fclose (fid);
  
  endif
  
endfunction

function expanded = latex_see_also_with_prefix (prefix, root, varargin)
  header = "\n";
  footer = "\n";
  
  format = sprintf ("%%s", prefix);
  
  varargin2 = cell (1, 2*length (varargin));
  varargin2 (1:2:end) = varargin;
  varargin2 (2:2:end) = varargin;
  
  list = sprintf (format, varargin2 {:});
  
  expanded = strcat (header, list, footer);
endfunction

function [text, images] = get_output (code, imagedir, full_imagedir, fileprefix)
  ## Clear everything
  close all
  diary_file = "__diary__.txt";
  if (exist (diary_file, "file"))
    delete (diary_file);
  endif
  
  unwind_protect
    ## Setup figure and pager properties
    def = get (0, "defaultfigurevisible");
    set (0, "defaultfigurevisible", "off");
    more_val = page_screen_output (false);
    
    ## Evaluate the code
    diary (diary_file);
    eval (code);
    diary ("off");
    
    ## Read the results
    fid = fopen (diary_file, "r");
    diary_data = char (fread (fid).');
    fclose (fid);
    
    ## Remove 'diary ("off");' from the diary
    idx = strfind (diary_data, "diary (\"off\");");
    if (isempty (idx))
      text = diary_data;
    else
      text = diary_data (1:idx (end)-1);
    endif
    text = strtrim (text);
    
    ## Save figures
    if (!isempty (get (0, "currentfigure")) && !exist (full_imagedir, "dir"))
      mkdir (full_imagedir);
    endif
    
    images = {};
    while (!isempty (get (0, "currentfigure")))
      fig = gcf ();
      r = round (1000*rand ());
      name = sprintf ("%s_%d.png", fileprefix, r);
      full_filename = fullfile (full_imagedir, name);
      filename = fullfile (imagedir, name);
      print (fig, full_filename);
      images {end+1} = filename;
      close (fig);
    endwhile
    
    ## Reverse image list, since we got them latest-first
    images = images (end:-1:1);

  unwind_protect_cleanup
    delete (diary_file);
    set (0, "defaultfigurevisible", def);
    page_screen_output (more_val);
  end_unwind_protect
endfunction

