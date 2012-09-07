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
## @deftypefn {Function File} [@var{xls}] = xlsclose (@var{xls})
## @deftypefnx {Function File} [@var{xls}] = xlsclose (@var{xls}, @var{filename})
## @deftypefnx {Function File} [@var{xls}] = xlsclose (@var{xls}, "FORCE")
## Close the Excel spreadsheet pointed to in struct @var{xls}, if needed
## write the file to disk. Based on information contained in @var{xls},
## xlsclose will determine if the file should be written to disk.
##
## If no errors occured during writing, the xls file pointer struct will be
## reset and -if COM interface was used- ActiveX/Excel will be closed.
## However if errors occurred, the file pinter will be untouched so you can
## clean up before a next try with xlsclose().
## Be warned that until xlsopen is called again with the same @var{xls} pointer
## struct, hidden Excel or Java applications with associated (possibly large)
## memory chunks are kept in memory, taking up resources.
## If (string) argument "FORCE" is supplied, the file pointer will be reset 
## regardless, whether the possibly modified file has been saved successfully
## or not. Hidden Excel (COM) or OpenOffice.org (UNO) invocations may live on,
## possibly even impeding proper shutdown of Octave.
##
## @var{filename} can be used to write changed spreadsheet files to
## an other file than opened with xlsopen(); unfortunately this doesn't work
## with JXL (JExcelAPI) interface.
##
## You need MS-Excel (95 - 2010), and/or the Java package => 1.2.8 plus Apache
## POI > 3.5 and/or JExcelAPI and/or OpenXLS and/or OpenOffice.org or clones
## installed on your computer + proper javaclasspath set, to make this
## function work at all.
##
## @var{xls} must be a valid pointer struct made by xlsopen() in the same
## octave session.
##
## Examples:
##
## @example
##   xls1 = xlsclose (xls1);
##   (Close spreadsheet file pointed to in pointer struct xls1; xls1 is reset)
## @end example
##
## @seealso {xlsopen, xlsread, xlswrite, xls2oct, oct2xls, xlsfinfo}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-29
## Updates: 
## 2010-01-03 (checked OOXML support)
## 2010-08-25 See also: xlsopen (instead of xlsclose)
## 2010-10-20 Improved tracking of file changes and need to write it to disk
## 2010-10-27 Various changes to catch errors when writing to disk;
##     "      Added input arg "keepxls" for use with xlswrite.m to save the
##     "      untouched file ptr struct in case of errors rather than wipe it
## 2010-11-12 Replaced 'keepxls' by new filename arg; catch write errors and
##            always keep file pointer in case of write errors
## 2011-03-26 Added OpenXLS support
## 2011-05-18 Added experimental UNO support, incl. saving newly created files
## 2011-09-08 Bug fix in check for filename input arg
## 2012-01-26 Fixed "seealso" help string
## 2012-09-03 (in UNO section) replace canonicalize_file_name on non-Windows to
##            make_absolute_filename (see bug #36677)
##     ''     (in UNO section) web adresses need only two consecutive slashes

function [ xls ] = xlsclose (xls, varargs)

  force = 0;

  if (nargin > 1)
    for ii=2:nargin
      if (strcmp (lower (varargin{ii}), "force"))
        # Close .ods anyway even if write errors occur
        force = 1;
      elseif (~isempty (strfind (tolower (varargin{ii}), '.')))
        # Apparently a file name. First some checks....
        if (xls.changed == 0 || xls.changed > 2)
          warning ("File %s wasn't changed, new filename ignored.", xls.filename);
        elseif (strcmp (xls.xtype, 'JXL'))
          error ("JXL doesn't support changing filename, new filename ignored.");
        elseif ~((strcmp (xls.xtype, 'COM') || strcmp (xls.xtype, 'UNO')) && isempty (strfind ( lower (filename), '.xls')))
          # Excel/ActiveX && OOo (UNO bridge) will write any valid filetype; POI/JXL/OXS need .xls[x]
          error ('.xls or .xlsx suffix lacking in filename %s', filename);
        else
          ### For multi-user environments, uncomment below AND relevant stanza in xlsopen
          # In case of COM, be sure to first close the open workbook
          #if (strcmp (xls.xtype, 'COM'))
          #   xls.app.Application.DisplayAlerts = 0;
          #   xls.workbook.close();
          #   xls.app.Application.DisplayAlerts = 0;
          #endif
          # All checks passed
          if (strcmp (xls.xtype, 'UNO'))
            # If needed, turn filename into URL
            if (~isempty (strmatch ("file:///", filename)) || ~isempty (strmatch ("http://", filename))...
              || ~isempty (strmatch ("ftp://", filename)) || ~isempty (strmatch ("www://", filename)))
              # Seems in proper shape for OOo (at first sight)
            else
              # Transform into URL form
              if (ispc)
                fname = canonicalize_file_name (strsplit (filename, filesep){end});
              else
                fname = make_absolute_filename (strsplit (filename, filesep){end});
              endif
               # On Windows, change backslash file separator into forward slash
              if (strcmp (filesep, "\\"))
                tmp = strsplit (fname, filesep);
                flen = numel (tmp);
                tmp(2:2:2*flen) = tmp;
                tmp(1:2:2*flen) = '/';
                filename = [ 'file://' tmp{:} ];
              endif
            endif
          endif
          # Preprocessing / -checking ready. Assign filename arg to file ptr struct
          xls.filename = filename;
        endif
      endif
    endfor
  endif

  if (strcmp (xls.xtype, 'COM'))
    # If file has been changed, write it out to disk.
    #
    # Note: COM / VB supports other Excel file formats as FileFormatNum:
    # 4 = .wks - Lotus 1-2-3 / Microsoft Works
    # 6 = .csv
    # -4158 = .txt 
    # 36 = .prn
    # 50 = .xlsb - xlExcel12 (Excel Binary Workbook in 2007 with or without macro's)
    # 51 = .xlsx - xlOpenXMLWorkbook (without macro's in 2007)
    # 52 = .xlsm - xlOpenXMLWorkbookMacroEnabled (with or without macro's in 2007)
    # 56 = .xls  - xlExcel8 (97-2003 format in Excel 2007)
    # (see Excel Help, VB reference, Enumerations, xlFileType)
    
    # xls.changed = 0: no changes: just close;
    #               1: existing file with changes: save, close.
    #               2: new file with data added: save, close
    #               3: new file, no added added (empty): close & delete on disk

    xls.app.Application.DisplayAlerts = 0;
    try
      if (xls.changed > 0 && xls.changed < 3)
        if (xls.changed == 2)
          # Probably a newly created, or renamed, Excel file
          printf ("Saving file %s ...\n", xls.filename);
          xls.workbook.SaveAs (canonicalize_file_name (xls.filename));
        elseif (xls.changed == 1)
          # Just updated existing Excel file
          xls.workbook.Save ();
        endif
        xls.changed = 0;
        xls.workbook.Close (canonicalize_file_name (xls.filename));
      endif
      xls.app.Quit ();
      delete (xls.workbook);  # This statement actually closes the workbook
      delete (xls.app);     # This statement actually closes down Excel
    catch
      xls.app.Application.DisplayAlerts = 1;
    end_try_catch
    
  elseif (strcmp (xls.xtype, 'POI'))
    if (xls.changed > 0 && xls.changed < 3)
      try
        xlsout = java_new ("java.io.FileOutputStream", xls.filename);
        bufout = java_new ("java.io.BufferedOutputStream", xlsout);
        if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
        xls.workbook.write (bufout);
        bufout.flush ();
        bufout.close ();
        xlsout.close ();
        xls.changed = 0;
      catch
#        xlsout.close ();
      end_try_catch
    endif

  elseif (strcmp (xls.xtype, 'JXL'))
    if (xls.changed > 0 && xls.changed < 3)
      try
        if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
        xls.workbook.write ();
        xls.workbook.close ();
        if (xls.changed == 3)
          # Upon entering write mode, JExcelAPI always makes a disk file
          # Incomplete new files (no data added) had better be deleted.
          xls.workbook.close ();
          delete (xls.filename); 
        endif
        xls.changed = 0;
      catch
      end_try_catch
    endif

  elseif (strcmp (xls.xtype, 'OXS'))
    if (xls.changed > 0 && xls.changed < 3)
      try
        xlsout = java_new ("java.io.FileOutputStream", xls.filename);
        bufout = java_new ("java.io.BufferedOutputStream", xlsout);
        if (xls.changed == 2) printf ("Saving file %s...\n", xls.filename); endif
        xls.workbook.writeBytes (bufout);
        xls.workbook.close ();
        bufout.flush ();
        bufout.close ();
        xlsout.close ();
        xls.changed = 0;
      catch
#        xlsout.close ();
      end_try_catch
    else
      xls.workbook.close ();
    endif

  elseif (strcmp (xls.xtype, 'UNO'))
    # Java & UNO bridge
    try
      if (xls.changed && xls.changed < 3)
        # Workaround:
        unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XModel');
        xModel = xls.workbook.queryInterface (unotmp);
        unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.util.XModifiable');
        xModified = xModel.queryInterface (unotmp);
        if (xModified.isModified ())
          unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XStorable');  # isReadonly() ?    
          xStore = xls.app.xComp.queryInterface (unotmp);
          if (xls.changed == 2)
            # Some trickery as Octave Java cannot create non-numeric arrays
            lProps = javaArray ('com.sun.star.beans.PropertyValue', 1);
            lProp = java_new ('com.sun.star.beans.PropertyValue', "Overwrite", 0, true, []);
            lProps(1) = lProp;
            # OK, store file
            xStore.storeAsURL (xls.filename, lProps);
          else
            xStore.store ();
          endif
        endif
      endif
      xls.changed = -1;    # Needed for check on properly shutting down OOo
      # Workaround:
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XModel');
      xModel = xls.app.xComp.queryInterface (unotmp);
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.util.XCloseable');
      xClosbl = xModel.queryInterface (unotmp);
      xClosbl.close (true);
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XDesktop');
      xDesk = xls.app.aLoader.queryInterface (unotmp);
      xDesk.terminate();
      xls.changed = 0;
    catch
      if (force)
        # Force closing OOo
        unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XDesktop');
        xDesk = xls.app.aLoader.queryInterface (unotmp);
        xDesk.terminate();
      else
        warning ("Error closing xls pointer (UNO)");
      endif
      return
    end_try_catch

#  elseif   <other interfaces here>
    
  endif

  if (xls.changed && xls.changed < 3)
    warning (sprintf ("File %s could not be saved. Read-only or in use elsewhere?\nFile pointer preserved.", xls.filename));
    if (force)
      xls = [];
    endif
  else
    xls = [];
  endif

endfunction
