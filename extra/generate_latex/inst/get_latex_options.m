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
## @deftypefn {Function File} {@var{options} =} get_latex_options (@var{document_type})
## Returns a structure containing design options for a latex manual.
##
## Given a string @var{document_type}, the function returns a structure containing
## various types of information for generating latex manual for the specified document type.
## Currently, the accepted values of @var{document_type} are
##
## @table @minus
## @item "amsart_a5"
## amsart document class on a5 paper.
## @item "article_a4"
## amsart document class on a5 paper.
## @end table
## @seealso{generate_package_latex, latex_help_text}
## @end deftypefn

function options = get_latex_options (project_name)
  ## Check input
  if (nargin == 0)
    error ("get_latex_options: not enough input arguments");
  endif
  
  if (!ischar (project_name))
    error ("get_latex_options: first input argument must be a string");
  endif
  
  ## Generate options depending on project
  switch (lower (project_name))
    case "amsart_a5"
      options = amsart_a5_options ();
    case "article_a4"
      options = article_a4_options ();
  otherwise
    error ("get_latex_options: unknown project name: %s", project_name);
  endswitch

endfunction


function options = amsart_a5_options ()

        ## Basic latex header
      hh = "\
\\documentclass{amsart} \n\
\\usepackage{geometry} \n\
\\geometry{a5paper} \n\
\\usepackage{graphicx} \n\
\\usepackage{amssymb} \n\
\\usepackage{epstopdf} \n\
\\usepackage{cprotect,fancyvrb} \n\
\\usepackage{float} \n\
\\floatstyle{ruled} \n\
\\newfloat{demo}{thp}{dem} \n\
\\floatname{demo}{Demo} \n\
\\newfloat{demoout}{thp}{deo} \n\
\\floatname{demoout}{Demo Output} \n\
\n";

    options.function_name_pre = "\\cprotect\\section{\\verb|";
    options.function_name_mangle = @(x) x;
    options.function_name_post = "|}\n";

    ## Options for alphabetical lists
    options.intro_pre = "\\section{Package Description}\n";
    options.intro_post = "%end package  description\n";
    options.name_pre = "{\\bf Name: } ";
    options.name_post = "\\\\  \n";
    options.desc_pre = "{\\bf Description: } \\\\\n";
    options.desc_post = "\\\\\n";
    options.version_pre = "{\\bf Version: } ";
    options.version_post = "\\\\   \n";
    options.date_pre = "{\\bf Release Date: } ";
    options.date_post = "\\\\ \n";
    options.author_pre = "{\\bf Author: } ";
    options.author_post = "\\\\  \n";
    options.maintainer_pre = "{\\bf Maintainer: } ";
    options.maintainer_post = "\\\\ \n";
    options.license_pre = "{\\bf License: } ";
    options.license_post = "\\\\ \n";
    options.deps_pre = "{\\bf Depends on: } \\\\ \n";
    options.deps_post = "\\null \n";
    options.deps_sep = "\\\\ \n";
    options.buildreq_pre = "{\\bf Build dependencies: } \\\\ \n";
    options.buildreq_post = "\\\\ \n";
    options.autoload_pre = "{\\bf Autoload: } \n";
    options.autoload_post = "\\\\ \n"; 
    
    ## Options for individual function pages
    options.header = "\\begin{SaveVerbatim}{VerbBox}\n";
    options.footer = "\\end{SaveVerbatim}\n\\resizebox{.9\\linewidth}{!}{\\BUseVerbatim{VerbBox}}";
    options.include_demos = true;
    
    ## Options for overview page
    options.main_header = sprintf ("%s", hh);
    options.main_footer = " ";
    options.include_toc = true;
        
    ## Options for COPYING file
    options.include_package_license = true;
    options.license_file_pre = "\\begin{Verbatim}";
    options.license_file_post = "\\end{Verbatim}\n\\null\n";

endfunction

function options = article_a4_options ()

        ## Basic latex header
      hh = "\
\\documentclass[10pt]{article} \n\
\\usepackage{geometry} \n\
\\geometry{a4paper} \n\
\\usepackage{graphicx} \n\
\\usepackage{amssymb} \n\
\\usepackage{epstopdf} \n\
\\usepackage{cprotect} \n\
\\usepackage{float} \n\
\\floatstyle{plain} \n\
\\newfloat{demo}{thp}{dem} \n\
\\floatname{demo}{Demo} \n\
\\newfloat{demoout}{thp}{deo} \n\
\\floatname{demoout}{Demo Output} \n\
\n";

    options.function_name_pre = "\\section{";
    options.function_name_mangle = @(x) __ec__ (x);
    options.function_name_post = "}\n";

    ## Options for alphabetical lists
    options.intro_pre = "\\section{Package Description}\n";
    options.intro_post = "%end package  description\n";
    options.name_pre = "{\\bf Name: } ";
    options.name_post = "\\\\  \n";
    options.desc_pre = "{\\bf Description: } \\\\\n";
    options.desc_post = "\\\\\n";
    options.version_pre = "{\\bf Version: } ";
    options.version_post = "\\\\   \n";
    options.date_pre = "{\\bf Release Date: } ";
    options.date_post = "\\\\ \n";
    options.author_pre = "{\\bf Author: } ";
    options.author_post = "\\\\  \n";
    options.maintainer_pre = "{\\bf Maintainer: } ";
    options.maintainer_post = "\\\\ \n";
    options.license_pre = "{\\bf License: } ";
    options.license_post = "\\\\ \n";
    options.deps_pre = "{\\bf Depends on: } \\\\ \n";
    options.deps_post = "\\null \n";
    options.deps_sep = "\\\\ \n";
    options.buildreq_pre = "{\\bf Build dependencies: } \\\\ \n";
    options.buildreq_post = "\\\\ \n";
    options.autoload_pre = "{\\bf Autoload: } \n";
    options.autoload_post = "\\\\ \n";  
    
    ## Options for individual function pages
    options.header = "\\begin{verbatim}\n";
    options.footer = "\\end{verbatim}\n";
    options.include_demos = true;
    
    ## Options for overview page
    options.main_header = sprintf ("%s", hh);
    options.main_footer = " ";
    options.include_toc = true;
        
    ## Options for COPYING file
    options.include_package_license = true;
    options.license_file_pre = "\\begin{verbatim}";
    options.license_file_post = "\\end{verbatim}\n\\null\n";

endfunction