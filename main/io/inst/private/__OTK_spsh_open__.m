## Copyright (C) 2012 Philip
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

## __OTK_SPSH_open

## Author: Philip <Philip@DESKPRN>
## Created: 2012-10-12

function [ ods, odssupport, lastintf ] = __OTK_spsh_open__ (ods, rw, filename, odssupport, chk2, odsinterfaces)

    # Parts after user gfterry in
    # http://www.oooforum.org/forum/viewtopic.phtml?t=69060
    odftk = 'org.odftoolkit.odfdom.doc';
    try
      if (rw > 2)
        # New spreadsheet
        wb = java_invoke ([odftk '.OdfSpreadsheetDocument'], 'newSpreadsheetDocument');
      else
        # Existing spreadsheet
        wb = java_invoke ([odftk '.OdfDocument'], 'loadDocument', filename);
      endif
      ods.workbook = wb.getContentDom ();    # Reads the entire spreadsheet
      ods.xtype = 'OTK';
      ods.app = wb;
      ods.filename = filename;
      ods.odfvsn = odsinterfaces.odfvsn;
      odssupport += 1;
      lastintf = 'OTK';
    catch
      if (odsinterfaces.JOD && ~rw && chk2)
        printf ('Couldn''t open file %s using OTK; trying .sxc format with JOD...\n', filename);
      else
        error ('Couldn''t open file %s using OTK', filename);
      endif
    end_try_catch

endfunction
