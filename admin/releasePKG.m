%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[@var{pkgtar} @var{htmltar}] = } releasePKG (@var{pkgname})
%% @deftypefnx {Function File} {[@dots{}] = } releasePKG (@var{pkgname},@var{property},@var{value},@dots{})
%% Create files ready to release the Octave-Forge package @var{pkgname}.
%%
%% @var{property} and @var{value} are used to indicate where is the source of the
%% package.
%% @var{property} can be:
%% @table @samp
%% @item outpath
%% Is the path where the files will be created. If not provided the current working
%% directory @code{pwd()} is used.
%%
%% @item repopath
%% Is the path where the local copy of package is located. For example, to release
%% any package in @code{main} you should pass '<my-path.to-repository>/main'.
%% If not provided, the environment variable OFPATH is used (you can set it in your)
%% .octaverc variable or using @code{setenv()}). If that variable is empty, the
%% property must be provided the first time the function is called. After that
%% it creates the environment variable (but only for the current octave session)
%%
%% @item revsys
%% Revision control system. It can be @asis{"svn"} or @asis{"hg"}(default).
%% @end table
%% @end deftypefn

function [pkgtar htmltar] = releasePKG (pkgname, varargin)
  OFPATH     = getenv ('OFPATH');
  use_inputP = exist ('inputParser') == 2;

  if use_inputP
    parser = inputParser ();
    parser = addParamValue (parser,'repopath', OFPATH , @ischar);
    parser = addParamValue (parser,'outpath', pwd (), @ischar);
    parser = addParamValue (parser,'revsys', "hg", @ischar);

    parser = parse(parser,varargin{:});
  else
    opt = {varargin{1:2:end}};
    val = {varargin{2:2:end}};
    parser.Results.repopath = tilde_expand (OFPATH);
    parser.Results.outpath = pwd ();
    parser.Results.revsys = "hg";

    if !isempty (opt)
      [tf indx] = ismember (fieldnames(parser.Results), opt);

      opt(indx(tf)) = opt(indx(tf));
      val(indx(tf)) = val(indx(tf));
      for i=1:numel(opt)
        parser.Results.(opt{i}) = val{i};
      end
    endif

    checkrepopath(parser.Results.repopath);

  end

  % Export from repo
  outpath = tilde_expand (checkpath (parser.Results.outpath));

  pkgname_tmp = [pkgname "_tmp"];
  exported    = fullfile (pwd (), pkgname_tmp);

  % Repo path
  repo_path = tilde_expand (checkpath (parser.Results.repopath));
  disp(['Exporting from ' repo_path]);

  % Revision control system
  revsys = parser.Results.revsys;
  
  if strcmp (revsys,"svn")
    export_call = ["svn export " fullfile(repo_path,pkgname) " " exported " --force"];
    failed      = system (export_call);
  else
    cdir        = pwd ();
    cd (fullfile (repo_path,pkgname));
    export_call = ["hg archive " exported ];
    failed      = system (export_call);
    cd (cdir);
    clear cdir
  endif
  
  if failed
    error ("Can not export.\n");
  elseif isempty (OFPATH) || !strcmpi(repo_path, OFPATH)
    setenv('OFPATH',parser.Results.repopath);
    printf (["\nEnvironment variable OFPATH set to %s\n" ...
              'add setenv("OFPATH","%s");' ...
              'to your .octaverc to make it permanent.' "\n\n"], ...
                           parser.Results.repopath, parser.Results.repopath);
    fflush (stdout);
  end

  printf("Exported to %s\n", exported);
  fflush(stdout);

  %%% Directory setup and cleanup
  confirm_recursive_rmdir (0, "local");

  % Run bootstrap if found
  if has_dir ("src", exported)
    ndir = fullfile (exported,"src");
    if has_file ("bootstrap", ndir)
      odir = pwd ();
      cd (ndir);
      
      failed = system ("./bootstrap");
      if failed
        cd (odir);
        error ("Could run bootstrap.\n");
      end
      
      [success, msg] = rmdir ("autom4te.cache", "s");
      if !success
        error (msg);
      endif
      cd (odir);
    endif
  endif
  
  % Remove devel, deprecated, .*ignore an others
  to_erase = {"devel","deprecated",".svnignore",".hgignore",".hg_archival.txt"};
  for idir = 1:numel(to_erase)

    if has_dir (to_erase{idir}, exported)
      [success, msg] = rmdir (fullfile (exported, to_erase{idir}), "s");
      if !success
        error (msg);
      endif
    elseif has_file (to_erase{idir}, exported)
      delete (fullfile (exported, to_erase{idir}));
    endif
  endfor
  
  % Get package version
  desc_file  = textread (fullfile (exported,"DESCRIPTION"),"%s");
  [tf ind]   = ismember ("Version:",desc_file);
  pkgversion = desc_file{ind+1};

  % Compress package
  pkgtar = sprintf ("%s-%s.tar", pkgname, pkgversion);
  tar (pkgtar, pkgname_tmp);
  gzip (pkgtar, outpath);
  #delete (pkgtar);
  pkgtar = fullfile (outpath, sprintf ("%s.gz", pkgtar));

  printf ("Tared to %s\n", pkgtar);
  fflush (stdout);

  % Remove exported package
  rmdir (exported, "s");
  
  do_doc = input ("\nCreate documentation for Octave-Forge? [y|Yes|Y] / [n|No|N] ","s");
  do_doc = strcmpi (do_doc(1),'y');

  if do_doc
    % Install package
    printf("Installing...\n");
    fflush (stdout);
    pkg ('install', pkgtar);


    % Load package and generate_html
    printf ("Generating html...\n");
    fflush(stdout);

    pkg ('load', pkgname);
    pkg ('load','generate_html');
    pkghtml = [pkgname '-html'];
    generate_package_html (pkgname, pkghtml, 'octave-forge');

    % Compress html
    htmltar = sprintf ("%s-html.tar", pkgname);
    tar (htmltar, pkghtml);
    gzip (htmltar);
    htmltar = sprintf ("%s.gz", htmltar);

    printf ("Documentation tared to %s\n", pkghtml);
    fflush(stdout);

    % md5sum
    printf (["\nmd5sum for " htmltar "\n"]);
    fflush (stdout);
    disp ([md5sum(htmltar) " " htmltar]);

    % Uninstall package
    printf ("Uninstalling...\n");
    fflush (stdout);
    pkg ('uninstall', pkgname);

  endif % do_doc

  % md5sum
  printf (["\nmd5sum for " pkgtar "\n"]);
  fflush (stdout);
  disp ([md5sum(pkgtar) " " pkgtar]);


endfunction

function str = checkpath (str)
  if str(end) != filesep()
    str = [str filesep()];
  end
endfunction

function tf = checkrepopath (str)

  if !ischar (str)
    tf = false;
  elseif isempty (str)
    error ([' If no path to the local Octave-Forge repository is given, ' ...
              'the environment variable OFPATH should be set. '
              'Use setenv("OFPATH", path-to-repo) to set it.'])
   tf = false;
  else
   tf = true;
  end

endfunction

function tf = has_dir (ddir, exported)
  
  s  = dir (exported);
  tf = any (cellfun (@(x) strcmpi (x,ddir), {s([s.isdir]).name}));
  
endfunction

function tf = has_file (dfile, ddir)
  
  s  = dir (ddir);
  tf = any (cellfun (@(x) strcmpi (x,dfile), {s(![s.isdir]).name}));
  
endfunction

