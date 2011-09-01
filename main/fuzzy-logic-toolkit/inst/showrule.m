## Copyright (C) 2011 L. Markowsky <lmarkov@users.sourceforge.net>
##
## This file is part of the fuzzy-logic-toolkit.
##
## The fuzzy-logic-toolkit is free software; you can redistribute it
## and/or modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3 of
## the License, or (at your option) any later version.
##
## The fuzzy-logic-toolkit is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the fuzzy-logic-toolkit; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} showrule (@var{fis})
## @deftypefnx {Function File} {} showrule (@var{fis}, @var{index_list})
## @deftypefnx {Function File} {} showrule (@var{fis}, @var{index_list}, @var{format})
## @deftypefnx {Function File} {} showrule (@var{fis}, @var{index_list}, @var{format}, @var{language})
##
## Show the rules for an FIS structure in verbose, symbolic, or indexed format.
##
## @noindent
## To run the demonstration code below, type @t{demo('showrule')} at the
## Octave prompt.
##
## @seealso{addrule, getfis, showfis}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy rule
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      showrule.m
## Last-Modified: 31 Aug 2011

function showrule (fis, index_list=[], format='verbose', language='english')

  ##--------------------------------------------------------------------------
  ## If the caller did not supply between 1 and 4 arguments with the correct
  ## types, print an error message and halt.
  ##--------------------------------------------------------------------------

  if (!(nargin >= 1 && nargin <= 4))
    puts ("Type 'help showrule' for more information.\n");
    error ("showrule requires between 1 and 4 arguments\n");
  elseif (!is_fis (fis))
    puts ("Type 'help showrule' for more information.\n");
    error ("showrule's first argument must be an FIS structure\n");
  elseif ((nargin >= 2) && !is_rule_index_list (index_list, length (fis.rule)))
    puts ("Type 'help showrule' for more information.\n");
    error ("showrule's second argument must be a vector of rule indices\n");
  elseif ((nargin >= 3) && !is_format (format))
    puts ("Type 'help showrule' for more information.\n");
    error ("showrule's third argument must specify the format\n");
  elseif ((nargin == 4) && !is_language (language))
    puts ("Type 'help showrule' for more information.\n");
    error ("showrule's fourth argument must specify the language\n");
  endif

  ##--------------------------------------------------------------------------
  ## If showrule was called with only one argument, create the default
  ## index list (all rule indices, in ascending order).
  ##--------------------------------------------------------------------------

  if (nargin == 1)
    index_list = 1 : length (fis.rule);
  endif

  ##--------------------------------------------------------------------------
  ## Save some numbers locally.
  ##--------------------------------------------------------------------------

  num_inputs = columns (fis.input);
  num_outputs = columns (fis.output);

  ##--------------------------------------------------------------------------
  ## Show the rules in indexed format.
  ##--------------------------------------------------------------------------

  if (strcmpi (format, 'indexed'))

    for i = 1 : length (index_list)
      current_ant = fis.rule(index_list(i)).antecedent;
      current_con = fis.rule(index_list(i)).consequent;
      current_wt = fis.rule(index_list(i)).weight;
      current_connect = fis.rule(index_list(i)).connection;

      ##------------------------------------------------------------------
      ## Print membership functions for the inputs.
      ##------------------------------------------------------------------
      if (num_inputs >= 1)
        printf ("%d", current_ant(1));
      endif
      for j = 2 : num_inputs
        printf (" %d", current_ant(j));
      endfor
      printf (", ");

      ##------------------------------------------------------------------
      ## Print membership functions for the outputs.
      ##------------------------------------------------------------------
      if (num_outputs >= 1)
        printf ("%d", current_con(1));
      endif
      for j = 2 : num_outputs
        printf (" %d", current_con(j));
      endfor

      ##------------------------------------------------------------------
      ## Print the weight in parens.
      ##------------------------------------------------------------------
      if (is_int (current_wt))
        printf (" (%d) : ", current_wt);
      else
        printf (" (%.4f) : ", current_wt);
      endif

      ##------------------------------------------------------------------
      ## Print the connection and a newline.
      ##------------------------------------------------------------------
      printf ("%d\n", current_connect);
    endfor

  ##--------------------------------------------------------------------------
  ## Show the rules in symbolic or verbose format.
  ##--------------------------------------------------------------------------

  else

    ##----------------------------------------------------------------------
    ## Create a cell array of the strings for 'and', 'or', 'is', 'is not',
    ## 'if' and 'then' in the three possible languages.
    ##----------------------------------------------------------------------

    if (strcmp (format, 'symbolic'))
      str = {"&"  "|"  ""  "=>"   "=="  "~="  "="  "~="};
    else
      switch (tolower (language))
        case 'english'
          str = {"and" "or" "If" "then" "is" "is not" "is" "is not"};
        case 'francais'
          str = {"et" "ou" "Si" "alors" "est" "n'est pas" "est" ...
                 "n'est pas"};
        case 'deutsch'
          str = {"und" "oder" "Wenn" "dann" "ist" "ist nicht" ...
                 "ist" "ist nicht"};
      endswitch
    endif

    ##----------------------------------------------------------------------
    ## For each index in the index_list, print the index number, the rule,
    ## and the weight.
    ##----------------------------------------------------------------------

    if_str = str{3};
    then_str = str{4};

    for i = 1 : length (index_list)

      connect_str = str{fis.rule(index_list(i)).connection};
      current_ant = fis.rule(index_list(i)).antecedent;
      current_con = fis.rule(index_list(i)).consequent;
      current_wt = fis.rule(index_list(i)).weight;

      ##------------------------------------------------------------------
      ## Handle the first input separately by printing:
      ##     "<rule num>. If (<var name> <is or isn't> <mem func name>) "
      ## in the specified language.
      ##------------------------------------------------------------------

      if (current_ant(1) > 0)
        is_or_isnt = str{5};
      else
        is_or_isnt = str{6};
      endif
      mf_str = fis.input(1).mf(abs(current_ant(1))).name;

      printf ("%d. %s (%s %s %s) ", index_list(i), if_str, ...
              fis.input(1).name, is_or_isnt, mf_str);

      ##------------------------------------------------------------------
      ## For each of the remaining inputs, print:
      ##     "<connection> (<var name> <is or isn't> <mem func name>) "
      ## in the specified language.
      ##------------------------------------------------------------------

      for j = 2 : num_inputs
        if (current_ant(j) > 0)
          is_or_isnt = str{5};
        else
          is_or_isnt = str{6};
        endif
        mf_str = fis.input(j).mf(abs(current_ant(j))).name;

        printf ("%s (%s %s %s) ", connect_str, fis.input(j).name, ...
                is_or_isnt, mf_str);
      endfor

      ##------------------------------------------------------------------
      ## After all inputs have been printed, print:
      ##     "then "
      ## in the specified language.
      ##------------------------------------------------------------------

      printf ("%s ", then_str);

      ##------------------------------------------------------------------
      ## For each of the outputs, print:
      ##     " (<var name> <is or isn't> <mem func name>)"
      ## in the specified language.
      ##------------------------------------------------------------------

      for j = 1 : num_outputs
        if (current_con(j) > 0)
          is_or_isnt = str{7};
        else
          is_or_isnt = str{8};
        endif
        mf_str = fis.output(j).mf(abs(current_con(j))).name;

        printf ("(%s %s %s)", fis.output(j).name, is_or_isnt, mf_str);
      endfor

      ##------------------------------------------------------------------
      ## Finally, print the weight in parens and a newline:
      ##     " (<weight>)"
      ##------------------------------------------------------------------

      if is_int (current_wt)
        printf (" (%d)\n", current_wt);
      else
        printf (" (%.4f)\n", current_wt);
      endif
    endfor

  endif

endfunction

%!demo
%! fis = readfis ('sugeno_tip_calculator.fis');
%! puts ("Output of: showrule(fis)\n");
%! showrule (fis)
%! puts ("\n");

%!demo
%! fis = readfis ('sugeno_tip_calculator.fis');
%! puts ("Output of: showrule(fis, [2 4], 'symbolic')\n");
%! showrule (fis, [2 4], 'symbolic')
%! puts ("\n");

%!demo
%! fis = readfis ('sugeno_tip_calculator.fis');
%! puts ("Output of: showrule(fis, 1:4, 'indexed')\n");
%! showrule (fis, 1:4, 'indexed')
%! puts ("\n");

%!demo
%! fis = readfis ('sugeno_tip_calculator.fis');
%! puts ("Output of: showrule(fis, 1, 'verbose', 'francais')\n");
%! showrule (fis, 1, 'verbose', 'francais')
%! puts ("\n");
