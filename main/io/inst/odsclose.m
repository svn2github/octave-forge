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

## -*- texinfo -*-
## @deftypefn {Function File} [@var{ods}] = odsclose (@var{ods})
## Close the OpenOffice_org Calc spreadsheet pointed to in struct
## @var{ods}, if needed write the file to disk. An empty pointer struct
## will be returned. odsclose will determine if the file must be written
## to disk based on information contained in @var{ods}.
##
## You need the Java package > 1.2.6 plus odfdom.jar + xercesImpl.jar
## and/or jopendocument-<version>.jar installed on your computer +
## proper javaclasspath set, to make this function work at all.
##
## @var{ods} must be a valid pointer struct made by odsopen() in the same
## octave session.
##
## Examples:
##
## @example
##   ods1 = odsclose (ods1);
##   (Close spreadsheet file pointed to in pointer struct ods1; ods1 is reset)
## @end example
##
## @seealso odsopen, odsread, odswrite, ods2oct, oct2ods, odsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Updates:
## 2010-01-08 (OTK ODS write support)
## 2010-04-13 Improved help text a little bit
## 2010-08-25 Swapped in texinfo help text

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
