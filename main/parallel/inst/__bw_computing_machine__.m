## Copyright (C) 2009 Olaf Till <olaf.till@uni-jena.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function __bw_computing_machine__ (f)

  ## internal function of the parallel package, not meant for explicit use

  while (true) # exits if eof

    try
      if (ismatrix (arg = __bw_prcv__ (stdin)))
	exit (0);
      endif
    catch
      exit (0);
    end_try_catch
    arg = arg.psend_var;
    try
      if (ismatrix (arg_id = __bw_prcv__ (stdin)))
	exit (0);
      endif
    catch
      exit (0);
    end_try_catch
    arg_id = arg_id.psend_var;

    try
      res = feval (f, arg, arg_id);
      err = false;
    catch
      err = true;
      msg = lasterr ();
    end_try_catch

    if (err)
      __bw_psend__ (stdout, 2);
      __bw_psend__ (stdout, msg);
    else
      __bw_psend__ (stdout, 0);
      __bw_psend__ (stdout, res);
    endif
    fflush (stdout);

  endwhile

endfunction