## Copyright (C) 2013 Philip Nienhuis
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{node} =} getxmlnode (@var{xml}, @var{nname})
## @deftypefnx {Function File} {@var{node} =} getxmlnode (@var{xml}, @var{nname}, @var{is})
## @deftypefnx {Function File} {@var{node} =} getxmlnode (@var{xml}, @var{nname}, @var{is}, @var{contnt})
## Get string representing the first xml node @var{nname} from xml file in
## string @var{xml}, optionally starting at position @var{is}, and return
## start and end indices. If @var{contnt} is TRUE, return the portion of the
## node between the outer tags.
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08
## Updates
## 2013-09-30 Use regexp for start & end positions as index catches false positives
## 2013-10-01 Input validation
##     ''     Further simplified using regexp
##     ''     Option to return just node contents

function [ node, spos, epos ] = getxmlnode (xml, nname, is=1, contnt=0)

  if (nargin >= 3 && isempty (is))
    is = 1;
  endif

  ## Input validation
  if (! ischar (xml) || ! ischar (nname))
    error ("getxmlnode: text strings expected for first two args");
  elseif (nargin==3 && (! islogical (is) && ! isnumeric (is)))
    error ("getxmlnode: logicalor numerical value expected for arg #3");
  elseif (nargin==4 && (! islogical (contnt) && ! isnumeric (contnt)))
    error ("getxmlnode: logicalor numerical value expected for arg #3");
  endif

  is = max (is, 1);

  node = '';
  ## Start tag must end with either > or a space preceding an attribute
  spos = regexp (xml(is:end), sprintf ("<%s( |>)", nname));
  if (! isempty (spos))
    ## Apparently a node exists. Get its end. Maybe it is a single node
    ## ending in "/>"
    spos = spos(1);
    [~, epos] = regexp (xml(is+spos:end), sprintf ("(</%s>|%s[^><]*/>)", nname, nname));
    if (! isempty (epos))
      epos = epos(1);
      node = xml(is+spos-1 : is+spos+epos(1)-1);
      if (contnt)
        if (strcmp (node(end-1:end), "/>"))
          Single node tag. Return empty string
          node = '';
        else
          ## Get contents between end of opening tag en start of end tag
          node = node(index (node, ">", "first")+1 : index (node, "<", "last")-1);
        endif
      endif
    else
      error ("getxmlnode: couldn't find matching end tag for %s", nname);
    endif
    ## Update position pointers relative to input string
    epos += is + spos - 1;
    spos += is - 1;
  else
    ## No node found; reset pointers
    spos = 0;
    epos = 0;
  endif

endfunction
