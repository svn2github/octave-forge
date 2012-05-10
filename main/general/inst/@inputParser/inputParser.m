## Copyright (C) 2011-2012 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{parser} =} inputParser ()
## Create object @var{parser} of the inputParser class.
##
## This class is designed to allow easy parsing of function arguments. This class
## supports four types of arguments:
##
## @enumerate
## @item mandatory (see @command{@@inputParser/addRequired});
## @item optional (see @command{@@inputParser/addOptional});
## @item named (see @command{@@inputParser/addParamValue});
## @item switch (see @command{@@inputParser/addSwitch}).
## @end enumerate
##
## After defining the function API with this methods, the supplied arguments can
## be parsed with the @command{@@inputParser/parse} method and the parsing results
## accessed with the @command{Results} accessor.
##
## @deftypefnx {Accessor method} parser.Parameters
## Return list of parameters name already defined.
##
## @deftypefnx {Accessor method} parser.Results
## Return structure with argument names as fieldnames and corresponding values.
##
## @deftypefnx {Accessor method} parser.Unmatched
## Return structure similar to @command{Results} for unmatched parameters. See
## the @command{KeepUnmatched} property.
##
## @deftypefnx {Accessor method} parser.UsingDefaults
## Return cell array with the names of arguments that are using default values.
##
## @deftypefnx {Class property} parser.CaseSensitive = @var{boolean}
## Set whether matching of argument names should be case sensitive. Defaults to false.
##
## @deftypefnx {Class property} parser.FunctionName = @var{name}
## Set function name to be used on error messages. Defauls to empty string.
##
## @deftypefnx {Class property} parser.KeepUnmatched = @var{boolean}
## Set whether an error should be given for non-defined arguments. Defaults to
## false. If set to true, the extra arguments can be accessed through
## @code{Unmatched} after the @code{parse} method. Note that since @command{Switch}
## and @command{ParamValue} arguments can be mixed, it is not possible to know
## the unmatched type. If argument is found unmatched it is assumed to be of the
## @command{ParamValue} type and it is expected to be followed by a value.
##
## @deftypefnx {Class property} parser.StructExpand = @var{boolean}
## Set whether a structure can be passed to the function instead of parameter
## value pairs. Defaults to true. Not implemented yet.
##
## The following example shows how to use this class:
##
## @example
## @group
## function check (pack, path, mat, varargin)
##     p = inputParser;                             # create object
##     p.FunctionName = "check";                    # set function name
##     p = p.addRequired ("pack", @@ischar);         # create mandatory argument
##
##     p = p.addOptional ("path", pwd(), @@ischar);  # create optional argument
##
##     ## one can create a function handle to anonymous functions for validators
##     val_mat = @@(x)isvector(x) && all( x <= 1) && all(x >= 0);
##     p = p.addOptional ("mat", [0 0], @@val_mat);
##
##     ## create two ParamValue type of arguments
##     val_type = @@(x) ischar(x) && any(strcmp(x, @{"linear", "quadratic"@});
##     p = p.addParamValue ("type", "linear", @@val_type);
##     val_verb = @@(x) ischar(x) && any(strcmp(x, @{"low", "medium", "high"@});
##     p = p.addParamValue ("tolerance", "low", @@val_verb);
##
##     ## create a switch type of argument
##     p = p.addSwitch ("verbose");
##
##     p = p.parse (pack, path, mat, varargin@{:@});
##
##     ## the rest of the function can access the input by accessing p.Results
##     ## for example, to access the value of tolerance, use p.Results.tolerance
## endfunction
##
## check ("mech");            # valid, will use defaults for other arguments
## check ();                  # error since at least one argument is mandatory
## check (1);                 # error since !ischar
## check ("mech", "~/dev");   # valid, will use defaults for other arguments
##
## check ("mech", "~/dev", [0 1 0 0], "type", "linear");  # valid
##
## ## the following is also valid. Note how the Switch type of argument can be
## ## mixed into or before the ParamValue (but still after Optional)
## check ("mech", "~/dev", [0 1 0 0], "verbose", "tolerance", "high");
##
## ## the following returns an error since not all optional arguments, `path' and
## ## `mat', were given before the named argument `type'.
## check ("mech", "~/dev", "type", "linear");
## @end group
## @end example
##
## @emph{Note 1}: a function can have any mixture of the four API types but they
## must appear in a specific order. @command{Required} arguments must be the very
## first which can be followed by @command{Optional} arguments. Only the
## @command{ParamValue} and @command{Switch} arguments can be mixed together but
## must be at the end.
##
## @emph{Note 2}: if both @command{Optional} and @command{ParamValue} arguments
## are mixed in a function API, once a string Optional argument fails to validate
## against, it will be considered the end of @command{Optional} arguments and the
## first key for a @command{ParamValue} and @command{Switch} arguments.
##
## @seealso{@@inputParser/addOptional, @@inputParser/addSwitch,
## @@inputParser/addParamValue, @@inputParser/addRequired,
## @@inputParser/createCopy, @@inputParser/parse}
## @end deftypefn

function inPar = inputParser

  if (nargin != 0)
    print_usage;
  endif

  inPar = struct;

  ## these are not to be accessed by users. Each will have a field whose names
  ## are the argnames which will also be a struct with fieldnames 'validator'
  ## and 'default'
  inPar.ParamValue    = struct;
  inPar.Optional      = struct;
  inPar.Required      = struct;
  inPar.Switch        = struct;

  ## this will be filled when the methodd parse is used and will be a struct whose
  ## fieldnames are the argnames that return their value
  inPar.Results       = struct;

  ## an 1xN cell array with argnames. It is read only by the user and its order
  ## showws the order that they were added to the object (which is the order they
  ## will be expected)
  inPar.Parameters    = {};

  inPar.CaseSensitive = false;
  inPar.FunctionName  = '';      # name of the function for the error message
  inPar.KeepUnmatched = false;
  inPar.StructExpand  = true;
  inPar.Unmatched     = struct;
  inPar.UsingDefaults = {};

  inPar = class (inPar, 'inputParser');

endfunction
