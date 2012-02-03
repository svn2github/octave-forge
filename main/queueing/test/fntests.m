## Copyright (C) 2005, 2006, 2007 David Bateman
## Modifications Copyright (C) 2009, 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox. It is based on the fntests.m
## script included in GNU Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

clear all;

global files_with_no_tests = {};
global files_with_tests = {};
global topsrcdir;
global topbuilddir;
global skip_files;

currdir = canonicalize_file_name (".");

if (nargin == 1)
  xdir = argv(){1};
else
  xdir = ".";
endif

srcdir = canonicalize_file_name (xdir);
topsrcdir = canonicalize_file_name (fullfile (xdir, ".."));
topbuilddir = canonicalize_file_name (fullfile (currdir, ".."));

if (strcmp (currdir, srcdir))
  testdirs = {srcdir};
else
  testdirs = {currdir, srcdir};
endif

#src_tree = canonicalize_file_name (fullfile (topsrcdir, "src"));
#liboctave_tree = canonicalize_file_name (fullfile (topsrcdir, "liboctave"));
script_tree = canonicalize_file_name (fullfile (topsrcdir, "inst"));
#local_script_tree = canonicalize_file_name (fullfile (currdir, "../scripts"));

fundirs = {script_tree};
skip_files = { "lee_et_al_98.m" };

# if (! strcmp (currdir, srcdir))
#   fundirs{end+1} = local_script_tree;
# endif

function print_test_file_name (nm)
  filler = repmat (".", 1, 55-length (nm));
  printf ("  %s %s", nm, filler);
endfunction

function print_pass_fail (n, p)
  if (n > 0)
    printf (" PASS %4d/%-4d", p, n);
    nfail = n - p;
    if (nfail > 0)
      printf (" FAIL %d", nfail);
    endif
  endif
  printf ("\n");
endfunction

function y = hastests (f)
  fid = fopen (f);
  str = fscanf (fid, "%s");
  fclose (fid);
  y = (findstr (str, "%!test") || findstr (str, "%!assert")
       || findstr (str, "%!error") || findstr (str, "%!warning"));
endfunction

function r = skip(nm)
  global skip_files;
  r = 0;
  for sk=skip_files
    if ( strcmp(nm,skip_files) )
      r = 1;
      break;
    endif
  endfor
endfunction

function [dp, dn, dxf, dsk] = run_test_dir (fid, d);
  global files_with_tests;
  global files_with_no_tests;
  lst = dir (d);
  dp = dn = dxf = dsk = 0;
  for i = 1:length (lst)
    nm = lst(i).name;
    if (length (nm) > 5 && strcmp (nm(1:5), "test_")
	&& strcmp (nm((end-1):end), ".m"))
      p = n = 0;
      ffnm = fullfile (d, nm);
      if (hastests (ffnm))
	print_test_file_name (nm);
	[p, n, xf, sk] = test (nm(1:(end-2)), "quiet", fid);
	print_pass_fail (n, p);
	files_with_tests(end+1) = ffnm;
      else
	files_with_no_tests(end+1) = ffnm;
      endif
      dp += p;
      dn += n;
      dxf += xf;
      dsk += sk;
    endif
  endfor
endfunction

function [dp, dn, dxf, dsk] = run_test_script (fid, d);
  global files_with_tests;
  global files_with_no_tests;
  global topsrcdir;
  global topbuilddir;
  lst = dir (d);
  dp = dn = dxf = dsk = 0;
  for i = 1:length (lst)
    nm = lst(i).name;
    if (lst(i).isdir && ! strcmp (nm, ".") && ! strcmp (nm, "..")
	&& ! strcmp (nm, "CVS"))
      [p, n, xf, sk] = run_test_script (fid, [d, "/", nm]);
      dp += p;
      dn += n;
      dxf += xf;
      dsk += sk;
    endif
  endfor
  for i = 1:length (lst)
    nm = lst(i).name;
    if (((length (nm) > 3 && strcmp (nm((end-2):end), ".cc"))
	 || (length (nm) > 2 && strcmp (nm((end-1):end), ".m")))
        && !skip(nm))
      f = fullfile (d, nm);
      p = n = xf = 0;
      ## Only run if it contains %!test, %!assert %!error or %!warning
      if (hastests (f))
	tmp = strrep (f, [topsrcdir, "/"], "");
	tmp = strrep (tmp, [topbuilddir, "/"], "../");
	print_test_file_name (tmp);
	[p, n, xf, sk] = test (f, "quiet", fid);
	print_pass_fail (n, p);
	dp += p;
	dn += n;
	dxf += xf;
	dsk += sk;
	files_with_tests(end+1) = f;
      else
	files_with_no_tests(end+1) = f;
      endif
    endif
  endfor 
  ##  printf("%s%s -> passes %d of %d tests\n", ident, d, dp, dn);
endfunction

function printf_assert (varargin)
  global _assert_printf;
  _assert_printf = cat (2, _assert_printf, sprintf (varargin{:}));
endfunction

function ret = prog_output_assert (str)
  global _assert_printf;
  if (isempty (_assert_printf))
    ret = isempty (str);
  elseif (_assert_printf(end) == "\n")
    ret = strcmp (_assert_printf(1:(end-1)), str);
  else
    ret = strcmp (_assert_printf, str);
  endif
  _assert_printf = "";
endfunction

pso = page_screen_output ();
warn_state = warning ("query", "quiet");
warning ("on", "quiet");
try
  page_screen_output (0);
  fid = fopen ("fntests.log", "wt");
  if (fid < 0)
    error ("could not open fntests.log for writing");
  endif
  test ("", "explain", fid);
  dp = dn = dxf = dsk = 0;
  printf ("\nIntegrated test scripts:\n\n");
  for i = 1:length (fundirs)
    [p, n, xf, sk] = run_test_script (fid, fundirs{i});
    dp += p;
    dn += n;
    dxf += xf;
    dsk += sk;
  endfor
  printf ("\nFixed test scripts:\n\n");
  for i = 1:length (testdirs)
    [p, n, xf, sk] = run_test_dir (fid, testdirs{i});
    dp += p;
    dn += n;
    dxf += xf;
    dsk += sk;
  endfor
  printf ("\nSummary:\n\n  PASS %6d\n", dp);
  nfail = dn - dp;
  printf ("  FAIL %6d\n", nfail);
  if (dxf > 0)
    if (dxf > 1)
      t1 = "were";
      t2 = "failures";
    else
      t1 = "was";
      t2 = "failure";
    endif
    printf ("\nThere %s %d expected %s (see fntests.log for details).\n",
	    t1, dxf, t2);
    printf ("\nExpected failures are known bugs. Please help improve\n");
    printf ("the queueing toolbox by contributing fixes for them.\n");
  endif
  if (dsk > 0)
    printf ("\nThere were %d skipped tests (see fntest.log for details).\n", dsk);
    printf ("Skipped tests are features that are disabled in this version\n");
    printf ("of the queueing toolbox\n");
  endif

  n_files_with_no_tests = length (files_with_no_tests);
  n_files = n_files_with_no_tests + length (files_with_tests);
  printf ("\n%d (of %d) files have no tests.  Please help improve the queueing toolbox by\n",
	  n_files_with_no_tests, n_files);
  printf ("contributing tests for these files (see the list in the file fntests.log).\n");
  fprintf (fid, "\nFiles with no tests:\n\n%s",
	  list_in_columns (files_with_no_tests, 80));
  fclose (fid);
  page_screen_output (pso);
  warning (warn_state.state, "quiet");
catch
  page_screen_output (pso);
  warning (warn_state.state, "quiet");
  disp (lasterr ());
end_try_catch
