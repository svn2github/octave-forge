## Copyright (C) 2005 Bill Denney
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} savepath (@var{file})
## This function saves the current @code{LOADPATH} to your personal
## default initilization file or optionally the @var{file} that you
## specify.
##
## It will return 0 if it was successful.
##
## @seealso{LOADPATH,addpath,rmpath}
## @end deftypefn

## Author: Bill Denney <bill@givebillmoney.com>

function varargout = savepath(savefile)

  retval = 1;

  beginstring = "## Begin savepath auto-created section, do not edit";
  endstring   = "## End savepath auto-created section";

  if nargin == 0
    savefile = [ getenv("HOME"), "/.octaverc" ];
  end

  %% parse the file if it exists to see if we should replace a section
  %% or create a section
  startline = 0;
  endline = 0;
  filelines = {};
  if (exist(savefile) == 2)
    %% read in all lines of the file
    [fid, msg] = fopen(savefile, "rt");
    if (fid < 0)
      error(["savepath: could not open savefile, " savefile ": " msg]);
    end
    linenum = 0;
    while (linenum >= 0)
      result = fgetl(fid);
      if isnumeric(result)
	%% end at the end of file
	linenum = -1;
      else
	linenum = linenum + 1;
	filelines{linenum} = result;
	%% find the first and last lines if they exist in the file
	if (strcmp(result, beginstring))
	  startline = linenum;
	elseif (strcmp(result, endstring))
	  endline = linenum;
	end
      end
    end
    closeread = fclose(fid);
    if (closeread < 0)
      error(["savepath: could not close savefile after reading, " savefile]);
    end
  end

  if (startline > endline) || ((startline > 0) && (endline == 0))
    error(["savepath: unable to parse file, " savefile ". There was " ...
	   "probably a start line without an end line or end without start."])
  end

  %% put the path into a cell array
  pathlines = { beginstring, ["  LOADPATH=\"",LOADPATH,"\";"], endstring };

  %% put the current savepath lines into the file
  if (isempty(filelines)) || ...
	((startline == 1) && (endline == length(filelines)))
    %% savepath is the entire file
    pre = post = {};
  elseif endline == 0
    %% drop the savepath statements at the end of the file
    pre = filelines;
    post = {};
  elseif (startline == 1)
    pre = {};
    post = filelines(endline+1:end);
  elseif (endline == length(filelines))
    pre = filelines(1:startline-1);
    post = {};
  else
    %% insert in the middle
    pre = filelines(1:startline-1);
    post = filelines(endline+1:end);
  end

  %% write the results
  [fid, msg] = fopen(savefile, "wt");
  if (fid < 0)
    error(["savepath: unable to open file for writing, " savefile ", " msg]);
  end
  for i = 1:length(pre), fprintf(fid, "%s\n", pre{i}); end
  for i = 1:length(pathlines), fprintf(fid, "%s\n", pathlines{i}); end
  for i = 1:length(post), fprintf(fid, "%s\n", post{i}); end
  closeread = fclose(fid);
  if (closeread < 0)
    error(["savepath: could not close savefile after writing, " savefile]);
  end

  retval = 0;

  if (nargout == 1)
    varargout{1} = retval;
  end
