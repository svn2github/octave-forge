## Copyright (C) 2009,2010,2011 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} @var{ods} = odsopen (@var{filename})
## @deftypefnx {Function File} @var{ods} = odsopen (@var{filename}, @var{readwrite})
## @deftypefnx {Function File} @var{ods} = odsopen (@var{filename}, @var{readwrite}, @var{reqintf})
## Get a pointer to an OpenOffice_org spreadsheet in the form of return
## argument @var{ods}.
##
## Calling odsopen without specifying a return argument is fairly useless!
##
## To make this function work at all, you need the Java package > 1.2.5 plus
## ODFtoolkit (version 0.7.5 or 0.8.6) & xercesImpl, and/or jOpenDocument
## installed on your computer + proper javaclasspath set. These interfaces are
## referred to as OTK and JOD, resp., and are preferred in that order by default
## (depending on their presence).
## For (currently experimental) UNO support, Octave-Java package 1.2.8 + latest
## fixes is imperative; furthermore the relevant classes had best be added to
## the javaclasspath by utility function chk_spreadsheet_support().
##
## @var{filename} must be a valid .ods OpenOffice.org file name including
## .ods suffix. If @var{filename} does not contain any directory path,
## the file is saved in the current directory.
##
## @var{readwrite} must be set to true ornumerical 1 if writing to spreadsheet
## is desired immediately after calling odsopen(). It merely serves proper
## handling of file errors (e.g., "file not found" or "new file created").
##
## Optional input argument @var{reqintf} can be used to override the ODS
## interface automatically selected by odsopen. Currently implemented interfaces
## are 'OTK' (Java / ODFtoolkit) or 'JOD' (Java / jOpenDocument).
##
## Examples:
##
## @example
##   ods = odsopen ('test1.ods');
##   (get a pointer for reading from spreadsheet test1.ods)
##
##   ods = odsopen ('test2.ods', [], 'JOD');
##   (as above, indicate test2.ods will be read from; in this case using
##    the jOpenDocument interface is requested)
## @end example
##
## @seealso odsclose, odsread, ods2oct, odsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Updates: 
## 2009-12-30 ....<forgot what is was >
## 2010-01-17 Make sure proper dimensions are checked in parsed javaclasspath
## 2010-01-24 Added warning when trying to create a new spreadsheet using jOpenDocument
## 2010-03-01 Removed check for rt.jar in javaclasspath
## 2010-03-04 Slight texinfo adaptation (reqd. odfdom version = 0.7.5)
## 2010-03-14 Updated help text (section on readwrite)
## 2010-06-01 Added check for jOpenDocument version + suitable warning
## 2010-06-02 Added ";" to supress debug stuff around lines 115
##      "     Moved JOD version check to subfunc getodsinterfaces
##      "     Fiddled ods.changed flag when creating a spreadsheet to avoid unnamed 1st sheets
## 2010-08-23 Added version field "odfvsn" to ods file ptr, set in getodsinterfaces() (odfdom)
##      "     Moved JOD version check to this func from subfunc getodsinterfaces()
##      "     Full support for odfdom 0.8.6 (in subfunc)
## 2010-08-27 Improved help text
## 2010-10-27 Improved tracking of file changes tru ods.changed
## 2010-11-12 Small changes to help text
##     "      Added try-catch to file open sections to create fallback to other intf
## 2011-05-06 Experimental UNO support
##
## Latest change on subfunction below: 2011-05-06

function [ ods ] = odsopen (filename, rw=0, reqinterface=[])

	persistent odsinterfaces; persistent chkintf;
	if (isempty (chkintf))
		odsinterfaces = struct ( "OTK", [], "JOD", [], "UNO", [] );
		chkintf = 1;
	endif
	
	if (nargout < 1) usage ("ODS = odsopen (ODSfile, [Rw]). But no return argument specified!"); endif

	## FIXME: if ever another interface is implemented the below stanzas
	## should be remodeled after xlsopen() to allow for multiple
	## user-desired interface requests (for just 2 interfaces there's
	## no need yet)
	if (~isempty (reqinterface))
		# Try to invoke requested interface for this call. Check if it
		# is supported anyway by emptying the corresponding var.
		if (strcmp (tolower (reqinterface), tolower ('OTK')))
			printf ("Java/ODFtoolkit interface requested... ");
			odsinterfaces.OTK = []; odsinterfaces.JOD = 0; odsinterfaces.UNO = 0;
		elseif (strcmp (tolower (reqinterface), tolower ('JOD')))
			printf ("Java/jOpenDocument interface requested... "); 
			odsinterfaces.OTK = 0; odsinterfaces.JOD = []; odsinterfaces.UNO = 0;
		elseif (strcmp (tolower (reqinterface), tolower ('UNO')))
			printf ("Java/UNO bridge interface requested... "); 
			odsinterfaces.OTK = 0; odsinterfaces.JOD = 0; odsinterfaces.UNO = [];
		else
			usage (sprintf ("Unknown .ods interface \"%s\" requested. Only OTK or JOD supported", reqinterface));
		endif
		[odsinterfaces] = getodsinterfaces (odsinterfaces);

		# Well, is the requested interface supported on the system?
		if (~odsinterfaces.(toupper (reqinterface)))
			# No it aint
			error (" ...but %s is not supported.", toupper (reqinterface));
		endif
	endif
	
	# Var rw is really used to avoid creating files when wanting to read, or
	# not finding not-yet-existing files when wanting to write.

	if (rw) rw = 1; endif		# Be sure it's either 0 or 1 initially

	# Check if ODS file exists. Set open mode based on rw argument
	if (rw), fmode = 'r+b'; else fmode = 'rb'; endif
	fid = fopen (filename, fmode);
	if (fid < 0)
		if (~rw)			# Read mode requested but file doesn't exist
			err_str = sprintf ("File %s not found\n", filename);
			error (err_str)
		else				# For writing we need more info:
			fid = fopen (filename, 'rb');  # Check if it can be opened for reading
			if (fid < 0)	# Not found => create it
				printf ("Creating file %s\n", filename);
				rw = 3;
			else			# Found but not writable = error
				fclose (fid);	# Do not forget to close the handle neatly
				error (sprintf ("Write mode requested but file %s is not writable\n", filename))
			endif
		endif
	else
		# close file anyway to avoid Java errors
		fclose (fid);
	endif

# Check for the various ODS interfaces. No problem if they've already
# been checked, getodsinterfaces (far below) just returns immediately then.

	[odsinterfaces] = getodsinterfaces (odsinterfaces);

# Supported interfaces determined; now check ODS file type.

	chk1 = strcmp (tolower (filename(end-3:end)), '.ods');
	# Only jOpenDocument (JOD) can read from .sxc files, but only if odfvsn = 2
	chk2 = strcmp (tolower (filename(end-3:end)), '.sxc');
#	if (~chk1)
#		error ("Currently ods2oct can only read reliably from .ods files")
#	endif

	ods = struct ("xtype", [], "app", [], "filename", [], "workbook", [], "changed", 0, "limits", [], "odfvsn", []);

	# Preferred interface = OTK (ODS toolkit & xerces), so it comes first. 
	# Keep track of which interface is selected. Can be used for fallback to other intf
	odssupport = 0;

	if (odsinterfaces.OTK && ~odssupport)
		# Parts after user gfterry in
		# http://www.oooforum.org/forum/viewtopic.phtml?t=69060
		odftk = 'org.odftoolkit.odfdom.doc';
		try
			if (rw > 2)
				# New spreadsheet
				wb = java_invoke ([odftk '.OdfSpreadsheetDocument'], 'newSpreadsheetDocument');
			else
				# Existing spreadsheet
				wb = java_invoke ([odftk '.OdfDocument'], 'loadDocument', filename);
			endif
			ods.workbook = wb.getContentDom ();		# Reads the entire spreadsheet
			ods.xtype = 'OTK';
			ods.app = wb;
			ods.filename = filename;
			ods.odfvsn = odsinterfaces.odfvsn;
			odssupport += 1;
		catch
			if (xlsinterfaces.JOD && ~rw && chk2)
				printf ('Couldn''t open file %s using OTK; trying .sxc format with JOD...\n', filename);
			else
				error ('Couldn''t open file %s using OTK', filename);
			endif
		end_try_catch
	endif

	if (odsinterfaces.JOD && ~odssupport)
		file = java_new ('java.io.File', filename);
		jopendoc = 'org.jopendocument.dom.spreadsheet.SpreadSheet';
		try
			if (rw > 2)
				# Create an empty 2 x 2 default TableModel template
				tmodel= java_new ('javax.swing.table.DefaultTableModel', 2, 2);
				wb = java_invoke (jopendoc, 'createEmpty', tmodel);
			else
				wb = java_invoke (jopendoc, 'createFromFile', file);
			endif
			ods.workbook = wb;
			ods.filename = filename;
			ods.xtype = 'JOD';
			ods.app = 'file';
			# Check jOpenDocument version. This can only work here when a
			# workbook has been opened
			sh = ods.workbook.getSheet (0);
			cl = sh.getCellAt (0, 0);
			try
				# 1.2b3 has public getValueType ()
				cl.getValueType ();
				ods.odfvsn = 3;
			catch
				# 1.2b2 has not
				ods.odfvsn = 2;
				printf ("NOTE: jOpenDocument v. 1.2b2 has limited functionality. Try upgrading to 1.2b3+\n");
			end_try_catch
			odssupport += 2;
		catch
			error ('Couldn''t open file %s using JOD', filename);
		end_try_catch
	endif

	if (odsinterfaces.UNO && ~odssupport)
		# First the file name must be transformed into a URL
		filename = 'file:///c:/Home/philip/MyDocs/octave/spreadsheet-tst/foo3_.ods';
		try
			xContext = java_invoke ("com.sun.star.comp.helper.Bootstrap", "bootstrap")
			xMCF = xContext.getServiceManager ()
			oDesktop = xMCF.createInstanceWithContext ("com.sun.star.frame.Desktop", xContext);
			# Workaround:
			unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.frame.XComponentLoader');
			aLoader = oDesktop.queryInterface (unotmp);
			# Some trickery as Octave Java cannot create non-numeric arrays
			lProps = javaArray ('com.sun.star.beans.PropertyValue', 1);
			lProp = java_new ('com.sun.star.beans.PropertyValue', "Hidden", 0, true, []);
			lProps(1) = lProp;
				# save in ods struct: 
			xComp = aLoader.loadComponentFromURL (filename, "_blank", 0, lProps);
			# Workaround:
			unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheetDocument');
				# save in ods struct:
			xSpdoc = xComp.queryInterface (unotmp);
			ods.workbook = xSpdoc;			# Needed to be able to close soffice in odsclose()
			ods.filename = filename;
			ods.xtype = 'UNO';
			ods.app.xComp = xComp;			# Needed to be able to close soffice in odsclose()
			ods.app.aLoader = aLoader;		# Needed to be able to close soffice in odsclose()
			ods.odfvsn = 'UNO';
			odssupport += 4;
		catch
			error ('Couldn''t open file %s using UNO', filename);
		end_try_catch
	endif

#	if 
#		<other interfaces here>

	if (~odssupport)
		warning ("No support for OpenOffice.org .ods I/O"); 
		ods = [];
	else
		# From here on rw is tracked via ods.changed in the various lower
		# level r/w routines and it is only used to determine if an informative
		# message is to be given when saving a newly created ods file.
		ods.changed = rw;

		# Until something was written to existing files we keep status "unchanged".
		# ods.changed = 0 (existing/only read from), 1 (existing/data added), 2 (new,
		# data added) or 3 (pristine, no data added).
		if (ods.changed == 1) ods.changed = 0; endif
	endif

	if (~isempty (reqinterface))
		# Reset all found interfaces for re-testing in the next call. Add interfaces if needed.
		chkintf = [];
	endif

endfunction


## Copyright (C) 2009,2010,2011 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} @var{odsinterfaces} = getodsinterfaces (@var{odsinterfaces})
## Get supported OpenOffice.org .ods file read/write interfaces from
## the system.
## Each interface for which the corresponding field is set to empty
## will be checked. So by manipulating the fields of input argument
## @var{odsinterfaces} it is possible to specify which
## interface(s) should be checked.
##
## Currently implemented interfaces comprise:
## - Java & ODFtoolkit (www.apache.org)
## - Java & jOpenDocument (www.jopendocument.org)
## - Java & UNO bridge (OpenOffice.org)
##
## Examples:
##
## @example
##   odsinterfaces = getodsinterfaces (odsinterfaces);
## @end example

## Author: Philip Nienhuis
## Created: 2009-12-27
## Updates:
## 2010-01-14
## 2010-01-17 Make sure proper dimensions are checked in parsed javaclasspath
## 2010-04-11 Introduced check on odfdom.jar version - only 0.7.5 works properly
## 2010-06-02 Moved in check on JOD version
## 2010-06-05 Experimental odfdom 0.8.5 support
## 2010-06-## dropped 0.8.5, too buggy
## 2010-08-22 Experimental odfdom 0.8.6 support
## 2010-08-23 Added odfvsn (odfdom version string) to output struct argument
##     "      Bugfix: moved JOD version check to main function (it can't work here)
##     "      Finalized odfdom 0.8.6 support (even prefered version now)
## 2010-09-11 Somewhat clarified messages about missing java classes
##     "      Rearranged code a bit; fixed typos in OTK detection code (odfdvsn -> odfvsn)
## 2010-09-27 More code cleanup
## 2010-11-12 Warning added about waning support for odfdom v. 0.7.5
## 2011-05-06 Fixed wrong strfind tests
##     "      Experimental UNO support added

function [odsinterfaces] = getodsinterfaces (odsinterfaces)

	if (isempty (odsinterfaces.OTK) && isempty (odsinterfaces.JOD))
		chk1 = 1;
		printf ("Supported interfaces: ");
	else
		chk1= 0;
	endif

	# Check Java support
	try
		jcp = javaclasspath;
		# If we get here, at least Java works. Now check for proper entries
		# in class path. Under *nix the classpath must first be split up
		if (isunix) jcp = strsplit (char(tmp1), ":"); endif
		## FIXME implement more rigid Java version check a la xlsopen.
		## ods / Java stuff is less critical than xls / Java, however
	catch
		# No Java support
		if ~(isempty (odsinterfaces.OTK) && isempty (odsinterfaces.JOD))
			# Some Java-based interface requested but Java support is absent
			error ('No Java support found.');
		else
			# No specific Java-based interface requested. Just return
			return;
		endif
		odsinterfaces.OTK = 0;
		odsinterfaces.JOD = 0;
		odsinterfaces.UNO = 0;
	end_try_catch

	# Try Java & UNO
	if (isempty (odsinterfaces.UNO))
		# entries0(1) = not a jar but a directory (<000_install_dir/program/>)
		jpchk = 0; entries = {'program', 'unoil', 'jurt', 'juh', 'unoloader', 'ridl'};
		# Only under *nix we might use brute force: e.g., strfind (javaclasspath, classname)
		# as javaclasspath is one long string. Under Windows however classpath is a cell array
		# so we need the following more subtle, platform-independent approach:
		for jj=1:numel (entries)
			for ii=1:numel (jcp)
				jcplst = strsplit (jcp{ii}, filesep);
				jcpentry = jcplst {end};
				if (~isempty (strfind (lower (jcpentry), lower (entries{jj}))))
					jpchk = jpchk + 1;
				endif
			endfor
		endfor
		if (jpchk >= numel (entries))
			odsinterfaces.UNO = 1;
			fprintf ('  => UNO (OOo) OK\n');
			chk1 = 1;
		else
			warning ('\nOne or more UNO classes (.jar) missing in javaclasspath');
		endif
	endif

	# Try Java & ODF toolkit
	if (isempty (odsinterfaces.OTK))
		odsinterfaces.OTK = 0;
		jpchk = 0; entries = {"odfdom", "xercesImpl"};
		# Only under *nix we might use brute force: e.g., strfind(classpath, classname);
		# under Windows we need the following more subtle, platform-independent approach:
		for ii=1:length (tmp1)
			for jj=1:length (entries)
				if (~isempty (strfind ( tmp1{ii}, entries{jj}))), ++jpchk; endif
			endfor
		endfor
		if (jpchk >= numel(entries))		# Apparently all requested classes present.
			# Only now we can check for proper odfdom version (only 0.7.5 & 0.8.6 work OK).
			# The odfdom team deemed it necessary to change the version call so we need this:
			odfvsn = ' ';
			try
				# New in 0.8.6
				odfvsn = java_invoke ('org.odftoolkit.odfdom.JarManifest', 'getOdfdomVersion');
			catch
				odfvsn = java_invoke ('org.odftoolkit.odfdom.Version', 'getApplicationVersion');
			end_try_catch
			if ~(strcmp (odfvsn, '0.7.5') || strcmp (odfvsn, '0.8.6'))
				warning ("\nodfdom version %s is not supported - use v. 0.7.5 or 0.8.6.\n", odfvsn);
			else
				if (strcmp (odfvsn, '0.7.5'))
					warning ("odfdom v. 0.7.5 support won't be maintained - please upgrade to 0.8.6 or higher."); 
				endif
				odsinterfaces.OTK = 1;
				printf (" Java/ODFtoolkit (OTK) OK. ");
				chk1 = 1;
			endif
			odsinterfaces.odfvsn = odfvsn;
		else
			warning ("\nNot all required classes (.jar) in classpath for OTK");
		endif
	endif

	# Try Java & jOpenDocument
	if (isempty (odsinterfaces.JOD))
		odsinterfaces.JOD = 0;
		jpchk = 0; entries = {"jOpenDocument"};
		for ii=1:length (tmp1)
			for jj=1:length (entries)
				if (~isempty (strfind (tmp1{ii}, entries{jj}))), ++jpchk; endif
			endfor
		endfor
		if (jpchk >= numel(entries))
			odsinterfaces.JOD = 1;
			printf (" Java/jOpenDocument (JOD) OK. ");
			chk1 = 1;
		else
			warning ("\nNot all required classes (.jar) in classpath for JOD");
		endif
	endif
	
	# ---- Other interfaces here, similar to the ones above

	if (chk1) printf ("\n"); endif
	
endfunction
