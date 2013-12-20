## Copyright (C) 2009,2010,2011,2012,2013 Philip Nienhuis
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
## @deftypefn  {Function File} {[ @var{retval} ]} = chk_spreadsheet_support ()
## @deftypefnx {Function File} {[ @var{retval} ]} = chk_spreadsheet_support ( @var{path_to_jars} )
## @deftypefnx {Function File} {[ @var{retval} ]} = chk_spreadsheet_support ( @var{path_to_jars}, @var{debug_level} )
## @deftypefnx {Function File} {[ @var{retval} ]} = chk_spreadsheet_support ( @var{path_to_jars}, @var{debug_level}, @var{path_to_ooo} )
## Check Octave environment for spreadsheet I/O support, report any problems,
## and optionally add Java class libs for spreadsheet support.
##
## chk_spreadsheet_support first checks ActiveX (native MS-Excel); then
## Java JRE presence, then Java support (builtin) or added tru octave-forge
## Java package (Octave); then checks existing javaclasspath for Java class
## libraries (.jar files) needed for various Java-based spreadsheet I/O
## interfaces. If requested chk_spreadsheet_support will try to add the relevant
## Java class libs to the dynamic javaclasspath.
##
## @var{path_to_jars} - relative or absolute path name to subdirectory
## containing these classes. TAKE NOTICE: /forward/ slashes are needed!
## chk_spreadsheet_support() will recurse into at most two subdir levels;
## if the Java class libs are scattered across deeper subdir levels or
## further apart in the file system, multiple calls to 
## chk_spreadsheet_support may be required. @var{path_to_jars} can be [] 
## or '' if no class libs need to be added to the javaclasspath.
##
## @var{debug_level}: (integer) between [0 (no output) .. 3 (full output]
## @table @asis
## @indent
## @item 0
## No debug output is generated.
##
## @item 1 
## Only proper operation of main interface groups (COM, Java) is shown.
## If @var{path_to_jars} and/or @var{path_to_ooo} was supplied,
## chk_spreadsheet_support indicates whether it could find the required
## Java class libs for all interfaces
##
## @item 2
## Like 1, proper working of individual implemented Java-based interfaces is
## shown as well. If @var{path_to_jars} and/or @var{path_to_ooo} was supplied,
## chk_spreadsheet_support indicates for each individual Java-based interface
## whether it could add the required Java class libs.
##
## @item 3
## Like 2, also presence of individual javaclass libs in javaclasspath is
## indicated. If @var{path_to_jars} and/or @var{path_to_ooo} was supplied,
## chk_spreadsheet_support reports for each individual Java-based interface
## which required Java class libs it could find and add to the javaclasspath.
## @noindent
## @end table
##
## @var{path_to_ooo} - installation directory of Openffice.org (again with
## /forward/ slashes). Usually that is something like (but no guarantees):
## @table @asis
## - Windows: C:/Program Files/OpenOffice.org
##
## - *nix: /usr/lib/ooo  or  /opt/libreoffice
##
## - Mac OSX: ?????
##
## IMPORTANT: @var{path_to_ooo} should be such that both:
## @example
## @group
## 1. PATH_TO_OOO/program/
##   and
## 2. PATH_TO_OOO/ure/.../ridl.jar
## resolve OK.
## @end group
## @end example
## @end table
##
## Output:
## @var{retval} = 0: only spreadsheet read support for OOXML,
## ODS 1.2 and gnumeric present through OCT interface, or
## @var{retval} <> 0: At least one read/write spreadsheet I/O
## interface found.
## RETVAL will be set to the sum of values for found interfaces:
## @example
##     0 = OCT (Native Octave)
##         (only read support for .xlsx, .ods and .gnumeric)
##    ---------- XLS (Excel) interfaces: ----------
##     1 = COM (ActiveX / Excel) (any file format supported by MS-Excel)
##     2 = POI (Java / Apache POI) (Excel 97-2003 = BIFF8)
##     4 = POI+OOXML (Java / Apache POI) (Excel 2007-2010 = OOXML)
##     8 = JXL (Java / JExcelAPI) (Excel 95-read and Excel-97-2003-r/w)
##    16 = OXS (Java / OpenXLS) (Excel 97-2003)
##    --- ODS (OpenOffice.org Calc) interfaces ----
##    32 = OTK (Java/ ODF Toolkit) (ODS 1.2)
##    64 = JOD (Java / jOpenDocument) (.sxc (old OOo)-read, ODS 1.2)
##    ----------------- XLS & ODS: ----------------
##     0 = OOXML / ODS / gumeric read support (built-in)
##   128 = UNO (Java/UNO bridge - OpenOffice.org) (any format supported by OOo)
## @end example
## @end deftypefn

function  [ retval ]  = chk_spreadsheet_support (path_to_jars, dbug, path_to_ooo)

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created 2010-11-03 for Octave & Matlab
## Updates:
## 2010-12-19 Found that dom4j-1.6.1.jar is needed regardless of ML's dom4j
##            presence in static classpath (ML r2007a)
## 2011-01-04 Adapted for general checks, debugging & set up, both Octave & ML
## 2011-04-04 Rebuilt into general setup/debug tool for spreadsheet I/O support
##            and renamed chk_spreadsheet_support()
## 2011-05-04 Added in UNO support (OpenOffice.org & clones)
##     ''     Improved finding jar names in javaclasspath
## 2011-05-07 Improved help text
## 2011-05-15 Better error msg if OOo instal dir isn't found
## 2011-05-20 Attempt to cope with case variations in subdir names of OOo install dir (_get_dir_)
## 2011-05-27 Fix proper return value (retval); header text improved
## 2011-05-29 Made retval value dependent on detected interfaces & adapted help text
## 2011-06-06 Fix for javaclasspath format in *nix w. octave-java-1.2.8 pkg
##     ''     Fixed wrong return value update when adding UNO classes
## 2011-09-03 Small fix to better detect Basis* subdir when searching unoil.jar
## 2011-09-18 Fixed 'Matlab style short circuit' warning in L. 152
## 2012-12-24 Amended code stanza to find unoil.jar; now works in LibreOffice 3.5b2 as well
## 2012-06-07 Replaced all tabs by double space
## 2012-06-24 Replaced error msg by printf & return
##     ''     Added Java pkg inquiry (Octave) before attempting javaclasspath()
##     ''     Updated check for odfdom version (now supports 0.8.8)
## 2012-10-07 Moved common classpath entry code to private function
## 2012-12-21 POI 3.9 support (w. either xmlbeans.jar or xbeans.jar)
## 2013-01-16 Updated to Octave w built-in Java (3.7.1+)
## 2013-06-23 More informative error messages:
##     ''     COM section: only called on Windows
##     ''     Java section: first check for Java support in Octave
##     ''     Restyled into Octave conventions
## 2013-07-18 Add Fedora naming scheme to POI jar entries (the "old" ones are symlinks)
## 2013-08-12 More restyling
##     ''     odfdom 0.8.9 support (incubator-0.6) - alas that is buggy :-(  => dropped
##     ''     Removed all Matlab-specific code
## 2013-08-19 Fixed wrong reference to path_to_jars where path_to_ooo was intended
##     ''     Fixed wrong echo of argument nr in checks on path_to_ooo
## 2013-08-20 Allow subdir searches for Java class libs
## 2013-09-01 Adapt recursive file search proc name (now rfsearch.m)
## 2013-12-14 Texinfo header updated to OCT

  jcp = []; retval = 0;
  if (nargin < 3)
    path_to_ooo= "";
  endif
  if (nargin < 2)
    dbug = 0;
  endif
  if (dbug)
    printf ('\n');
  endif
  ## interfaces = {"COM", "POI", "POI+OOXML", "JXL", "OXS", "OTK", "JOD", "UNO", "OCT"}; 
  ## Order  = vital

  ## Check if MS-Excel COM ActiveX server runs. Only needed on Windows systems
  if (ispc)
    if (dbug)
      printf ("Checking Excel/ActiveX/COM... ");
    endif
    try
      app = actxserver ("Excel.application");
      ## If we get here, the call succeeded & COM works.
      xlsinterfaces.COM = 1;
      ## Close Excel to avoid zombie Excel invocation
      app.Quit();
      delete(app);
      if (dbug), printf ("OK.\n\n"); endif
      retval = retval + 1;
    catch
      ## COM not supported
      if (dbug)
        printf ("not working.\n");
      endif
      ## Check if Windows package is installed and loaded
      pkglist = pkg ("list");
      winpkgind = find (cellfun (@(x) strcmp(x.name, "windows"), pkglist), 1, "first");
      if (! isempty (winpkgind))
        winpkg = pkglist{winpkgind};
        if (winpkg.loaded)
          printf ("MS-Excel couldn't be started (maybe because of 64-bit MS-Office?)\n");
        endif
      else
        printf ("(windows package is required for COM/ActiveX support)\n");
      endif
      printf ("\n");
    end_try_catch
  endif

  ## Check Java
  if (dbug)
    printf ("Checking Java support...\n");
  endif
  if (dbug > 1)
    printf ("  1. Checking Java JRE presence.... ");
  endif
  ## Try if Java is installed at all
  if (ispc)
    ## FIXME the following call fails on 64-bit Windows
    jtst = (system ("java -version 2> nul"));
  else
    jtst = (system ("java -version 2> /dev/null"));
  endif
  if (dbug)
    if (jtst)
      printf ("Apparently no Java JRE installed.\n");
      if (! retval)
        printf ("Only read support for ODS 1.2 (.ods), OOXML (.xlsx) and .gnumeric present\n");
      endif
      return;
    else
      if (dbug > 1), printf ("OK, found one.\n"); endif
    endif
    if (dbug > 1)
      printf ("  2. Checking Octave Java support... ");
    endif
  endif
  ## Check Java package (older) or core Java support (newer Octave)
  try
    ## The following stanza is meant for older Octave w/o built-in Java
    if (compare_versions (OCTAVE_VERSION, "3.7.2", "<"))
      ## Check Java package
      [~, b] = pkg ("describe", "java");
      if (strcmpi (b{:}, "Not loaded"))
        if (dbug > 1)
          printf ('Java package found but not loaded. First do: "pkg load java"\n');
        endif
      elseif strcmpi (b{:}, "Not installed")
        if (dbug > 1)
          printf ("Java package is not installed.\n");
        endif
      endif
    else
      ## Check for proper look of UGLY_DEFS/features (only needed for 3.7.2+ version)
      if (isfield (octave_config_info, "features"))
        if (! octave_config_info.features.JAVA)
          if (dbug)
            printf ("none.\n");
            printf ("     (Octave was built without core Java support)\n");
          endif
        endif
      elseif (isfield (octave_config_info, "UGLY_DEFS"))
        if (isempty (regexp (octave_config_info.UGLY_DEFS, "HAVE_JAVE=1", "match")))
          if (dbug)
            printf ("none.\n");
            printf ("     (Octave was built without enabled core Java support)\n");
          endif
        endif
      endif
    endif

    ## OK sufficient info to give it a try
    jcp = javaclasspath ("-all");
    ## If we get here (=past above statement), at least Java works.

    if (dbug > 1)
      printf ("Java seems to work OK.\n");
    endif
    ## Now check for proper version (> 1.6.x.x)
    jver = char (javaMethod ("getProperty", "java.lang.System", "java.version"));
    cjver = strsplit (jver, ".");
    if (sscanf (cjver{2}, "%d") < 6)
      if (dbug)
        printf ("  Java version (%s) too old - you need at least Java 6 (v. 1.6.x.x)\n", jver);
        warning ('    At Octave prompt, try "!system ("java -version")"'); 
      endif
      return
    else
      if (dbug > 2)
        printf ("  Java (version %s) seems OK.\n", jver);
      endif
    endif
    ## Under *nix the classpath must first be split up.
    if (isunix && ! iscell (jcp))
      jcp = strsplit (char (jcp), ":");
    endif
    if (dbug > 1)
      ## Check JVM virtual memory settings
      jrt = javaMethod ("getRuntime", "java.lang.Runtime");
      jmem = jrt.maxMemory ()
      ## Some Java versions return jmem as octave_value => convert to double
      if (! isnumeric (jmem))
        jmem = jmem.doubleValue();
      endif
      jmem = int16 (jmem/1024/1024);
      printf ("  Maximum JVM memory: %5d MiB; ", jmem);
      if (jmem < 400)
        printf ("should better be at least 400 MB!\n");
        printf ('    Hint: adapt setting -Xmx in file "java.opts" (supposed to be here:)\n');
        printf ("    %s\n", [matlabroot filesep "share" filesep "octave" filesep "packages" filesep "java-<version>" filesep "java.opts"]);
      else
        printf ("sufficient.\n");
      endif
    endif
    if (dbug)
      printf ("Java support OK\n");
    endif
  catch
    if (dbug)
      printf ("No Java support found.\n");
      if (! retval)
        printf ("Only read support for ODS 1.2 (.ods), OOXML (.xlsx) amd .gnumeric\n");
      endif
    endif
    return
  end_try_catch

  if (dbug)
    printf ("\nChecking javaclasspath for .jar class libraries needed for spreadsheet I/O...:\n");
  endif

  ## Try Java & Apache POI. First Check basic .xls (BIFF8) support
  if (dbug > 1)
    printf ("\nBasic POI (.xls) <poi-3> <poi-ooxml>:\n");
  endif
  entries1 = {{"apache-poi.", "poi-3"}, {"apache-poi-ooxml.", "poi-ooxml-3"}}; missing1 = zeros (1, numel (entries1));
  ## Only under *nix we might use brute force: e.g., strfind (javaclasspath, classname)
  ## as javaclasspath is one long string. Under Windows however classpath is a cell array
  ## so we need the following more subtle, platform-independent approach:
  [jpchk1, missing1] = chk_jar_entries (jcp, entries1, dbug);
  if (jpchk1 >= numel (entries1))
    retval = retval + 2;
  endif
  if (dbug > 1)
    if (jpchk1 >= numel (entries1))
      printf ("  => Apache (POI) OK\n");
    else
      printf ("  => Not all classes (.jar) required for POI in classpath\n");
    endif
  endif
  ## Next, check OOXML support
  if (dbug > 1)
    printf ("\nPOI OOXML (.xlsx) <xbean/xmlbean> <poi-ooxml-schemas> <dom4j>:\n");
  endif
  entries2 = {{"xbean", "xmlbean"}, {"apache-poi-ooxml-schemas", "poi-ooxml-schemas"}, "dom4j"}; 
  ## Only update retval if all classes for basic POI have been found in javaclasspath
  [jpchk2, missing2] = chk_jar_entries (jcp, entries2, dbug);
  if (jpchk1 >= numel (entries1) && jpchk2 >= numel (entries2))
    retval = retval + 4;
  endif
  if (dbug > 1)
    if (jpchk2 >= numel (entries2)) 
      printf ("  => POI OOXML OK\n");
    else
      printf ("  => Some classes for POI OOXML support missing\n"); 
    endif
  endif

  ## Try Java & JExcelAPI
  if (dbug > 1)
    printf ("\nJExcelAPI (.xls (incl. BIFF5 read)) <jxl>:\n");
  endif
  entries3 = {"jxl"}; missing3 = zeros (1, numel (entries3));
  [jpchk, missing3] = chk_jar_entries (jcp, entries3, dbug);
  if (jpchk >= numel (entries3))
    retval = retval + 8;
  endif
  if (dbug > 1)
    if (jpchk >= numel (entries3))
      printf ("  => Java/JExcelAPI (JXL) OK.\n");
    else
      printf ("  => Not all classes (.jar) required for JXL in classpath\n");
    endif
  endif

  ## Try Java & OpenXLS
  if (dbug > 1)
    printf ("\nOpenXLS (.xls (BIFF8)) <OpenXLS>:\n");
  endif
  entries4 = {"OpenXLS"}; missing4 = zeros (1, numel (entries4));
  [jpchk, missing4] = chk_jar_entries (jcp, entries4, dbug);
  if (jpchk >= numel (entries4))
    retval = retval + 16;
  endif
  if (dbug > 1)
    if (jpchk >= numel (entries4))
      printf ("  => Java/OpenXLS (OXS) OK.\n");
    else
      printf ("  => Not all classes (.jar) required for OXS in classpath\n");
    endif
  endif

  ## Try Java & ODF toolkit
  if (dbug > 1)
    printf ("\nODF Toolkit (.ods) <odfdom> <xercesImpl>:\n");
  endif
  entries5 = {"odfdom", "xercesImpl"}; missing5 = zeros (1, numel (entries5));
  [jpchk, missing5] = chk_jar_entries (jcp, entries5, dbug);
  if (jpchk >= numel (entries5))    ## Apparently all requested classes present.
    ## Only now we can check for proper odfdom version (only 0.7.5 & 0.8.6-0.8.8 work OK).
    ## The odfdom team deemed it necessary to change the version call so we need this:
    odfvsn = " ";
    try
      ## New in 0.8.6
      odfvsn = javaMethod ("getOdfdomVersion", "org.odftoolkit.odfdom.JarManifest");
    catch
      ## Worked in 0.7.5
      odfvsn = javaMethod ("getApplicationVersion", "org.odftoolkit.odfdom.Version");
    end_try_catch
    ## For odfdom-incubator (= 0.8.8+), strip extra info
    odfvsn = regexp (odfvsn, '\d\.\d\.\d', "match"){1};
    if (! (strcmp (odfvsn, "0.7.5") || (compare_versions (odfvsn, "0.8.6", ">=") ...
           && compare_versions (odfvsn, "0.8.9", "<"))))
      warning ("  *** odfdom version (%s) is not supported - use v. 0.8.6 - 0.8.8\n", odfvsn);
    else  
      if (dbug > 1), printf ("  => ODFtoolkit (OTK) OK.\n"); endif
      retval = retval + 32;
    endif
  elseif (dbug > 1)
    printf ("  => Not all required classes (.jar) in classpath for OTK\n");
  endif

  ## Try Java & jOpenDocument
  if (dbug > 1)
    printf ("\njOpenDocument (.ods + experimental .sxc readonly) <jOpendocument>:\n");
  endif
  entries6 = {"jOpenDocument"}; missing6 = zeros (1, numel (entries6));
  [jpchk, missing6] = chk_jar_entries (jcp, entries6, dbug);
  if (jpchk >= numel (entries6))
    retval = retval + 64;
  endif
  if (dbug > 1)
    if (jpchk >= numel(entries6))
      printf ("  => jOpenDocument (JOD) OK.\n");
    else
      printf ("  => Not all required classes (.jar) in classpath for JOD\n");
    endif
  endif

  ## Try Java & UNO
  if (dbug > 1)
    printf ("\nUNO/Java (.ods, .xls, .xlsx, .sxc) <OpenOffice.org>:\n");
  endif
  ## entries0(1) = not a jar but a directory (<000_install_dir/program/>)
  entries0 = {"program", "unoil", "jurt", "juh", "unoloader", "ridl"};
  [jpchk, missing0] = chk_jar_entries (jcp, entries0, dbug);
  if (jpchk >= numel (entries0))
    retval = retval + 128;
  endif
  if (dbug > 1)
    if (jpchk >= numel (entries0))
      printf ("  => UNO (OOo) OK\n");
    else
      printf ("  => One or more UNO classes (.jar) missing in javaclasspath\n");
    endif
  endif

  ## If requested, try to add UNO stuff to javaclasspath
  ujars_complete = isempty (find (missing0, 1));

  if ((! ujars_complete) && nargin > 0 && (! isempty (path_to_ooo)))
    if (dbug)
      printf ("\nTrying to add missing program subdir & UNO java class libs to javaclasspath...\n");
    endif
    if (~ischar (path_to_ooo))
      printf ("Path expected for arg # 3\n");
      return;
    endif
    if (! isempty (strfind (path_to_ooo, '\')))
      printf ("\n(Hmmm... forward slashes are preferred over backward slashes in path)\n");
    endif
    ## Add missing jars to javaclasspath. First combine all entries
    targt = sum (missing0);
    if (missing0(1))
      ## Add program dir (= where soffice or soffice.exe or ooffice resides)
      programdir = [path_to_ooo filesep entries0{1}];
      if (exist (programdir, "dir"))
        if (dbug > 2)
          printf ("  Found %s, adding it to javaclasspath ... ", programdir);
        endif
        try
          javaaddpath (programdir);
          targt = targt - 1;
          if (dbug > 2)
            printf ("OK\n");
          endif
        catch
          if (dbug > 2)
            printf ("FAILED\n");
          endif
        end_try_catch
      else
        if (dbug > 2)
          printf ("Suggested OpenOffice.org install directory: %s not found!\n", path_to_ooo); 
          return
        endif
      endif
    endif
    ## Rest of missing entries. Find where URE is located. Watch out because
    ## case of ./ure is unknown
    uredir = get_dir_ (path_to_ooo, "ure");
    if (isempty (uredir))
      return
    endif
    ## Now search for UNO jars
    for ii=2:length (entries0)
      if (missing0(ii))
        if (ii == 2)
          ## Special case as unoil.jar usually resides in ./Basis<something>/program/classes
          ## Find out the exact name of Basis.....
          basisdirlst = dir ([path_to_ooo filesep "?asis" "*"]);
          jj = 1;
          if (numel (basisdirlst) > 0) 
            while (jj <= size (basisdirlst, 1) && jj > 0)
              basisdir = basisdirlst(jj).name;
              if (basisdirlst(jj).isdir)
                basisdir = basisdirlst(jj).name;
                jj = 0;
              else
                jj = jj + 1;
              endif
            endwhile
            basisdir = [path_to_ooo filesep basisdir ];
          else
            basisdir = path_to_ooo;
          endif
          basisdirentries = {"program", "classes"};
          tmp = basisdir; jj=1;
          while (~isempty (tmp) && jj <= numel (basisdirentries))
            tmp = get_dir_ (tmp, basisdirentries{jj});
            jj = jj + 1;
          endwhile
          unojarpath = tmp;
          file = dir ([ unojarpath filesep entries0{2} "*" ]);
        else
          ## Rest of jars in ./ure/share/java or ./ure/java
          unojardir = get_dir_ (uredir, "share");
          if (isempty (unojardir))
            tmp = uredir;
          else
            tmp = unojardir;
          endif
          unojarpath = get_dir_ (tmp, "java");
          file = dir ([unojarpath filesep entries0{ii} "*"]);
        endif
        ## Path found, now try to add jar
        if (isempty (file))
          if (dbug > 2)
            printf ("  ? %s<...>.jar ?\n", entries0{ii});
          endif
        else
          if (dbug > 2)
            printf ("  Found %s, adding it to javaclasspath ... ", file.name);
          endif
          try
            javaaddpath ([unojarpath filesep file.name]);
            targt = targt - 1;
            if (dbug > 2)
              printf ("OK\n");
            endif
          catch
            if (dbug > 2)
              printf ("FAILED\n");
            endif
          end_try_catch
        endif
      endif
    endfor
    if (~targt)
      retval = retval + 128;
    endif
    if (dbug)
      if (targt)
        printf ("Some UNO class libs still lacking...\n\n"); 
      else
        printf ("UNO interface supported now.\n\n");
      endif
    endif
  endif

## ----------Rest of Java interfaces----------------------------------

  missing = [missing1 missing2 missing3 missing4 missing5 missing6];
  jars_complete = isempty (find (missing, 1));
  if (dbug)
    if (jars_complete)
      printf ("All Java-based interfaces (save UNO) fully supported.\n\n");
    else
      printf ("Some class libs lacking yet...\n\n"); 
    endif
  endif

  if (! jars_complete && nargin > 0 && ! isempty (path_to_jars))
    ## Add missing jars to javaclasspath. Assume they're all in the same place
    if (dbug)
      printf ("Trying to add missing java class libs to javaclasspath...\n");
    endif
    if (~ischar (path_to_jars))
      printf ("Path expected for arg # 1\n");
      return;
    endif
    ## First combine all entries
    targt = sum (missing);
    ## For each interface, search tru list of missing entries
    for ii=1:6   ## Adapt number in case of future new interfaces
      tmpe = eval ([ "entries" char(ii + "0") ]);
      tmpm = eval ([ "missing" char(ii + "0") ]);
      if (sum (tmpm))
        for jj=1:numel (tmpe)
          if (tmpm(jj))
            if (iscellstr (tmpe{jj}))
              rtval = 0; kk = 1;
              while (kk <= numel (tmpe{jj}) && ! rtval)
                jtmpe = tmpe{jj}{kk};
                rtval = add_jars_to_jcp (path_to_jars, jtmpe, dbug);
                ++kk;
              endwhile
            else
              rtval = add_jars_to_jcp (path_to_jars, tmpe{jj}, dbug);
            endif
            if (rtval)
              targt = targt - rtval;
              tmpm(jj) = 0;
            endif
          endif
        endfor
        if (~sum (tmpm))
          retval = retval + 2^ii;
        endif
      endif
    endfor
    if (dbug)
      if (targt)
        printf ("Some other class libs still lacking...\n\n");
      else
        printf ("All Java-based interfaces fully supported.now.\n\n");
      endif
    endif
  endif

endfunction


function [ ret_dir ] = get_dir_ (base_dir, req_dir)

## Construct path to subdirectory req_dir in a subdir tree, aimed
## at taking care of proper case (esp. for *nix) of existing subdir
## in the result. Case of input var req_dir is ignored on purpose.

  ret_dir = '';
  ## Get list of directory entries
  ret_dir_list = dir (base_dir);
  ## Find matching entries
  idx = find (strcmpi ({ret_dir_list.name}, req_dir));
  ## On *nix, several files and subdirs in one dir may have the same name as long as case differs
  if (! isempty (idx))
    ii = 1;
    while (! ret_dir_list(idx(ii)).isdir)
      ii = ii + 1;
      if (ii > numel (idx)); return; endif
    endwhile
    ## If we get here, a dir with proper name has been found. Construct path
    ret_dir = [ base_dir filesep  ret_dir_list(idx(ii)).name ];
  endif

endfunction


function [ retval ] = add_jars_to_jcp (path_to_jars, jarname, dbug)

## Given a subdirectory path and a (sufficiently unique part of a) Java class
## lib file (.jar) name, checks if it can find the file in the subdir and
## tries to add it to the javaclasspath. Only two more subdir levels below the
## path_to_jar subdir will be searched to limit excessive search time.

  retval = 0;
  ## Search subdirs. Max search depth = 2 to avoid undue search time
  file = rfsearch (path_to_jars, jarname, 2);
  if (isempty (file))
    ## Still not found...
    if (dbug > 2)
      printf ('  ? %s<...>.jar ?\n', jarname);
    endif
  elseif (stat ([path_to_jars filesep file]).size < 1024)
    ## Probably too small for a jar => apparently a symlink
    if (dbug > 2)
      printf ('  File %s is probably a symlink ... \n', file);
    endif
  else
    ## FIXME: cache subdir in file name to speed up search
    if (dbug > 2)
      printf ('  Found %s, adding it to javaclasspath ... ', file);
    endif
    try
      javaaddpath ([path_to_jars filesep file]);
      if (dbug > 2)
        printf ('OK\n');
      endif
      retval = 1;
    catch
      if (dbug > 2)
        printf ('FAILED\n');
      endif
    end_try_catch
  endif

endfunction
