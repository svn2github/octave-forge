## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function dat = iddata (y = [], u = [], tsam = -1, varargin)

  if (nargin == 1 && isa (y, "iddata"))
    dat = y;
    return;
  elseif (nargin < 2)
    print_usage ();
  endif

  if (! issample (tsam, -1))
    error ("iddata: invalid sampling time");
  endif

  [y, u] = __adjust_iddata__ (y, u);
  [p, m, e] = __iddata_dim__ (y, u);

  outname = repmat ({""}, p, 1);
  inname = repmat ({""}, m, 1);

  dat = struct ("y", y, "outname", {outname}, "outunit", {outname},
                "u", u, "inname", {inname}, "inunit", {inname},
                "tsam", tsam, "timeunit", {""},
                "name", "", "notes", {{}}, "userdata", []);

  dat = class (dat, "iddata");
  
  if (nargin > 3)
    dat = set (dat, varargin{:});
  endif

endfunction


function [y, u] = __adjust_iddata__ (y, u)

  if (iscell (y))
    y = reshape (y, [], 1);
  else
    y = {y};
  endif
  
  if (isempty (u))
    u = [];     # avoid [](nx0) and the like
  elseif (iscell (u))
    u = reshape (u, [], 1);
  else
    u = {u};
  endif

endfunction
