## Copyright (C) 2009,2010 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefnx {Function File} [@var{ods}] = odsclose (@var{ods}, @var{filename})
## Close the OpenOffice_org Calc spreadsheet pointed to in struct
## @var{ods}, if needed write the file to disk.
## odsclose will determine if the file must be written to disk based on
## information contained in @var{ods}.
## An empty pointer struct will be returned if no errors occurred. 
## Optional argument @var{filename} can be used to write changed spreadsheet
## files to an other file than opened by odsopen().
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
## 2010-10-17 Fixed typo in error message about unknown interface
## 2010-10-27 Improved file change tracking tru ods.changed
## 2010-11-12 Keep ods file pointer when write errors occur.
##      "     Added optional filename arg to change filename to be written to

function [ ods ] = odsclose (ods, filename=[])

	# If needed warn that dangling spreadsheet pointers may be left
	if (nargout < 1) warning ("return argument missing - ods invocation not reset."); endif

	if (~isempty (filename))
		if (ischar (filename))
			if (ods.changed == 0 || ods.changed > 2)
				warning ("File %s wasn't changed, new filename ignored.", ods.filename);
			else
				if (strfind (tolower (filename), '.sxc') || strfind (tolower (filename), '.ods'))
					ods.filename = filename;
				else
					error ('No .sxc or .ods filename extension specified');
				endif
			endif
		endif
	endif

	if (strcmp (ods.xtype, 'OTK'))
		# Java & ODF toolkit
		try
			if (ods.changed && ods.changed < 3)
				ods.app.save (ods.filename);
				ods.changed = 0;
			endif
			ods.app.close ();
		catch
		end_try_catch

	elseif (strcmp (ods.xtype, 'JOD'))
		# Java & jOpenDocument
		try
			if (ods.changed && ods.changed < 3)
				ofile = java_new ('java.io.File', ods.filename);
				ods.workbook.saveAs (ofile);
				ods.changed = 0;
			endif
		catch
		end_try_catch

#	elseif ---- < Other interfaces here >

	else
		error (sprintf ("ods2close: unknown OpenOffice.org .ods interface - %s.", ods.xtype));

	endif

	if (ods.changed && ods.changed < 3)
		error ( sprintf ("Could not save file %s - read-only or in use elsewhere?\nFile pointer preserved", ods.filename));
	else
		# Reset file pointer
		ods = [];
	endif

endfunction
