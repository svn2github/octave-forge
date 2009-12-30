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
## @deftypefn {Function File} [@var{filetype}] = odsfinfo (@var{filename})
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}] = odsfinfo (@var{filename})
## Query an OpenOffice.org spreadsheet file @var{filename} (with .ods
## suffix) for some info about its contents (viz. sheet names).
##
## If @var{filename} is a recognizable OpenOffice.org spreadsheet file,
## @var{filetype} returns the string "OpenOffice.org Calc spreadsheet",
## or @'' (empty string) otherwise.
## 
## If @var{filename} is a recognizable OpenOffice.org Calc spreadsheet
## file, optional argument @var{sh_names} contains a list (cell array)
## of sheet names contained in @var{filename}, in the order (from left
## to right) in which they occur in the sheet stack.
##
## If you omit return arguments @var{filetype} and @var{sh_names} altogether,
## odsfinfo returns the sheet names + a guess for the number of rows
## containing actual data to the screen.
##
## odsfinfo execution can take its time as the entire spreadsheet has to
## be parsed to get the sheet names.
##
## Examples:
##
## @example
##   exist = odsfinfo ('test4.ods');
##   (Just checks if file test4.ods is a readable Calc file) 
## @end example
##
## @example
##   [exist, names] = odsfinfo ('test4.ods');
##   (Checks if file test4.ods is a readable Calc file and return a 
##    list of sheet names) 
## @end example
##
## @seealso odsread, ods2oct
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-17
## Last updated 2009-12-29

function [ filetype, sheetnames ] = odsfinfo (filename)

	onscreen = nargout < 1;
	
	ods = odsopen (filename);
	
	filetype = 'OpenOffice.org Calc Document';

	# To save execution time, only proceed if sheet names are wanted
	if ~(nargout == 1)

		if (strcmp (ods.xtype, 'OTK'))
			# Get contents and table (= sheet) stuff from the workbook
			odfcont = ods.workbook;		# Local copy just in case
			xpath = ods.app.getXPath;

			# Create an instance of type NODESET for use in subsequent statement
			NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');
			# Parse sheets ("tables") from ODS file
			sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
			nr_of_sheets = sheets.getLength(); 
			sheetnames = cell (nr_of_sheets, 1);

			# Get sheet names (& optionally date row count estimate)
			for ii=1:nr_of_sheets
				# Check in first part of the sheet nodeset
				tmp1 = char (sheets.item(ii-1))(1:150);
				ist = index (tmp1, 'table:name=') + 12;
				ien = index (tmp1(ist:end), '" table') - 2 + ist;
				sheetnames(ii) = tmp1(ist:ien);
				if (onscreen) 
					# Echo sheet names + row count estimate to screen
					nr_of_rows = sheets.item(ii-1).getLength ();
					printf (sprintf("%s    (~%d data rows)\n", sheetnames{ii}, nr_of_rows));
				endif
			endfor
			
		elseif (strcmp (ods.xtype, 'JOD'))
			# jOpenDocument doesn't support sheet name extraction (yet?)
			printf ("No sheet name support implemented in jOpenDocument.\n")

		else
			error (sprintf ("odsfinfo: unknown OpenOffice.org .ods interface - %s.", xls.xtype));

		endif
	endif

	ods = odsclose (ods);
	
endfunction

