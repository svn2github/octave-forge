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
## @deftypefn {Function File} generate_package_latex (@var{name}, @var{outdir}, @var{options})
## Generate @t{LaTeX} documentation for a package.
##
## The function reads information about package @var{name} using the
## package system. This is then used to generate a bunch of
## @t{LaTeX} files; one for each function in the package, and one file including them
## all. The files are all placed in the directory @var{outdir}, which defaults
## to the current directory. The @var{options} structure is used to control
## the design of the file.
##
## As an example, the following code generates the manual for the @t{image}
## package.
##
## @example
## options = get_latex_options ("default");
## generate_package_latex ("image", "image_latex", options);
## @end example
##
## The resulting files will be available in the @t{"image_latex"} directory. The
## main fail will be called @t{"image_html/manual.tex"}.
##
## As a convenience, if @var{options} is a string, a structure will
## be generated by calling @code{get_html_options}. This means the above
## example can be reduced to the following.
##
## @example
## generate_package_latex ("image", "image_latex", "default");
## @end example
##
## It should be noted that the function only works for installed packages.
## @seealso{get_latex_options}
## @end deftypefn

function generate_package_latex (name = [], outdir = "latexdocs", options = "default")

  ## Check input
  if (isempty (name))
    list = pkg ("list");
    for k = 1:length (list)
      generate_package_latex (list {k}.name, outdir, options);
    endfor
    return;
  elseif (isstruct (name))
    desc = name;
    if (isfield (name, "name"))
      packname = desc.name;
    else
      packname = "";
    endif
  elseif (ischar (name))
    packname = name;
    pkg ("load", name);
    desc = pkg ("describe", name) {1};
  else
    error (["generate_package_latex: first input must either be the name of a ", ...
            "package, or a structure giving its description."]);
  endif
  
  if (isempty (outdir))
    outdir = packname;
  elseif (! ischar (outdir))
    error ("generate_package_latex: second input argument must be a string");
  endif
  
  ## Create output directory if needed
  if (! exist (outdir, "dir"))
    mkdir (outdir);
  endif

  packdir = fullfile (outdir, packname);
  if (! exist (packdir, "dir"))
    mkdir (packdir);
  endif

  [local_fundir, fundir] = mk_function_dir (packdir, packname, options);
  
  ## If options is a string, call get_latex_options
  if (ischar (options))
    options = get_latex_options (options);
  elseif (! isstruct (options))
    error ("generate_package_latex: third input argument must be a string or a structure");
  endif
  
  ###################################################  
  ## Generate latex pages for individual functions ##
  ###################################################
  options.footer = strrep (options.footer, "@package", packname);
  num_categories = length (desc.provides);
  anchors = implemented = cell (1, num_categories);

  for k = 1:num_categories
    F = desc.provides {k}.functions;
    category = desc.provides {k}.category;
    anchors {k} = strrep (category, " ", ""); # anchor names
   
    ## For each function in category
    num_functions = length (F);
    implemented {k} = cell (1, num_functions);
    for l = 1:num_functions
      fun = F {l};
      if (any (fun == filesep ()))
        at_dir = fileparts (fun);
        mkdir (fullfile (fundir, at_dir));
        r = "../../../";
      else
        r = "../../";
      endif
      outname = fullfile (fundir, sprintf ("%s.tex", fun));
%      try
        latex_help_text (fun, outname, options, r); 
        implemented {k}{l} = true;
%      catch
%        warning ("marking '%s' as not implemented", fun);
%        implemented {k}{l} = false;
%     end_try_catch
    endfor
  endfor  

  #########################
  ## Write main file     ##
  #########################
  first_sentences = cell (1, num_categories);
  main_filename = get_main_filename (options, desc.name);

  fid = fopen (fullfile (packdir, main_filename), "w");
  if (fid < 0)
    error ("generate_package_latex: couldn't open main file for writing");
  endif
  
  [header, title, footer] = get_main_header_title_and_footer (options, desc.name, "../");

  fprintf (fid, "%s\n", header);  
  fprintf (fid, "\\title{%s}\n", desc.name);
  fprintf (fid, "\\begin{document}\n");
  fprintf (fid, "\\maketitle\n");
  if (options.include_toc)
    fprintf (fid, "\\tableofcontents\n");
  endif


  ######################
  ## Write file intro ##
  ######################
  
  ## Get detailed information about the package
  all_list = pkg ("list");
  list = [];
  for k = 1:length (all_list)
    if (strcmp (all_list {k}.name, packname))
      list = all_list {k};
    endif
  endfor
  if (isempty (list))
    error ("generate_package_latex: couldn't locate package '%s'", packname);
  endif
  
  ## Write output  
  fprintf (fid, "%s\n", options.intro_pre);  
  fprintf (fid, "%s%s%s\n", options.name_pre, __ec__ (desc.name), options.name_post);   
  fprintf (fid, "%s%s%s\n", options.desc_pre, __ec__ (desc.description), options.desc_post);   
  fprintf (fid, "%s%s%s\n", options.version_pre, __ec__ (list.version), options.version_post);
  fprintf (fid, "%s%s%s\n", options.date_pre, __ec__ (list.date), options.date_post);
  fprintf (fid, "%s%s%s\n", options.author_pre, __ec__ (list.author), options.author_post);
  fprintf (fid, "%s%s%s\n", options.maintainer_pre, __ec__ (list.maintainer), options.maintainer_post);
  fprintf (fid, "%s%s%s\n", options.license_pre, __ec__ (list.license), options.license_post);
  if (isfield (list, "depends"))
    fprintf (fid, "%s\n", options.deps_pre);
    for k = 1:length (list.depends)
      vt = __ec__ (list.depends {k}.package);
      if (isfield (list.depends {k}, "operator") && isfield (list.depends {k}, "version"))            
        o = list.depends {k}.operator;
        v = list.depends {k}.version;
        vt = sprintf ("%s ($%s$ %s), ", vt, o, v);
      else
        vt = "";
      endif
      
      fprintf (fid, vt);
    endfor
    fprintf (fid, "%s\n", options.deps_sep);
  endif
  fprintf (fid, "%s\n", options.deps_post);

  if (isfield (list, "buildrequires"))
      fprintf (fid, "%s%s%s\n", options.buildreq_pre, list.buildrequires, options.buildreq_post);
  endif
  
  if (isfield (list, "autoload"))
    if (list.autoload)
      a = "Yes";
    else
      a = "No";
    endif
    fprintf (fid, "%s%s%s\n", options.autoload_pre, a, options.autoload_post);
  endif
  
  fprintf (fid, "%s\n", options.intro_post);  

    
  ## Generate function list by category
  for k = 1:num_categories
    F = desc.provides {k}.functions;
    category = desc.provides {k}.category;  
    first_sentences {k} = cell (1, length (F));
    
    ## For each function in category
    for l = 1:length (F)
      fun = F {l};
      if (implemented {k}{l})
        first_sentences {k}{l} = get_first_help_sentence (fun, 200);
        first_sentences {k}{l} = strrep (first_sentences {k}{l}, "\n", " ");
        
        link = sprintf ('%s%s%s.tex', local_fundir, filesep (), fun);
        fprintf (fid, "%s%s%s\n", options.function_name_pre, options.function_name_mangle (fun), options.function_name_post);
        fprintf (fid, "\\input{%s}\n", link);
      else
        fprintf (fid, "%s%s%s\n", options.function_name_pre, options.function_name_mangle (fun), options.function_name_post);
        fprintf (fid, "Not Implemnted.\n", fun);
      endif
    endfor
  endfor
    
  if (isfield (options, "include_package_license") && options.include_package_license)
    copying_filename = "COPYING.tex";
    fprintf (fid, "\\input{%s}\n", copying_filename);
  endif

  fprintf (fid, "\n%s\n\\end{document}", footer);
  fclose (fid);

  ########################
  ## Write COPYING file ##
  ########################

  if (isfield (options, "include_package_license") && options.include_package_license)
    ## Get detailed information about the package
    all_list = pkg ("list");
    list = [];
    for k = 1:length (all_list)
      if (strcmp (all_list {k}.name, packname))
        list = all_list {k};
      endif
    endfor
    if (isempty (list))
      error ("generate_package_latex: couldn't locate package '%s'", packname);
    endif

    ## Read license
    filename = fullfile (list.dir, "packinfo", "COPYING");
    fid = fopen (filename, "r");
    if (fid < 0)
      error ("generate_package_latex: couldn't open license for reading");
    endif
    contents = char (fread (fid).');
    fclose (fid);

    ## Open output file
    fid = fopen (fullfile (packdir, copying_filename), "w");
    if (fid < 0)
      error ("generate_package_latex: couldn't open COPYING file for writing");
    endif
  
    fprintf (fid, "\n%s\n", options.license_file_pre);
    fprintf (fid, "%s\n\n", contents);
    fprintf (fid, "\n%s\n", options.license_file_post);
    fclose (fid);
  endif
endfunction

