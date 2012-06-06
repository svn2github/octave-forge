## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} @var{xls} = xlsopen (@var{filename})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite})
## @deftypefnx {Function File} @var{xls} = xlsopen (@var{filename}, @var{readwrite}, @var{reqintf})
## Get a pointer to an Excel spreadsheet in the form of return argument
## (file pointer struct) @var{xls}. After processing the spreadsheet,
## the file pointer must be explicitly closed by calling xlsclose().
##
## Calling xlsopen without specifying a return argument is fairly useless!
##
## To make this function work at all, you need MS-Excel (95 - 2003), and/or
## the Java package >= 1.2.8 plus Apache POI >= 3.5 and/or JExcelAPI and/or
## OpenXLS and/or OpenOffice.org (or clones) installed on your computer +
## proper javaclasspath set. These interfaces are referred to as COM, POI,
## JXL, OXS, and UNO, resp., and are preferred in that order by default
## (depending on their presence).
## For OOXML support, in addition to Apache POI support you also need the
## following jars in your javaclasspath: poi-ooxml-schemas-3.5.jar,
## xbean.jar and dom4j-1.6.1.jar (or later versions). Later OpenOffice.org
## versions (UNO) have support for OOXML as well.
## Excel'95 spreadsheets can only be read by JExcelAPI and OpenOffice.org.
##
## @var{filename} should be a valid .xls or xlsx Excel file name (including
## extension). But if you use the COM interface you can specify any extension
## that your installed Excel version can read AND write; the same goes for UNO
## (OpenOffice.org). Using the other Java interfaces, only .xls or .xlsx are
## allowed. If @var{filename} does not contain any directory path, the file
## is saved in the current directory.
##
## If @var{readwrite} is set to 0 (default value) or omitted, the Excel file
## is opened for reading. If @var{readwrite} is set to True or 1, an Excel
## file is opened (or created) for reading & writing.
##
## Optional input argument @var{reqintf} can be used to override the Excel
## interface that otherwise is automatically selected by xlsopen. Currently
## implemented interfaces (in order of preference) are 'COM' (Excel/COM),
## 'POI' (Java/Apache POI), 'JXL' (Java/JExcelAPI), 'OXS' (Java/OpenXLS), or
## 'UNO' (Java/OpenOffice.org - EXPERIMENTAL!).
## In most situations this parameter is unneeded as xlsopen automatically
## selects the most useful interface present.
##
## Beware: Excel invocations may be left running invisibly in case of COM
## errors or forgetting to close the file pointer. Similarly for OpenOffice.org
## which may even prevent Octave from being closed.
##
## Examples:
##
## @example
##   xls = xlsopen ('test1.xls');
##   (get a pointer for reading from spreadsheet test1.xls)
##
##   xls = xlsopen ('test2.xls', 1, 'POI');
##   (as above, indicate test2.xls will be written to; in this case using Java
##    and the Apache POI interface are requested)
## @end example
##
## @seealso {xlsclose, xlsread, xlswrite, xls2oct, oct2xls, xlsfinfo}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-29
## Updates:
## 2010-01-03 Added OOXML support
## 2010-01-10 Changed (java) interface preference order to COM->POI->JXL
## 2010-01-16 Removed echoeing debug info in POI stanza
## 2010-03-01 Removed javaclasspath check for rt.jar
## 2010-03-14 Fixed check on xwrite flag lines 204+, if xlsopen fails xls ptr
##            should be []
## 2010-08-25 Improved help text
## 2010-09-27 Improved POI help message for unrecognized .xls format to hint for BIFF5/JXL
## 2010-10-20 Improved code for tracking changes to new/existing files
##     ''     Lots of code cleanup, improved error checking and catching
##     ''     Implemented fallback to JXL if POI can't read a file.
## 2010-10-30 More fine-grained file existence/writable checks
## 2010-11-01 Added <COM>.Application.DisplayAlerts=0 in COM section to avoid Excel pop-ups
## 2010-11-05 Option for multiple requested interface types (cell array)
##     ''     Bug fix: JXL fallback from POI for BIFF5 is only useful for reading
## 2010-11-05 Slight change to reporting to screen
## 2010-11-08 Tested with POI 3.7 (OK)
## 2010-11-10 Texinfo header updated
## 2010-12-01 Small bugfix - reset xlssupport in l. 102
## 2010-12-06 Textual changes to info header 
## 2011-03-26 OpenXLS support added
## 2011-05-18 Experimental UNO support added, incl. creating new spreadsheets
## 2011-05-22 Textual changes in header
## 2011-05-29 Cleanup of comments & messages
## 2011-09-03 Reset chkintf to [] if no xls support was discovered (to allow
##            rediscovery of interfaces between xlsopen calls, e.g. javaclasspath changes)
## 2011-09-08 Minor code cleanup
## 2012-01-26 Fixed "seealso" help string
## 2012-06-06 Improved interface detection logic. No more messages if same interface is
##            requested & used consecutively
##
## Latest subfunction update: 2012-06-06

function [ xls ] = xlsopen (filename, xwrite=0, reqinterface=[])

  persistent xlsinterfaces; persistent chkintf; persistent lastintf;
  # xlsinterfaces.<intf> = [] (not yet checked), 0 (found to be unsupported) or 1 (OK)
  if (isempty (chkintf));
      chkintf = 1;
      xlsinterfaces = struct ('COM', [], 'POI', [], 'JXL', [], 'OXS', [], 'UNO', []);
  endif
  if (isempty (lastintf))
    lastintf = "---";
  endif

  xlssupport = 0;

  if (nargout < 1)
      usage ("XLS = xlsopen (Xlfile [, Rw] [, reqintf]). But no return argument specified!"); 
  endif

  if (~(islogical (xwrite) || isnumeric (xwrite)))
      usage ("Numerical or logical value expected for arg # 2")
  endif

  if (~isempty (reqinterface))
    if ~(ischar (reqinterface) || iscell (reqinterface)), usage ("Arg # 3 not recognized"); endif
    # Turn arg3 into cell array if needed
    if (~iscell (reqinterface)), reqinterface = {reqinterface}; endif
    ## Check if previously used interface matches a requested interface
    if (isempty (regexpi (reqinterface, lastintf, 'once'){1}))
      ## New interface requested
      xlsinterfaces.COM = 0; xlsinterfaces.POI = 0; xlsinterfaces.JXL = 0;
      xlsinterfaces.OXS = 0; xlsinterfaces.UNO = 0;
      for ii=1:numel (reqinterface)
        reqintf = toupper (reqinterface {ii});
        # Try to invoke requested interface(s) for this call. Check if it
        # is supported anyway by emptying the corresponding var.
        if     (strcmpi (reqintf, 'COM'))
          xlsinterfaces.COM = [];
        elseif (strcmpi (reqintf, 'POI'))
          xlsinterfaces.POI = [];
        elseif (strcmpi (reqintf, 'JXL'))
          xlsinterfaces.JXL = [];
        elseif (strcmpi (reqintf, 'OXS'))
          xlsinterfaces.OXS = [];
        elseif (strcmpi (reqintf, 'UNO'))
          xlsinterfaces.UNO = [];
        else 
          usage (sprintf ("Unknown .xls interface \"%s\" requested. Only COM, POI, JXL, OXS or UNO supported\n", reqinterface{}));
        endif
      endfor
      printf ("Checking requested interface(s):\n");
      xlsinterfaces = getxlsinterfaces (xlsinterfaces);
      # Well, is/are the requested interface(s) supported on the system?
      # FIXME check for multiple interfaces
      xlsintf_cnt = 0;
      for ii=1:numel (reqinterface)
        if (~xlsinterfaces.(toupper (reqinterface{ii})))
          # No it aint
          printf ("%s is not supported.\n", upper (reqinterface{ii}));
        else
          ++xlsintf_cnt;
        endif
      endfor
      # Reset interface check indicator if no requested support found
      if (~xlsintf_cnt)
        chkintf = [];
        xls = [];
        return
      endif
    endif
  endif

  # Var xwrite is really used to avoid creating files when wanting to read, or
  # not finding not-yet-existing files when wanting to write.

  # Check if Excel file exists. Adapt file open mode for readwrite argument
  if (xwrite), fmode = 'r+b'; else fmode = 'rb'; endif
  fid = fopen (filename, fmode);
  if (fid < 0)            # File doesn't exist...
    if (~xwrite)        # ...which obviously is fatal for reading...
      error ( sprintf ("File %s not found\n", filename));
    else              # ...but for writing, we need more info:
      fid = fopen (filename, 'rb');  # Check if it exists at all...
      if (fid < 0)      # File didn't exist yet. Simply create it
        printf ("Creating file %s\n", filename);
        xwrite = 3;
      else            # File exists, but is not writable => Error
        fclose (fid);  # Do not forget to close the handle neatly
        error (sprintf ("Write mode requested but file %s is not writable\n", filename))
      endif
    endif
  else
    # Close file anyway to avoid COM or Java errors
    fclose (fid);
  endif
  
  # Check for the various Excel interfaces. No problem if they've already
  # been checked, getxlsinterfaces (far below) just returns immediately then.
  xlsinterfaces = getxlsinterfaces (xlsinterfaces);

  # Supported interfaces determined; Excel file type check moved to seperate interfaces.
  chk1 = strcmpi (filename(end-3:end), '.xls');      # Regular (binary) BIFF 
  chk2 = strcmpi (filename(end-4:end-1), '.xls');    # Zipped XML / OOXML
  
  # Initialize file ptr struct
  xls = struct ("xtype", 'NONE', "app", [], "filename", [], "workbook", [], "changed", 0, "limits", []); 

  # Keep track of which interface is selected
  xlssupport = 0;

  # Interface preference order is defined below: currently COM -> POI -> JXL -> OXS -> UNO
  if (xlsinterfaces.COM && ~xlssupport)
    # Excel functioning has been tested above & file exists, so we just invoke it
    app = actxserver ("Excel.Application");
    try      # Because Excel itself can still crash on file formats etc.
      app.Application.DisplayAlerts = 0;
      if (xwrite < 2)
        # Open workbook
        wb = app.Workbooks.Open (canonicalize_file_name (filename));
      elseif (xwrite > 2)
        # Create a new workbook
        wb = app.Workbooks.Add ();
        ### Uncommenting the below statement can be useful in multi-user environments.
        ### Be sure to uncomment correspondig stanza in xlsclose to avoid zombie Excels
        # wb.SaveAs (canonicalize_file_name (filename))
      endif
      xls.app = app;
      xls.xtype = 'COM';
      xls.workbook = wb;
      xls.filename = filename;
      xlssupport += 1;
      lastintf = 'COM';
    catch
      warning ( sprintf ("ActiveX error trying to open or create file %s\n", filename));
      app.Application.DisplayAlerts = 1;
      app.Quit ();
      delete (app);
    end_try_catch
  endif
  
  if (xlsinterfaces.POI && ~xlssupport)
    if ~(chk1 || chk2)
      error ("Unsupported file format for Apache POI.")
    endif
    # Get handle to workbook
    try
      if (xwrite > 2)
        if (chk1)
          wb = java_new ('org.apache.poi.hssf.usermodel.HSSFWorkbook');
        elseif (chk2)
          wb = java_new ('org.apache.poi.xssf.usermodel.XSSFWorkbook');
        endif
          xls.app = 'new_POI';
      else
        xlsin = java_new ('java.io.FileInputStream', filename);
        wb = java_invoke ('org.apache.poi.ss.usermodel.WorkbookFactory', 'create', xlsin);
        xls.app = xlsin;
      endif
      xls.xtype = 'POI';
      xls.workbook = wb;
      xls.filename = filename;
      xlssupport += 2;
      lastintf = 'JXL';
    catch
      clear xlsin;
      if (xlsinterfaces.JXL)
        printf ('Couldn''t open file %s using POI; trying Excel''95 format with JXL...\n', filename);
      endif
    end_try_catch
  endif
      
  if (xlsinterfaces.JXL && ~xlssupport)
    if (~chk1)
      error ("JXL can only read reliably from .xls files")
    endif
    try
      xlsin = java_new ('java.io.File', filename);
      if (xwrite > 2)
        # Get handle to new xls-file
        wb = java_invoke ('jxl.Workbook', 'createWorkbook', xlsin);
      else
        # Open existing file
        wb = java_invoke ('jxl.Workbook', 'getWorkbook', xlsin);
      endif
      xls.xtype = 'JXL';
      xls.app = xlsin;
      xls.workbook = wb;
      xls.filename = filename;
      xlssupport += 4;
      lastintf = 'POI';
    catch
      clear xlsin;
      if (xlsinterfaces.POI)
        printf ('... No luck with JXL either, unsupported file format.\n', filename);
      endif
    end_try_catch
  endif

  if (xlsinterfaces.OXS && ~xlssupport)
    if (~chk1)
      error ("OXS can only read from .xls files")
    endif
    try
      wb = javaObject ('com.extentech.ExtenXLS.WorkBookHandle', filename);
      xls.xtype = 'OXS';
      xls.app = 'void - OpenXLS';
      xls.workbook = wb;
      xls.filename = filename;
      xlssupport += 8;
      lastintf = 'OXS';
    catch
      printf ('Unsupported file format for OpenXLS - %s\n');
    end_try_catch
  endif

  if (xlsinterfaces.UNO && ~xlssupport)
    # First, the file name must be transformed into a URL
    if (~isempty (strmatch ("file:///", filename)) || ~isempty (strmatch ("http:///", filename))...
      || ~isempty (strmatch ("ftp:///", filename)) || ~isempty (strmatch ("www:///", filename)))
      # Seems in proper shape for OOo (at first sight)
    else
      # Transform into URL form
      fname = canonicalize_file_name (strsplit (filename, filesep){end});
      # On Windows, change backslash file separator into forward slash
      if (strcmp (filesep, "\\"))
        tmp = strsplit (fname, filesep);
        flen = numel (tmp);
        tmp(2:2:2*flen) = tmp;
        tmp(1:2:2*flen) = '/';
        fname = [ tmp{:} ];
      endif
      filename = [ 'file://' fname ];
    endif
    try
      xContext = java_invoke ("com.sun.star.comp.helper.Bootstrap", "bootstrap");
      xMCF = xContext.getServiceManager ();
      oDesktop = xMCF.createInstanceWithContext ("com.sun.star.frame.Desktop", xContext);
      # Workaround for <UNOruntime>.queryInterface():
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XComponentLoader');
      aLoader = oDesktop.queryInterface (unotmp);
      # Some trickery as Octave Java cannot create initialized arrays
      lProps = javaArray ('com.sun.star.beans.PropertyValue', 1);
      lProp = java_new ('com.sun.star.beans.PropertyValue', "Hidden", 0, true, []);
      lProps(1) = lProp;
      if (xwrite > 2)
        xComp = aLoader.loadComponentFromURL ("private:factory/scalc", "_blank", 0, lProps);
      else
        xComp = aLoader.loadComponentFromURL (filename, "_blank", 0, lProps);
      endif
      # Workaround for <UNOruntime>.queryInterface():
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheetDocument');
      xSpdoc = xComp.queryInterface (unotmp);
      # save in ods struct:
      xls.xtype = 'UNO';
      xls.workbook = xSpdoc;        # Needed to be able to close soffice in odsclose()
      xls.filename = filename;
      xls.app.xComp = xComp;        # Needed to be able to close soffice in odsclose()
      xls.app.aLoader = aLoader;      # Needed to be able to close soffice in odsclose()
      xls.odfvsn = 'UNO';
      xlssupport += 16;
      lastintf = 'UNO';
    catch
      error ('Couldn''t open file %s using UNO', filename);
    end_try_catch
  endif

  # if 
  #  ---- other interfaces
  # endif

  # Rounding up. If none of the xlsinterfaces is supported we're out of luck.
  if (~xlssupport)
    if (isempty (reqinterface))
      printf ("None.\n");
      warning ("No support for Excel .xls I/O"); 
    else
      warning ("File type not supported by %s %s %s %s %s", reqinterface{:});
    endif
    xls = [];
    # Reset found interfaces for re-testing in the next call. Add interfaces if needed.
    chkintf = [];
  else
    # From here on xwrite is tracked via xls.changed in the various lower
    # level r/w routines and it is only used to determine if an informative
    # message is to be given when saving a newly created xls file.
    xls.changed = xwrite;

    # Until something was written to existing files we keep status "unchanged".
    # xls.changed = 0 (existing/only read from), 1 (existing/data added), 2 (new,
    # data added) or 3 (pristine, no data added).
    if (xls.changed == 1), xls.changed = 0; endif
  endif
  
endfunction


## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} @var{xlsinterfaces} = getxlsinterfaces (@var{xlsinterfaces})
## Get supported Excel .xls file read/write interfaces from the system.
## Each interface for which the corresponding field is set to empty
## will be checked. So by manipulating the fields of input argument
## @var{xlsinterfaces} it is possible to specify which
## interface(s) should be checked.
##
## Currently implemented interfaces comprise:
## - ActiveX / COM (native Excel in the background)
## - Java & Apache POI
## - Java & JExcelAPI
## - Java & OpenXLS (only JRE >= 1.4 needed)
## - Java & UNO bridge (native OpenOffice.org in background) - EXPERIMENTAL!!
##
## Examples:
##
## @example
##   xlsinterfaces = getxlsinterfaces (xlsinterfaces);
## @end example

## Author: Philip Nienhuis
## Created: 2009-11-29
## Last updates: 
## 2009-12-27 Make sure proper dimensions are checked in parsed javaclasspath
## 2010-09-11 Rearranged code and clarified messages about missing classes
## 2010-09-27 More code cleanup
## 2010-10-20 Added check for minimum Java version (should be >= 6 / 1.6)
## 2010-11-05 Slight change to reporting to screen
## 2011-02-15 Adapted to javaclasspath calling style of java-1.2.8 pkg
## 2011-03-26 OpenXLS support added
##      ''    Bug fix: javaclasspath change wasn't picked up between calls with req.intf
## 2011-05-18 Experimental UNO support added
## 2011-05-29 Reduced verbosity
## 2011-06-06 Fix for javaclasspath format in *nix w java-1.2.8 pkg
## 2011-06-13 Fixed potentially faulty tests for java classlib presence
## 2011-09-03 Fixed order of xlsinterfaces.<member> statements in Java detection try-catch
##      ''    Reset tmp1 (always allow interface rediscovery) for empty xlsinterfaces arg
## 2011-09-08 Minor code cleanup
## 2011-09-18 Added temporary warning about UNO interface
## 2012-03-01 Changed UNO warning so that it is suppressed when UNO is not yet chosen
## 2012-03-07 Only check for COM if run on Windows
## 2012-03-21 Print newline if COM found but no Java support
##     ''     Improved logic for finding out what interfaces to check
##     ''     Fixed bugs with Java interface checking (tmp1 initialization)
## 2012-06-06 Improved & simplified Java check code

function [xlsinterfaces] = getxlsinterfaces (xlsinterfaces)

  # tmp1 = [] (not initialized), 0 (No Java detected), or 1 (Working Java found)
  persistent tmp1 = []; persistent jcp;  # Java class path
  persistent uno_1st_time = 0;

  if (isempty (xlsinterfaces.COM) && isempty (xlsinterfaces.POI) && isempty (xlsinterfaces.JXL)
   && isempty (xlsinterfaces.OXS) && isempty (xlsinterfaces.UNO))
    # Looks like first call to xlsopen. Check Java support
    printf ("Detected XLS interfaces: ");
    tmp1 = [];
  elseif (isempty (xlsinterfaces.POI) || isempty (xlsinterfaces.JXL)
       || isempty (xlsinterfaces.OXS) || isempty (xlsinterfaces.UNO))
    # Can't be first call. Here one of the Java interfaces is requested
    if (~tmp1)
      # Check Java support again
      tmp1 = [];
    endif
  endif
  deflt = 0;

  # Check if MS-Excel COM ActiveX server runs (only on Windows!)
  if (isempty (xlsinterfaces.COM))
    xlsinterfaces.COM = 0;
    if (ispc)
      try
        app = actxserver ("Excel.application");
        # If we get here, the call succeeded & COM works.
        xlsinterfaces.COM = 1;
        # Close Excel. Yep this is inefficient when we need only one r/w action,
        # but it quickly pays off when we need to do more with the same file
        # (+, MS-Excel code is in OS cache anyway after this call so no big deal)
        app.Quit();
        delete(app);
        printf ("COM");
        if (deflt), printf ("; "); else, printf ("*; "); deflt = 1; endif
      catch
        # COM non-existent. Only print message if COM is explicitly requested (tmp1==[])
        if (~isempty (tmp1))
          printf ("ActiveX not working; no Excel installed?\n"); 
        endif
      end_try_catch
    endif
  endif

  if (isempty (tmp1))
    # Check Java support. First try javaclasspath
    try
      jcp = javaclasspath ('-all');              # For java pkg > 1.2.7
      if (isempty (jcp)), jcp = javaclasspath; endif  # For java pkg < 1.2.8
      # If we get here, at least Java works. Now check for proper version (>= 1.6)
      jver = char (java_invoke ('java.lang.System', 'getProperty', 'java.version'));
      cjver = strsplit (jver, '.');
      if (sscanf (cjver{2}, '%d') < 6)
        warning ("\nJava version might be too old - you need at least Java 6 (v. 1.6.x.x)\n");
        return
      endif
      # Now check for proper entries in class path. Under *nix the classpath
      # must first be split up. In java 1.2.8+ javaclasspath is already a cell array
      if (isunix && ~iscell (jcp)); jcp = strsplit (char (jcp), ":"); endif
      tmp1 = 1;
    catch
      # No Java support found
      tmp1 = 0;
      if (isempty (xlsinterfaces.POI) || isempty (xlsinterfaces.JXL)...
        || isempty (xlsinterfaces.OXS) || isempty (xlsinterfaces.UNO))
        # Some or all Java-based interface(s) explicitly requested but no Java support
        warning (' No Java support found (no Java JRE? no Java pkg installed AND loaded?');
      endif
      # Set Java interfaces to 0 anyway as there's no Java support
      xlsinterfaces.POI = 0;
      xlsinterfaces.JXL = 0;
      xlsinterfaces.OXS = 0;
      xlsinterfaces.UNO = 0;
      printf ("\n");
      # No more need to try any Java interface
      return
    end_try_catch
  endif

  # Try Java & Apache POI
  if (isempty (xlsinterfaces.POI))
    xlsinterfaces.POI = 0;
    # Check basic .xls (BIFF8) support
    jpchk1 = 0; entries1 = {"poi-3", "poi-ooxml-3"};
    # Only under *nix we might use brute force: e.g., strfind (classname, classpath);
    # under Windows we need the following more subtle, platform-independent approach:
    for ii=1:length (jcp)
      for jj=1:length (entries1)
        if (isempty (strfind (tolower (jcp{ii}), entries1{jj}))), ++jpchk1; endif
      endfor
    endfor
    if (jpchk1 > 1)
      xlsinterfaces.POI = 1;
      printf ("POI");
    endif
    # Check OOXML support
    jpchk2 = 0; entries2 = {"xbean", "poi-ooxml-schemas", "dom4j"};
    for ii=1:length (jcp)
      for jj=1:length (entries2)
        if (isempty (strfind (lower (jcp{ii}), entries2{jj}))), ++jpchk2; endif
      endfor
    endfor
    if (jpchk2 > 2), printf (" (& OOXML)"); endif
    if (xlsinterfaces.POI)
      if (deflt), printf ("; "); else, printf ("*; "); deflt = 1; endif
    endif
  endif

  # Try Java & JExcelAPI
  if (isempty (xlsinterfaces.JXL))
    xlsinterfaces.JXL = 0;
    jpchk = 0; entries = {"jxl"};
    for ii=1:length (jcp)
      for jj=1:length (entries)
        if (isempty (strfind (lower (jcp{ii}), entries{jj}))), ++jpchk; endif
      endfor
    endfor
    if (jpchk > 0)
      xlsinterfaces.JXL = 1;
      printf ("JXL");
      if (deflt), printf ("; "); else, printf ("*; "); deflt = 1; endif
    endif
  endif

  # Try Java & OpenXLS
  if (isempty (xlsinterfaces.OXS))
    xlsinterfaces.OXS = 0;
    jpchk = 0; entries = {"openxls"};
    for ii=1:length (jcp)
      for jj=1:length (entries)
        if (isempty (strfind (lower (jcp{ii}), entries{jj}))), ++jpchk; endif
      endfor
    endfor
    if (jpchk > 0)
      xlsinterfaces.OXS = 1;
      printf ("OXS");
      if (deflt), printf ("; "); else, printf ("*; "); deflt = 1; endif
    endif
  endif

  # Try Java & UNO
  if (isempty (xlsinterfaces.UNO))
    xlsinterfaces.UNO = 0;
    # entries0(1) = not a jar but a directory (<00o_install_dir/program/>)
    jpchk = 0; entries = {'program', 'unoil', 'jurt', 'juh', 'unoloader', 'ridl'};
    for jj=1:numel (entries)
      for ii=1:numel (jcp)
        jcplst = strsplit (jcp{ii}, filesep);
        jcpentry = jcplst {end};
        if (~isempty (strfind (lower (jcpentry), lower (entries{jj})))); ++jpchk; endif
      endfor
    endfor
    if (jpchk >= numel (entries))
      xlsinterfaces.UNO = 1;
      printf ('UNO');
      if (deflt), printf ("; "); else, printf ("*; "); deflt = 1; uno_1st_time = min (++uno_1st_time, 2); endif
    endif
  endif

  # ---- Other interfaces here, similar to the ones above

  if (deflt), printf ("(* = active interface)\n"); endif

  ## FIXME the below stanza should be dropped once UNO is stable.
  # Echo a suitable warning about experimental status:
  if (uno_1st_time == 1)
    ++uno_1st_time;
    printf ("\nPLEASE NOTE: UNO (=OpenOffice.org-behind-the-scenes) is EXPERIMENTAL\n");
    printf ("After you've opened a spreadsheet file using the UNO interface,\n");
    printf ("xlsclose on that file will kill ALL OpenOffice.org invocations,\n");
    printf ("also those that were started outside and/or before Octave!\n");
    printf ("Trying to quit Octave w/o invoking xlsclose will only hang Octave.\n\n");
  endif

endfunction