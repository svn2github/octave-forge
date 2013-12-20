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
## @deftypefn {Function File}  [ @var{ret} ] = test_sprdsh ()
## @deftypefnx {Function File} [ @var{ret} ] = test_sprdsh (@var{interface})
## Internal function meant for testing functionality of spreadsheet functions.

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2013-04-21
## Updates:
## 2013-12-20 Updated texinfo header & copyright strings
##     ''     Added OCT interface tests conditional of writing interfaces

function [] = test_spsh (numb = [])

  persistent xls_intf = {'com', 'poi', 'oox', 'jxl', 'oxs', ' - ', ' - ', 'uno'};
  persistent ods_intf = {' - ', ' - ', ' - ', ' - ', ' - ', 'otk', 'jod', 'uno'};

  ## Get available interfaces
  avail_intf = uint16 (chk_spreadsheet_support ());

  if (! isempty (numb))
    ## Check if numb makes sense
    if (ischar (numb))
      numb = lower (numb);
      ## First check if it is recognized in the list ofinterfaces
      if (ismember (numb, xls_intf) || ismember (numb, ods_intf))
        idx = strmatch (numb, [xls_intf ods_intf]);
        ## It is known; now check if it's actually supported at the moment
        if (bitget (avail_intf, idx))
          ## It is, set just that bit of avail_intf that's related to intf 'numb'
          avail_intf = bitset (uint16 (0), idx, 1);
        else
          ## It isn't, notify user
          error ("Requested interface \"%s\" presently not available\n", numb);
        endif
      else
        error ("Unknown interface - %s\n", numb);
      endif
    endif
  endif

  ## First all Excel xls/xlsx interfaces
  intf2 = '';
  for ii = 1:numel (xls_intf)
    intfpatt = bitset (uint16 (0), ii, 1);## uint16 so more intfs can be added
    intfchk = bitand (intfpatt, avail_intf);
    intf = [];
    fname = 'io-test.xls';
    switch intfchk
      case 1                            ## COM (ActiveX / hidden MS-Excel)
        intf = intf2 = 'com';
      case 2                            ## POI (Apache POI)
        intf = 'poi';
        tst_oct = 1;
      case 4                            ## POI/OOXML (Apache POI)
        intf = intf2 = 'poi';
        fname = 'io-test.xlsx';
      case 8                            ## JXL (JExcelAPI)
        intf = 'jxl';
      case 16                           ## OXS (OpenXLS/ Extentech)
        intf = 'oxs';
      case 128                          ## UNO (LibreOffice Java-UNO bridge)
        intf = intf2 = 'uno';
      otherwise
    endswitch
    ## If present, test selected interfaces
    if (! isempty (intf))
      printf ("\nInterface \"%s\" found.\n", upper (intf));
      io_xls_testscript (intf, fname);
    endif
  endfor
  ## Test OCT interface if possible
  if (! isempty (intf2))
    printf ("\nInterface \"OCT\"....\n");
    io_xls_testscript ("OCT", 'io-test.xlsx', intf2);
   endif

  ## Next, all (OOo/LO) ods interfaces
  intf2 = '';
  for ii = 1:numel (ods_intf)
    intfpatt = bitset (uint16 (0), ii, 1);## uint16 so more intfs can be added
    intfchk = bitand (intfpatt, avail_intf);
    intf = [];
    switch intfchk
      case 32                           ## OTK (ODF Toolkit)
        intf = intf2 = 'otk'
      case 64                           ## JOD (jOpenDocument)
        intf = intf2 = 'jod';
      case 128                          ## UNO (LibreOffice Java-UNO bridge)
        intf = intf2 = 'uno';
      otherwise
    endswitch
    ## If present, test selected interfaces
    if (! isempty (intf))
      printf ("\nInterface \"%s\" found.\n", upper (intf));
      io_ods_testscript (intf, 'io-test.ods');
    endif
  endfor
  ## Test OCT interface if possible
  if (! isempty (intf2))
    printf ("\nInterface \"OCT\"....\n");
    io_ods_testscript ("OCT", 'io-test.ods', intf2);
   endif

  printf ("End of test_spsh\n");

endfunction
