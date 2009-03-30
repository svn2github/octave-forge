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

function __bw_scheduler__ (f, argfile)

  ## internal function of the parallel package, not meant for explicit use

  ## Normally this function runs in a dedicated process, but if someone
  ## uses it differently, there could be child-processes before; but
  ## there must not be any.
  while (waitpid (-1) > 0) endwhile

  ## default directories
  data_dir = tilde_expand ("~/bw-data/");
  state_dir = tilde_expand ("~/.bw-state/");
  ## default value of minimal time-interval for saving state
  min_save_interv = 10; # seconds
  ## default timeout for connections
  connect_timeout = 30; # seconds

  ## configuration files
  systemrc = fullfile (OCTAVE_HOME (), "share/octave/site/m/startup/bwrc");
  userrc = "~/.bwrc";

  ## Read system-wide configuration, should provide
  ## "computing_machines", a cell-array with addresses, and
  ## "central_machine", a single address.
  source (systemrc);

  ## Read per-user configuration.
  if (! isempty (stat (userrc)))
    source (userrc);
  endif

  ## some preparation of configuration
  ssh_opt_str = sprintf ("-o ConnectTimeout=%i", \
			 max (round (connect_timeout), 0));

  ## read arguments
  args = __bw_load_variable__ (fullfile (data_dir, argfile));
  n_args = length (args);

  ## racing condition, but might avoid some blocked schedulers
  if (__bw_is_locked__ (lfn = \
			fullfile \
			(state_dir, \
			 sprintf ("%s-%s.lock", f, argfile))))
    return;
  endif

  ## assure unique access to state-file with an advisory locked lockfile
  lfd = __bw_lock_file__ (lfn);

  ## note pid in an extra file
  pidfn = fullfile (state_dir, sprintf ("%s-%s.pid", f, argfile));
  if ((pidfd = fopen (pidfn, "w")) < 0)
    return;
  endif
  fprintf (pidfd, "%i", getpid ());
  fclose (pidfd);

  ## initialize state
  if (isempty (stat (stfn = \
		     fullfile (state_dir, \
			       sprintf ("%s-%s.state", f, argfile)))))
    state.results = state.msg = cell (n_args, 1);
    state.active = state.ready = state.error = zeros (n_args, 1);
    state.scheduler_msg = "";
    save ("-binary", stfn, "state");
  else
    state = __bw_load_variable__ (stfn);
    if (all (state.ready))
      ## nothing to do, so quit
      return;
    endif
    state.scheduler_msg = "";
    ## reset argument information for a running scheduler
    state.active = zeros (n_args, 1);
  endif

  if (! exist ("computing_machines") || isempty (computing_machines))
    state.scheduler_msg = "no computing machines given\n";
    __bw_secure_save__ (stfn, state, "state");
    return;
  endif

  ## initialize machine information
  m_n = length (computing_machines);
  m_njobs = m_unresponsive = m_active = pids = pipesr = \
      pipesw = m_just_tried = zeros (m_n, 1);

  ## fork one permanent subprocess per machine
  cmd = "ssh";
  for id = 1:m_n
    [pdrp, pdwc, err, msg] = pipe ();
    if (err)
      state.scheduler_msg = \
	  sprintf ("error %i in creating pipe, msg: %s\n", err, msg);
      __bw_secure_save__ (stfn, state, "state");
      return;
    endif
    [pdrc, pdwp, err, msg] = pipe ();
    if (err)
      state.scheduler_msg = \
	  sprintf ("error %i in creating pipe, msg: %s\n", err, msg);
      __bw_secure_save__ (stfn, state, "state");
      return;
    endif
    [pids(id), msg] = fork ();
    if (pids(id) == 0) # child process
      pclose (pdrp);
      pclose (pdwp);
      fcntl (pdrc, F_SETFL, O_SYNC);
      while (true) # no break, process killed from parent process
	cmd_args = {ssh_opt_str, \
		    computing_machines{id}, \
		    "octave", \
		    "-q", \
		    "--eval", \
		    (sprintf \
		     ("\"__bw_computing_machine__ (\\\"%s\\\")\"", \
		      f)), \
		    "2>/dev/null"};
	constart = time;
	[pdw, pdr, pid] = popen2 (cmd, cmd_args, 1);
	while (true) # break if eof on pdr
	  arg_id = __bw_prcv__ (pdrc).psend_var;
	  __bw_psend__ (pdw, args{arg_id}, true);
	  __bw_psend__ (pdw, arg_id, true);
	  fflush (pdw);
	  try
	    if (ismatrix (tp = __bw_prcv__ (pdr)))
	      break;
	    endif
	  catch
	    break;
	  end_try_catch
	  tp = tp.psend_var;
	  if (tp == 2) # computing function returned error
	    try
	      if (ismatrix (tp = __bw_prcv__ (pdr)))
		break;
	      endif
	    catch
	      break;
	    end_try_catch
	    tp = tp.psend_var;
	    __bw_psend__ (pdwc, 2, true);
	    __bw_psend__ (pdwc, tp, true);
	    fflush (pdwc);
	  else # success
	    try
	      if (ismatrix (tp = __bw_prcv__ (pdr)))
		break;
	      endif
	    catch
	      break;
	    end_try_catch
	    tp = tp.psend_var;
	    __bw_psend__ (pdwc, 0, true);
	    __bw_psend__ (pdwc, tp, true);
	    fflush (pdwc);
	  endif
	endwhile
	waitpid (pid);
	pclose (pdr);
	pclose (pdw);
	__bw_psend__ (pdwc, 1, true); # computing machine (got) unreachable
	fflush (pdwc);
	if ((rest = connect_timeout + constart - time) > 0)
	  pause (rest);
	endif
      endwhile

      ## not reached, but left here lest they are needed sometime
      pclose (pdrc);
      pclose (pdwc);
      __exit__ (0);
    elseif (pids(id) > 0) # parent process
      pclose (pdwc);
      pclose (pdrc);
      pipesr(id) = pdrp;
      pipesw(id) = pdwp;
      fcntl (pipesr(id), F_SETFL, O_SYNC);
    else # error
      state.scheduler_msg = \
	  sprintf ("error %i in forking, msg: %s\n", pids(id), msg);
      __bw_secure_save__ (stfn, state, "state");
      return;
    endif    
  endfor

  ## scheduling section
  last_saved = time;

  while (! all (state.ready))
    args_unused = find (! (state.ready | state.active));
    m_free = cat (1, \
		  find (! (m_active | m_unresponsive)), \
		  find ((! (m_active | m_just_tried)) & \
			m_unresponsive), \
		  find ((! m_active) & m_just_tried & m_unresponsive));
    ## there should always be free childs here, give them a task
    for id = 1:min (length (m_free), length (args_unused))
      ## tell child to use this argument
      __bw_psend__ (pipesw(m_free(id)), args_unused(id), true);
      fflush (pipesw(m_free(id)));
      ## mark child active (busy) and note argument of machine
      m_active(m_free(id)) = args_unused(id);
      ## mark argument active
      state.active(args_unused(id)) = true;
    endfor

    [np, act_idx] = select (pipesr, [], [], -1);

    ## respond to childs answers
    for id = act_idx
      try
	res = __bw_prcv__ (pipesr(id)).psend_var;
      catch
	state.scheduler_msg = \
	    sprintf ("error in reading state from child %i\n", id);
	__bw_secure_save__ (stfn, state, "state");
	return;
      end_try_catch
      switch res
	case 0 # success
	  m_unresponsive(id) = false;
	  m_just_tried(id) = false;
	  m_njobs(id)++;
	  state.active(m_active(id)) = false;
	  state.ready(m_active(id)) = true;
	  try
	    state.results{m_active(id)} = __bw_prcv__ (pipesr(id)).psend_var;
	  catch
	    state.scheduler_msg = \
		sprintf ("error in reading result %i from child %i\n", \
			 m_active(id), id);
	    __bw_secure_save__ (stfn, state, "state");
	    return;
	  end_try_catch
	  m_active(id) = 0;
	case 1 # computing machine (got) unreachable
	  state.active(m_active(id)) = false;
	  m_unresponsive(id) = true;
	  m_just_tried(id) = true;
	  m_active(id) = 0;
	case 2 # computing function returned error
	  m_unresponsive(id) = false;
	  m_just_tried(id) = false;
	  m_njobs(id)++;
	  state.active(m_active(id)) = false;
	  state.ready(m_active(id)) = true;
	  state.error(m_active(id)) = true;
	  try
	    state.msg{m_active(id)} = __bw_prcv__ (pipesr(id)).psend_var;
	  catch
	    state.scheduler_msg = \
		sprintf ("error in reading functions error message for args %i from child %i\n", \
			 m_active(id), id);
	    __bw_secure_save__ (stfn, state, "state");
	    return;
	  end_try_catch
	  m_active(id) = 0;
	otherwise # invalid
	  state.scheduler_msg = \
	      sprintf ("child %i returned invalid state\n", res);
	  __bw_secure_save__ (stfn, state, "state");
	  return;
      endswitch
      ## update statefile, but not if last update was a short time ago
      if ((tp = time) - last_saved >= min_save_interv)
	state.machines.active = m_active;
	state.machines.unresponsive = m_unresponsive;
	state.machines.njobs = m_njobs;
	__bw_secure_save__ (stfn, state, "state");
	last_saved = tp;
      endif
    endfor
    if (all ((m_just_tried | ! m_unresponsive)(! m_active)))
      m_just_tried = zeros (m_n, 1);
    endif
  endwhile

  ## terminate child processes, no coredump
  for pid = pids'
    system (sprintf ("kill -9 %i", pid));
    waitpid (pid);
  endfor

  ## release lockfile
  __bw_unlock_file__ (lfd);

  ## if all is ready, unlink lockfile; earlier unlinking breaks locking
  if (all (state.ready))
    unlink (lfn);
  endif

  ## unlink pidfile
  unlink (pidfn);

endfunction