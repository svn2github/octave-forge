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
## Get string representing the first xml node @var{nname} from xml file in
## string @var{xml}, optionally starting at position @var{is}, and return
## start and end indices.
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08

function [ node, spos, epos ] = getxmlnode (xml, nname, is=1)

  node = '';
  spos = index (xml(is:end), ["<" nname]);
  if (spos)
    ## Apparently a node exists. Get its end. Maybe it is a single node
    ## ending in "/>"
    epos = index (xml(is+spos:end), "/>");
    ## Do check if the "/>" really belongs to this node
    if ((! epos) || index (xml(is+spos:is+spos+epos), "><"))
      ## Apparently it is a composite node 
      epos = index (xml(is+spos:end), ["</" nname ">"]);
      if (! epos)
        ## Apparently the xml is invalid?
        error ("getxmlnode: couldn't find matching end tag for %s", nname);
      endif
      epos = is + spos + epos + length (nname) + 1;
    else
      epos = is + spos + epos;
    endif
    spos = is + spos - 1;
    node = xml(spos:epos);
  else
    epos = 0;
  endif

endfunction
