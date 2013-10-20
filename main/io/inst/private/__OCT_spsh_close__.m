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
## struct xls; for native OCT interface just set it to empty.
##
## @end deftypefn

## Author: Philip Nenhuis <prnienhuis@users.sf.net>
## Created: 2013-09-09
## Updates:
## 2013-09-23 Added in commented-out stanza for OOXML (.xlsx)
## 2013-10-20 OOXLM support

function [xls] = __OCT_spsh_close__ (xls)

  ## Below order is vital - shortest extension first as you can have file 'a.<ext>'
  ## that'll crash if we have 't.ods' but first try the 'gnumeric' extension
  if (strcmpi (xls.filename(end-3:end), ".ods"))
    ## Delete tmp file
    rmdir (xls.workbook, "s");

  elseif (strcmpi (xls.filename(end-4:end-1), ".xls"))
    ## For OOXML remove temp dir here
    rmdir (xls.workbook, "s");

  elseif (strcmpi (xls.filename(end-8:end), ".gnumeric"))
    ## Delete temporary file
    unlink (xls.workbook);

  endif

endfunction
