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
%% @end deftypefn
function [pkgtar htmltar] = releasePKG (pkgname, varargin)
  OFPATH = getenv ('OFPATH');
  use_inputP = exist('inputParser') == 2;

  if use_inputP
    parser = inputParser ();
    parser = addParamValue (parser,'repopath', OFPATH , @ischar);
    parser = addParamValue (parser,'outpath', pwd (), @ischar);

    parser = parse(parser,varargin{:});
  else
    opt = {varargin{1:2:end}};
    val = {varargin{2:2:end}};
    parser.Results.repopath = OFPATH;
    parser.Results.outpath = pwd ();

    if !isempty(opt)
      [tf indx] = ismember (fieldnames(parser.Results), opt);
      opt{indx(tf)} = opt{indx(tf)};
      val{indx(tf)} = val{indx(tf)};
      for i=1:numel(opt)
        parser.Results.(opt{i}) = val{i};
      end
    endif

    checkrepopath(parser.Results.repopath);

  end



  % Export from repo
  outpath = checkpath(parser.Results.outpath);

  exported = sprintf ([outpath "%s"], pkgname);

  % Repo path
  svn_repo = checkpath(parser.Results.repopath);
  disp(['Exporting from ' svn_repo]);

  export_call = ["svn export " svn_repo filesep() pkgname " " exported " --force"];
  if system (export_call);
    error ("Can not export.\n");
  elseif isempty (OFPATH) || !strcmpi(svn_repo, OFPATH)
    setenv('OFPATH',parser.Results.repopath);
    printf (["\nEnvironment variable OFPATH set to %s\n" ...
              'add setenv("OFPATH","%s");' ...
              'to your .octaverc to make it permanent.' "\n\n"], ...
                           parser.Results.repopath, parser.Results.repopath);
    fflush (stdout);

    % Delete .svnignore files
    % This works only for unix
    unix (sprintf ('find %s -name .svnignore | xargs rm -v',exported));
    % FIXME: This prints a confusing error when no .svnignore are present.
  end

  printf("Exported to %s\n", exported);
  fflush(stdout);

  % Get package version
  desc_file = textread([exported filesep() "DESCRIPTION"],"%s");
  [tf ind] = ismember ("Version:",desc_file);
  pkgversion = desc_file{ind+1};

  % Compress package
  pkgtar = sprintf ("%s-%s.tar", pkgname, pkgversion);
  tar (pkgtar, pkgname);
  gzip (pkgtar);
  pkgtar = sprintf ("%s.gz", pkgtar);

  printf ("Tared to %s\n", pkgtar);
  fflush (stdout);

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
