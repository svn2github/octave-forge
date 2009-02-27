## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
##
## Author: Jaroslav Hajek
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
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} [@var{o1}, @var{o2}, ...] = parcellfun (nproc, fun, a1, a2, ...)
## Evaluates a function for multiple argument sets using multiple processes.
## @var{nproc} should specify the number of processes. A maximum recommended value is
## equal to number of CPUs on your machine or one less. 
## @var{fun} is a function handle pointing to the requested evaluating function.
## @var{a1}, @var{a2} etc. should be cell arrays of equal size.
## @var{o1}, @var{o2} etc. will be set to corresponding output arguments.
##
## NOTE: this function is implemented using "fork" and a number of pipes for IPC.
## On system without an efficient "fork" implementation (such as GNU/Linux), 
## it should be used with caution.
## Also, if you use a multithreaded BLAS, it may be wise to turn off multi-threading
## when using this function.
## @end deftypefn

function varargout = parcellfun (nproc, fun, varargin)
  
  if (! isscalar (nproc) || nproc <= 0 || ! isa (fun, "function_handle") || nargin < 3)
    print_usage ();
  endif

  if (nargin > 3 && ! size_equal (varargin{:}))
    error ("arguments size must match");
  endif

  ## create communication pipes.
  cmdr = cmdw = resr = resw = zeros (nproc, 1);
  err = 0;
  for i = 1:nproc
    ## command pipes
    [cmdr(i), cmdw(i), err, msg] = pipe ();
    if (err)
      break;
    endif
    ## result pipes
    [resr(i), resw(i), err, msg] = pipe ();
    if (err)
      break;
    endif
  endfor
  if (! err)
    ## status pipe
    [statr, statw, err, msg] = pipe ();
  endif
  if (err)
    error ("failed to open pipe: %s", msg);
  endif

  iproc = 0; ## the parent process
  nsuc = 0; ## number of processes succesfully forked.

  ## fork subprocesses
  for i = 1:nproc
    [pid, msg] = fork ();
    if (pid > 0)
      ## parent process. fork succeded.
      nsuc ++;
    elseif (pid == 0)
      ## child process.
      iproc = i;
      break;
    elseif (pid < 0)
      ## parent process. fork failed.
      err = 1;
      break;
    endif
  endfor

  if (iproc)
    ## child process. close unnecessary pipe ends.
    fclose (statr);
    for i = 1:nproc
      ## we won't write commands and read results
      fclose (cmdw (i));
      fclose (resr (i));
      if (i != iproc)
        ## close also those pipes that don't belong to us.
        fclose (cmdr (i));
        fclose (resw (i));
      endif
    endfor
  else
    ## parent process. close unnecessary pipe ends.
    fclose (statw);
    for i = 1:nproc
      ## we won't read commands and write results
      fclose (cmdr (i));
      fclose (resw (i));
    endfor

    if (nsuc)
      ## we forked some processes. if this is less than we opted for, gripe
      ## but continue.
      if (nsuc < nproc)
        warning ("parcellfun: only %d out of %d processes forked", nsuc, nproc);
        nproc = nsuc;
      endif
    else
      ## this is bad.
      error ("parcellfun: failed to fork processes");
    endif
  endif

  ## At this point, everything should be OK (?)

  if (iproc)
    ## the border patrol.
    try

      ## child process. indicate ready state.
      fwrite (statw, -iproc, "double");
      fflush (statw);

      myres = {};

      nargs = length (varargin);

      do
        ## get command
        cmd = fread (cmdr(iproc), 1, "double");
        if (cmd)
          ## we've got a job to do. prepare argument and return lists.
          res = cell (1, nargout);
          args = cell (1, nargs);
          for i = 1:nargs
            args{i} = varargin{i}{cmd};
          endfor

          ## evaluate function, with guard.
          try
            [res{:}] = fun (args{:});
          catch
            ## FIXME: need a better indication of result.
            res(:) = {[]};
          end_try_catch

          ## indicate ready state.
          fwrite (statw, iproc, "double");
          fflush (statw);

          ## write the result.
          ## FIXME: this can fail.
          fsave (resw(iproc), res);
          fflush (resw(iproc));

        endif
      until (cmd == 0)

    catch

      ## just indicate the error. don't quit this function !!!!
      warning ("parcellfun: unexpected error in subprocess");
      warning ("parcellfun: %s", lasterr);

    end_try_catch

    ## no more work for us. It's not a good idea to call exit (), however,
    ## because all that clean-up code would be run. 
    ## let's just pass control to a dummy sh process.
    exec ("sh", {"-c", "exit"});

    ## we should never get here.
    ## FIXME: but if we do (exec failed), what next?
    ## a good place to call abort, except that it's not available in Octave.
    warning ("parcellfun: impossible state reached in child process");

    ## anything is better than a hanging process.
    exit ();

  else
    ## parent process. 
    njobs = numel (varargin{1});
    res = cell (nargout, njobs);

    pjobs = 0;
    pending = zeros (1, nproc);

    while (pjobs < njobs || any (pending))
      ## if pipe contains no more data, that's bad
      if (feof (statr))
        warning ("parcellfun: premature exit due to closed pipe");
        break;
      endif
      ## wait for a process state.
      isubp = fread (statr, 1, "double");
      if (isubp > 0)
        ijob = pending(isubp);
        ## we have a result ready.
        ## FIXME: handle failure.
        res(:, ijob) = fload (resr(isubp));
      else
        isubp = -isubp;
      endif
      if (pjobs < njobs)
        ijob = ++pjobs;
        ## send the next job to the process.
        fwrite (cmdw(isubp), ijob, "double");
        fflush (cmdw(isubp));
        ## set pending state
        pending(isubp) = ijob;
      else
        ## send terminating signal
        fwrite (cmdw(isubp), 0, "double");
        fflush (cmdw(isubp));
        ## clear pending state
        pending(isubp) = 0;
      endif
      fprintf (stderr, "\rparcellfun: %d/%d jobs done", pjobs - sum (pending != 0), njobs);
      fflush (stderr);
    endwhile
    fputs (stderr, "\n");
    fflush (stderr);

    ## we're finished. transform the result.
    varargout = cell (1, nargout);
    shape = size (varargin{1});
    for i = 1:nargout
      varargout{i} = reshape (res(i,:), shape);
    endfor
    
  endif

endfunction
