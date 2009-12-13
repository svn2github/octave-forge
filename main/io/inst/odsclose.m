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

## odsclose - close an ods spreadsheet file & if needed write out to disk
## Basic version - no checks yet

## Author: Philip Nienhuis
## Created: 2009-12-13

function [ ods ] = odsclose (ods)

	if (ods.changed > 0)
		file = java_new ('java.io.File', ods.filename);
		ods.workbook.saveAs (file);
	endif
	
	ods = [];

endfunction
