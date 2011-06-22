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
## @deftypefn {Function File} {@var{fis} =} readfis ()
## @deftypefnx {Function File} {@var{fis} =} readfis (@var{filename})
##
## Read the information in an FIS file, and using this information, create and
## return an FIS structure. If called without any arguments or with an empty
## string as an argument, present the user with a file dialog GUI. If called
## with a @var{filename} that does not end with '.fis', append '.fis' to the
## @var{filename}. The @var{filename} is expected to be a string.
##
## CURRENT LIMITATIONS:
## @itemize @bullet
## @item
## Custom membership functions are limited to 1-10 parameters.
## @item
## "Version" is not yet implemented.
## @item
## The input file must strictly adhere to the format, without
## comments or extra whitespace.
## @end itemize
##
## Three examples of the input file format:
## @itemize @bullet
## @item
## heart-disease-risk.fis
## @item
## mamdani-tip-calculator.fis
## @item
## sugeno-tip-calculator.fis
## @end itemize
##
## Four examples that use readfis:
## @itemize @bullet
## @item
## heart_demo.m
## @item
## mamdani_demo.m
## @item
## showrule_demo.m
## @item
## tipping_demo.m
## @end itemize
##
## @seealso{writefis}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      readfis.m
## Last-Modified: 20 Jun 2011

##------------------------------------------------------------------------------

function fis = readfis (filename='')

  ##--------------------------------------------------------------------------
  ## If readfis was not called with 0 or 1 arguments, or if the argument is
  ## not a string, print an error message and halt.
  ##--------------------------------------------------------------------------

  if (nargin > 1)
    puts ("Type 'help readfis' for more information.\n");
    error ("readfis requires 0 or 1 arguments\n");
  elseif ((nargin == 1) && !is_string (filename))
    puts ("Type 'help readfis' for more information.\n");
    error ("readfis's argument must be a string\n");
  endif

  ##--------------------------------------------------------------------------
  ## Open the input file.
  ##--------------------------------------------------------------------------

  fid = open_input_file (filename);

  ##--------------------------------------------------------------------------
  ## Read the [System] section.
  ## Using the strings read from the input file, initialize an FIS structure.
  ##--------------------------------------------------------------------------

  line_num = 1;
  [fis, num_inputs, num_outputs, num_rules, line_num] = ...
    init_fis_struct (fid, line_num);

  ##--------------------------------------------------------------------------
  ## For each FIS input, read [Input<number>] section from file.
  ## Add each new input to the FIS structure.
  ##--------------------------------------------------------------------------

  for i = 1 : num_inputs
    [next_fis_input, num_mfs, line_num] = ...
      get_next_fis_io (fid, line_num, i, 'input');
    if (i == 1)
      fis.input = next_fis_input;
    else
      fis.input = [fis.input, next_fis_input];
    endif

    ##----------------------------------------------------------------------
    ## Read membership function info for the new FIS input from file.
    ## Add each new membership function to the FIS struct.
    ##----------------------------------------------------------------------

    for j = 1 : num_mfs
      [next_mf, line_num] = get_next_mf (fid, line_num, i, j, 'input');
      if (j == 1)
        fis.input(i).mf = next_mf;
      else
        fis.input(i).mf = [fis.input(i).mf, next_mf];
      endif
    endfor
  endfor

  ##--------------------------------------------------------------------------
  ## For each FIS output, read [Output<number>] section from file.
  ## Add each new output to the FIS structure.
  ##--------------------------------------------------------------------------

  for i = 1 : num_outputs
    [next_fis_output, num_mfs, line_num] = ...
      get_next_fis_io (fid, line_num, i, 'output');
    if (i == 1)
      fis.output = next_fis_output;
    else
      fis.output = [fis.output, next_fis_output];
    endif

    ##----------------------------------------------------------------------
    ## Read membership function info for the new FIS output from file.
    ## Add each new membership function to the FIS struct.
    ##----------------------------------------------------------------------

    for j = 1 : num_mfs
      [next_mf, line_num] = get_next_mf (fid, line_num, i, j, 'output');
      if (j == 1)
        fis.output(i).mf = next_mf;
      else
        fis.output(i).mf = [fis.output(i).mf, next_mf];
      endif
    endfor
  endfor

  ##--------------------------------------------------------------------------
  ## Read [Rules] section from file.
  ## Add the rules to the FIS.
  ##--------------------------------------------------------------------------

  line = get_line (fid, line_num++);
  line = get_line (fid, line_num++);
  for i = 1 : num_rules
    [next_rule, line_num] = ...
      get_next_rule (fid, line_num, num_inputs, num_outputs);
    if (i == 1)
      fis.rule = next_rule;
    else
      fis.rule = [fis.rule, next_rule];
    endif
  endfor
endfunction

##------------------------------------------------------------------------------
## Function: open_input_file
## Purpose:  Open the input file specified by the filename. If the filename does
##           not end with ".fis", then append ".fis" to the filename before
##           opening. Return an fid if successful. Otherwise, print an error
##           message and halt.
##------------------------------------------------------------------------------

function fid = open_input_file (filename)

  ##--------------------------------------------------------------------------
  ## If the filename is not empty, and if the last four characters of the
  ## filename are not '.fis', append '.fis' to the filename. If the filename
  ## is empty, use a dialog to select the input file.
  ##--------------------------------------------------------------------------

  fn_len = length (filename);
  if (fn_len == 0)
    dialog = 1;
  else
    dialog = 0;
  endif
  if (((fn_len >= 4) && !strcmp(".fis",filename(fn_len-3:fn_len))) || ...
      ((fn_len > 0) && (fn_len < 4)))
    filename = [filename ".fis"];
  elseif (dialog)
    system_command = sprintf ("zenity --file-selection; echo $file", ...
                              filename);
    [dialog_error, filename] = system (file = system_command);
    if (dialog_error)
      puts ("Type 'help readfis' for more information.\n");
      error ("error selecting file using dialog\n");
    endif
    filename = strtrim (filename);
  endif

  ##--------------------------------------------------------------------------
  ## Open input file.
  ##--------------------------------------------------------------------------

  [fid, msg] = fopen (filename, "r");
  if (fid == -1)
    if (dialog)
      system ('zenity --error --text "Error opening input file."');
    endif
    puts ("Type 'help readfis' for more information.\n");
    printf ("Error opening input file: %s\n", msg);
    error ("error opening input file\n");
  endif

endfunction

##------------------------------------------------------------------------------
## Function: init_fis_struct
## Purpose:  Read the [System] section of the input file. Using the strings read
##           from the input file, create a new FIS. If an error in the format of
##           the input file is found, print an error message and halt.
##------------------------------------------------------------------------------

function [fis, num_inputs, num_outputs, num_rules, line_num] = ...
            init_fis_struct (fid, line_num)

  ##--------------------------------------------------------------------------
  ## Read the [System] section.
  ##--------------------------------------------------------------------------

  line = get_line (fid, line_num++);
  line = get_line (fid, line_num++);
  [fis_name, count] = sscanf (line, "Name='%s", "C");
  if (count != 1)
    error ("line %d: name of FIS expected\n", --line_num);
  endif
  fis_name = trim_last_char (fis_name);

  line = get_line (fid, line_num++);
  [fis_type, count] = sscanf (line, "Type='%s", "C");
  if (count != 1)
    error ("line %d: type of FIS expected\n", --line_num);
  endif
  fis_type = trim_last_char (fis_type);

  line = get_line (fid, line_num++);
  [fis_version, count] = sscanf (line, "Version=%f", "C");
  if (count != 1)
    error ("line %d: version of FIS expected\n", --line_num);
  endif

  line = get_line (fid, line_num++);
  [num_inputs, count] = sscanf (line, "NumInputs=%d", "C");
  if (count != 1)
    error ("line %d: number of inputs expected\n", --line_num);
  endif

  line = get_line (fid, line_num++);
  [num_outputs, count] = sscanf (line, "NumOutputs=%d", "C");
  if (count != 1)
    error ("line %d: number of oututs expected\n", --line_num);
  endif

  line = get_line (fid, line_num++);
  [num_rules, count] = sscanf (line, "NumRules=%d", "C");
  if (count != 1)
    error ("line %d: number of rules expected\n", --line_num);
  endif

  line = get_line (fid, line_num++);
  [and_method, count] = sscanf (line, "AndMethod='%s", "C");
  if (count != 1)
    error ("line %d: and method expected\n", --line_num);
  endif
  and_method = trim_last_char (and_method);

  line = get_line (fid, line_num++);
  [or_method, count] = sscanf (line, "OrMethod='%s", "C");
  if (count != 1)
    error ("line %d: or method expected\n", --line_num);
  endif
  or_method = trim_last_char (or_method);

  line = get_line (fid, line_num++);
  [imp_method, count] = sscanf (line, "ImpMethod='%s", "C");
  if (count != 1)
    error ("line %d: implication method expected\n", --line_num);
  endif
  imp_method = trim_last_char (imp_method);

  line = get_line (fid, line_num++);
  [agg_method, count] = sscanf (line, "AggMethod='%s", "C");
  if (count != 1)
    error ("line %d: aggregation method expected\n", --line_num);
  endif
  agg_method = trim_last_char (agg_method);

  line = get_line (fid, line_num++);
  [defuzz_method, count] = sscanf (line, "DefuzzMethod='%s", "C");
  if (count != 1)
    error ("line %d: defuzzification method expected\n", --line_num);
  endif
  defuzz_method = trim_last_char (defuzz_method);

  ##--------------------------------------------------------------------------
  ## Create a new FIS structure using the strings read from the input file.
  ##--------------------------------------------------------------------------

  fis = struct ('name', fis_name, ...
                'type', fis_type, ...
                'andMethod', and_method, ...
                'orMethod', or_method, ...
                'impMethod', imp_method, ...
                'aggMethod', agg_method, ...
                'defuzzMethod', defuzz_method, ...
                'input', [], ...
                'output', [], ...
                'rule', []);

endfunction

##------------------------------------------------------------------------------
## Function: get_next_fis_io
## Purpose:  Read the next [Input<i>] or [Output<i>] section of the input file.
##           Using the info read from the input file, create a new FIS input or
##           output structure. If an error in the format of the input file is
##           found, print an error message and halt.
##------------------------------------------------------------------------------

function [next_fis_io, num_mfs, line_num] = ...
             get_next_fis_io (fid, line_num, i, in_or_out)

  ##--------------------------------------------------------------------------
  ## Read [Input<i>] or [Output<i>] section from file.
  ##--------------------------------------------------------------------------

  line = get_line (fid, line_num++);
  line = get_line (fid, line_num++);
  if (strcmp ('input', in_or_out))
    [io_index, count] = sscanf (line, "[Input%d", "C");
  else
    [io_index, count] = sscanf (line, "[Output%d", "C");
  endif
  if ((count != 1) || (io_index != i))
    error ("line %d: next input or output expected\n", --line_num);
  endif

  line = get_line (fid, line_num++);
  [var_name, count] = sscanf (line, "Name='%s", "C");
  if (count != 1)
    error ("line %d: name of %s %d expected\n", --line_num, in_or_out, i);
  endif
  var_name = trim_last_char (var_name);

  line = get_line (fid, line_num++);
  [range_low, range_high, count] = sscanf (line, "Range=[%f %f]", "C");
  if ((count != 2) || (range_low > range_high))
    error ("line %d: range for %s %d expected\n", --line_num, in_or_out, i);
  endif

  line = get_line (fid, line_num++);
  [num_mfs, count] = sscanf (line, "NumMFs=%d", "C");
  if (count != 1)
    error ("line %d: number of MFs for %s %d expected\n", --line_num, ...
           in_or_out, i);
  endif

  ##--------------------------------------------------------------------------
  ## Create a new FIS input or output structure.
  ##--------------------------------------------------------------------------

  next_fis_io = struct ('name', var_name, 'range', [range_low, range_high], ...
                        'mf', []);

endfunction

##------------------------------------------------------------------------------
## Function: get_next_mf
## Purpose:  Read information specifying the jth membership function for 
##           Input<i> or Output<i> (if in_or_out is 'input' or 'output',
##           respectively) from the input file. Create a new membership
##           function structure using the info read. If an error in the format
##           of the input file is found, print an error message and halt.
##------------------------------------------------------------------------------

function [next_mf, line_num] = get_next_mf (fid, line_num, i, j, in_or_out)
            
  ##--------------------------------------------------------------------------
  ## Read membership function info for the new FIS input or output from file.
  ##--------------------------------------------------------------------------

  line = get_line (fid, line_num++);
  line_vec = strsplit (line, ":'[]", true);
  mf_index = sscanf (line_vec{1}, "MF%d", "C");
  mf_name = line_vec{2};
  mf_type = line_vec{3};
  if (mf_index != j)
    error ("line %d: next MF for %s %d expected\n", --line_num,
           in_or_out, i);
  endif

  [mf_params, count] = sscanf (line_vec{5}, ...
                       "%f %f %f %f %f %f %f %f %f %f", [1, Inf]);
  if (count == 0)
    error ("line %d: %s %d MF%d params expected\n", --line_num,
           in_or_out, i, j);
  endif

  ##--------------------------------------------------------------------------
  ## Create a new membership function structure.
  ##--------------------------------------------------------------------------

  next_mf = struct ('name', mf_name, 'type', mf_type, 'params', mf_params);

endfunction

##------------------------------------------------------------------------------
## Function: get_next_rule
## Purpose:  Read the next rule from the input file. Create a struct for the new
##           rule. If an error in the format of the input file is found, print
##           an error message and halt.
##------------------------------------------------------------------------------

function [next_rule, line_num] = get_next_rule (fid, line_num, num_inputs, ...
                                                num_outputs)

  line = get_line (fid, line_num++);
  line_vec = strsplit (line, ",():", true);

  ##--------------------------------------------------------------------------
  ## Read antecedent.
  ##--------------------------------------------------------------------------
  format_str = "%d";
  for j = 2 : num_inputs
    format_str = [format_str " %d"];
  endfor
  [antecedent, count] = sscanf (line_vec{1}, format_str, [1, num_inputs]);
  if (length (antecedent) != num_inputs)
    error ("Line %d: Rule antecedent expected.\n", line_num);
  endif

  ##--------------------------------------------------------------------------
  ## Read consequent.
  ##--------------------------------------------------------------------------
  format_str = "";
  for j = 1 : num_outputs
    format_str = [format_str " %d"];
  endfor
  [consequent, count] = sscanf (line_vec{2}, format_str, [1, num_outputs]);
  if (length (consequent) != num_outputs)
    error ("Line %d: Rule consequent expected.\n", line_num);
  endif

  ##--------------------------------------------------------------------------
  ## Read weight.
  ##--------------------------------------------------------------------------
  [weight, count] = sscanf (line_vec{3}, "%f", "C");
  if (count != 1)
    error ("Line %d: Rule weight expected.\n", line_num);
  endif

  ##--------------------------------------------------------------------------
  ## Read connection.
  ##--------------------------------------------------------------------------
  [connection, count] = sscanf (line_vec{5}, "%d", "C");
  if ((count != 1) || (connection < 1) || (connection > 2))
    error ("Line %d: Antecedent connection expected.\n", line_num);
  endif

  ##--------------------------------------------------------------------------
  ## Create a new rule struct.
  ##--------------------------------------------------------------------------
  next_rule = struct ('antecedent', antecedent, ...
                      'consequent', consequent, ...
                      'weight', weight, ...
                      'connection', connection);

endfunction

##------------------------------------------------------------------------------
## Function: get_line
## Purpose:  Read the next line of the input file (without the newline) into
##           line. Print an error message and halt on eof.
##------------------------------------------------------------------------------

function line = get_line (fid, line_num)

  line = fgetl (fid);
  if (isequal (line, -1))
    error ("unexpected end of file at line %d", line_num);
  endif

endfunction

##------------------------------------------------------------------------------
## Function: trim_last_char
## Purpose:  Return a copy of the input string without its final character.
##------------------------------------------------------------------------------

function str = trim_last_char (str)

  str = str(1 : length (str) - 1);

endfunction
