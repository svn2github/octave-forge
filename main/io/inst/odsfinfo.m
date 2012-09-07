## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{filetype}] = odsfinfo (@var{filename} [, @var{reqintf}])
## @deftypefnx {Function File} [@var{filetype}, @var{sh_names}] = odsfinfo (@var{filename} [, @var{reqintf}])
## Query an OpenOffice_org spreadsheet file @var{filename} (with ods
## suffix) for some info about its contents.
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
## odsfinfo returns the sheet names and for each sheet the actual occupied
## data ranges to the screen.The occupied cell range will have to be
## determined behind the scenes first; this can take some time.
## 
## odsfinfo execution can take its time for large spreadsheets as the entire
## spreadsheet has to be parsed to get the sheet names, let alone exploring
## used data ranges.
##
## By specifying a value of 'jod', 'otk' or 'uno' for @var{reqintf} the automatic
## selection of the java interface is bypassed and the specified interface
## will be used (if at all present).
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
## @seealso {odsread, odsopen, ods2oct, odsclose}
##
## @end deftypefn

## Author: Philip Nienhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-17
## Updates:
## 2010-01-03 Added functionality for JOD as well
## 2010-03-03 Fixed echo of proper number of occupied data rows
## 2010-03-18 Fixed proper echo of occupied data range 
##            (ah those pesky table-row-repeated & table-column-repeated attr.... :-( )
## 2010-03-18 Separated range exploration (for OTK only yet) in separate function file
## 2010-03-20 "Beautified" output (for OTK ), used range now in more tabular form
## 2010-05-23 Updated jOpenDocument support (can also get occupied data range now)
## 2010-05-31 Added remark about delays when determining occupied data range
## 2011-03-23 Adapted to odfdom 0.8.7 (changed getXPath method call)
## 2011-05-07 Experimental UNO support added
## 2011-09-03 Normal return in case of no ODS support (empty ods struct)
## 2012-01-26 Fixed "seealso" help string
## 2012-02-25 Return occupied sheet ranges in output args
##     ''     Improve echo of sheet names & ranges if interactive
## 2012-03-01 Fix wrong cell refs in UNO section ("(..)" rather than "{..}"
## 2012-06-08 Support for odfdom-0.8.8-incubator

function [ filetype, sheetnames ] = odsfinfo (filename, reqintf=[])

  onscreen = nargout < 1;

  ods = odsopen (filename, 0, reqintf);
  # If no ods support was found, odsopen will have complained. Just return here
  if (isempty (ods)), return; endif
  
  filetype = 'OpenOffice.org Calc Document';
  
  persistent adj_str; adj_str = '                              '; # 30 char filler string

  # To save execution time, only proceed if sheet names are wanted
  if ~(nargout == 1)

    if (strcmp (ods.xtype, 'OTK'))
      # Get contents and table (= sheet) stuff from the workbook
      odfcont = ods.workbook;    # Local copy just in case
      if (strcmp (ods.odfvsn, '0.8.7') || strfind (ods.odfvsn, "0.8.8"))
        xpath = ods.workbook.getXPath;
      else
        xpath = ods.app.getXPath;
      endif

      # Create an instance of type NODESET for use in subsequent statement
      NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');
      # Parse sheets ("tables") from ODS file
      sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
      nr_of_sheets = sheets.getLength(); 
      sheetnames = cell (nr_of_sheets, 2);

      # Get sheet names (& optionally date row count estimate)
      for ii=1:nr_of_sheets
        # Check in first part of the sheet nodeset
        sheetnames (ii) = sheets.item(ii-1).getTableNameAttribute ();
        [ tr, lr, lc, rc ] = getusedrange (ods, ii);
        if (onscreen) 
          printf (sprintf("%s", sheetnames{ii}));
          if (tr)
            printf (sprintf("%s (used range = %s:%s)", \
            adj_str(1:(30 - length (sheetnames{ii}))), \
            calccelladdress (tr, lc), calccelladdress (lr, rc)));
          else
            printf ("%s (empty)", adj_str(1:(30 - length (sheetnames{ii}))));
          endif
          printf ("\n");
        endif
        if (tr)
          sheetnames(ii, 2) = sprintf ("%s:%s", calccelladdress (tr, lc), calccelladdress (lr, rc));
        endif
      endfor
      
    elseif (strcmp (ods.xtype, 'JOD'))
      nr_of_sheets = ods.workbook.getSheetCount ();
      sheetnames = cell (nr_of_sheets, 2);
      for ii=1:nr_of_sheets
        sheetnames(ii) = ods.workbook.getSheet (ii-1).getName ();
        [ tr, lr, lc, rc ] = getusedrange (ods, ii);
        if (onscreen) 
          printf (sprintf("%s", sheetnames{ii}));
          if (tr)
            printf (sprintf("%s (used range = %s:%s)", \
            adj_str(1:(30 - length (sheetnames{ii}))), \
            calccelladdress (tr, lc), calccelladdress (lr, rc)));
          else
            printf ("%s (empty)", adj_str(1:(30 - length (sheetnames{ii}))));
          endif
          printf ("\n");
        endif
        if (tr)
          sheetnames(ii, 2) = sprintf ("%s:%s", calccelladdress (tr, lc), calccelladdress (lr, rc));
        endif
      endfor
      
    elseif (strcmp (ods.xtype, 'UNO'))
      sheets = ods.workbook.getSheets ();
      sheetnames = sheets.getElementNames ();    # A Java object, NOT a cell array
      nr_of_sheets = numel (sheetnames);
      sheetnames = char (sheetnames);
      for ii=1:nr_of_sheets
        [ tr, lr, lc, rc ] = getusedrange (ods, ii);
        if (onscreen) 
          printf (sprintf("%s", sheetnames{ii}));  # () as it is a Java object
          if (tr)
            printf (sprintf ("%s (used range = %s:%s)", \
            adj_str (1:(30 - length (sheetnames{ii}))), \
            calccelladdress (tr, lc), calccelladdress (lr, rc)));
          else
            printf ("%s (empty)", adj_str(1:(30 - length (sheetnames{ii}))));
          endif
          printf ("\n");
        endif
        if (tr)
          sheetnames(ii, 2) = sprintf ("%s:%s", calccelladdress (tr, lc), calccelladdress (lr, rc));
        endif

      endfor

    else
#      error (sprintf ("odsfinfo: unknown OpenOffice.org .ods interface - %s.", ods.xtype));

    endif
  endif

  ods = odsclose (ods);
  
endfunction
