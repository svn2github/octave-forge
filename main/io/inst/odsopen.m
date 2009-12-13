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

## odsopen - open ODS spreadsheet
## Basic version, no checks yet

## Author: Philip Nienhuis
## Created: 2009-12-13

function [ ods ] = odsopen (filename, rw=0)

	file = java_new ('java.io.File', filename);
	wb = java_invoke ('org.jopendocument.dom.spreadsheet.SpreadSheet', 'createFromFile', file);

	ods = struct ("xtype", 'JOD', "app", file, "filename", filename, "workbook", wb, "changed", 0, "limits", []);

endfunction
