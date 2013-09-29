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
## @deftypefn {Function File} {@var{xls} =} __OCT_spsh_close__ (@var{xls})
## Internal function! do not call directly; close spreadsheet pointer
## struct xls; for native OCT interface just set ito empty.
##
## @end deftypefn

## Author: Philip Nenhuis <prnienhuis@users.sf.net>
## Created: 2013-09-09
## Updates:
## 2013-09-23 Added in commented-out stanza for OOXML (.xlsx)

function [xls] = __OCT_spsh_close__ (xls)

## FIXME remove comments and fill OOXML clause
#  if (strcmpi (xls.filename(end-3:end), ".ods"))
    ## Not much to do here as files were closed in __OCT_spsh_open__
    xls.changed = 0;
#  else
    ## For OOXML remove temp dir here
#  endif

endfunction
