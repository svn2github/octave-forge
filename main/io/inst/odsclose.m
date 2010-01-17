## Copyright (C) 2009 Philip Nienhuis <prnienhuis at users.sf.net>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
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

## odsclose - close an ods spreadsheet file
## usage: ods = odsclose (ods)

## Author: Philip Nienhuis
## Created: 2009-12-13
## Last update: 2010-01-08 (OTK ODS write support)

function [ ods ] = odsclose (ods)

	# If needed warn that dangling spreadsheet pointers may be left
	if (nargout < 1) warning ("return argument missing - ods invocation not reset."); endif

	if (strcmp (ods.xtype, 'OTK'))
		# Java & ODF toolkit
		if (ods.changed), ods.app.save (ods.filename); endif
		ods.app.close ();

	elseif (strcmp (ods.xtype, 'JOD'))
		# Java & jOpenDocument
		if (ods.changed)
			ofile = java_new ('java.io.File', ods.filename);
			ods.workbook.saveAs (ofile);
		endif

#	elseif ---- < Other interfaces here >

	else
		error (sprintf ("ods2oct: unknown OpenOffice.org .ods interface - %s.", ods.xtype));

	endif

	# Reset file pointer
	ods = [];

endfunction
