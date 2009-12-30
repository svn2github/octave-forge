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
## @deftypefn {Function File} [ @var{numarr}, @var{txtarr}, @var{lim} ] = parsecell (@var{rawarr})
## @deftypefnx {Function File} [ @var{numarr}, @var{txtarr}, @var{lim} ] = parsecell (@var{rawarr}, @var{limits})
##
## Divide a heterogeneous 2D cell array into a 2D numeric array and a
## 2D cell array containing only strings. Both returned arrays are
## trimmed from empty outer rows and columns.
## This function is particularly useful for parsing cell arrays returned
## by functions reading spreadsheets (e.g., xlsread, odsread).
##
## Optional return argument @var{lim} contains two field with the outer
## column and row numbers of @var{numarr} and @var{txtarr} in the
## original array @var{rawarr}.
## If optional input argument @var{limits} contained the spreadsheet
## data limits returned in the spreadsheet file pointer struct
## (field xls.limits or ods.limits), optional return argument @var{lim}
## contains the real spreadsheet row & column numbers enclosing the
## origins of the numerical and text data returned in @var{numarr}
## and @var{txtarr}.
##
## Examples:
##
## @example
##   [An, Tn] = parsecell (Rn);
##   (which returns the numeric contents of Rn into array An and the
##    text data into array Tn)
## @end example
##
## @example
##   [An, Tn, lims] = parsecell (Rn, xls.limits);
##   (which returns the numeric contents of Rn into array An and the
##    text data into array Tn.)
## @end example
##
## @seealso xlsread, odsread, xls2oct, ods2oct
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Last updated: 2009-12-29

function [ numarr, txtarr, lim ] = parsecell (rawarr, rawlimits=[])

	lim = struct ( "numlimits", [], "txtlimits", []);

	numarr = [];
	txtarr = {};
	
	if (~isempty (rawarr))
		# Valid data returned. Divide into numeric & text arrays
		no_txt = 0; no_num = 0;
		if (isnumeric ([rawarr{:}]))
			numarr = num2cell (rawarr); 
			no_txt = 1;
		elseif (iscellstr (rawarr))
			txtarr = cellstr (rawarr);
			no_num = 1;
		endif
		# Prepare parsing
		[nrows, ncols] = size (rawarr);
	
		# Find text entries in raw data cell array
		txtptr = cellfun ('isclass', rawarr, 'char');
		if (~no_txt)
			# Prepare text array. Create placeholder for text cells
			txtarr = cell (size (rawarr));
			txtarr(:) = {''};
			if (any (any (txtptr)))
				# Copy any text cells found into place holder
				txtarr(txtptr) = rawarr(txtptr);
				# Clean up text array (find leading / trailing empty
				# rows & columns)
				irowt = 1;
				while (~any (txtptr(irowt, :))) irowt++; endwhile
				irowb = nrows;
				while (~any (txtptr(irowb, :))) irowb--; endwhile
				icoll = 1;
				while (~any (txtptr(:, icoll))) icoll++; endwhile
				icolr = ncols;
				while (~any (txtptr(:, icolr))) icolr--; endwhile
				# Crop textarray
				txtarr = txtarr(irowt:irowb, icoll:icolr);
				lim.txtlimits = [icoll, icolr; irowt, irowb];
				if (~isempty (rawlimits))
					correction = [1; 1];
					lim.txtlimits (:,1) = lim.txtlimits(:,1) + rawlimits(:,1) - correction;
					lim.txtlimits (:,2) = lim.txtlimits(:,2) + rawlimits(:,1) - correction;
				endif
			else
				# If no text cells found return empty text array
				txtarr = {};
			endif
		endif
		
		if (~no_num)
			# Prepare numeric array. Set all text & empty cells to
			# NaN. First get their locations
			emptr = cellfun ('isempty', rawarr);
			emptr(find (txtptr)) = 1;
			if (all (all (emptr)))
				numarr= [];
			else
				# Find leading & trailing empty rows
				irowt = 1;
				while (all(emptr(irowt, :))) irowt++; endwhile
				irowb = nrows;
				while (all(emptr(irowb, :))) irowb--; endwhile
				icoll = 1;
				while (all(emptr(:, icoll))) icoll++; endwhile
				icolr = ncols;
				while (all(emptr(:, icolr))) icolr--; endwhile
				# Put numvalues column by column into temporary storage while
				# skipping leading & trailing NaN columns & -rows.
				# As columns are usually bigger chunks than rows & octave
				# stores arrays by column, building by columns is supposedly
				# faster than bulding by rows
				tmparr = cell (1, icolr-icoll+1);
				for ii = icoll:icolr
					tmpcol = rawarr(irowt:irowb, ii);
					tmpcol(find (emptr(irowt:irowb, ii))) = NaN;
					tmparr(ii) = cat (1, tmpcol{:});
				endfor
				numarr = cat (2, tmparr{:});
				lim.numlimits = [icoll, icolr; irowt, irowb];
				if (~isempty (rawlimits))
					correction = [1; 1];
					lim.numlimits(:,1) = lim.numlimits(:,1) + rawlimits(:,1) - correction(:);
					lim.numlimits(:,2) = lim.numlimits(:,2) + rawlimits(:,1) - correction(:);
				endif
			endif
		endif

		lim.rawlimits = rawlimits;
	
	endif

endfunction
