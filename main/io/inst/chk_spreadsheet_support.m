% Check Octave / Matlab environment for spreadsheet I/O support.
%
%   usage:  [ RETVAL ] = chk_spreadsheet_support ( [/PATH/TO/JARS], [,DEBUG_LEVEL] [,PATH_TO_OOO])
%
%     Input arguments (all are optional):
% /PATH/TO/JARS = (string) path (relative or absolute) to a
%                 subdirectory where java class libraries (.jar)
%                 for spreadsheet I/O reside
% DEBUG_LEVEL   = (integer) between [0 (no output) .. 3 (full output]
% PATH_TO_OOO   = (string) installation directory of Openffice.org,
%                 usually (but not guaranteed):
%                 - Windows: C:\Program Files\OpenOffice.org
%                 - *nix:    /usr/lib/ooo
%                 - Mac OSX: ?????
%                 IMPORTANT: PATH_TO_OOO should be such that both:
%                 1. PATH_TO_OOO/program/       and
%                 2. PATH_TO_OOO/ure/share/java/ridl.jar
%                 resolve OK
%     Returns:
% RETVAL        = 0 No spreadsheet I/O support found
%               = 1 At least one spreadsheet I/O interface found
%
% CHK_SPREADSHEET_SUPPORT first checks ActiveX (native MS-Excel); then
% Java JRE presence, then Java support (builtin/activated - Matlab or
% added tru octave-forge Java package (Octave); then check existing
% javaclasspath for Java class libraries (.jar) needed for spreadsheet
% I/O.
% If desired the relevant classes can be added to the dynamic
% javaclasspath. In that case the path name to the directory 
% containing these classes should be specified as input argument
% with -TAKE NOTICE- /forward/ slashes.
% A second (optional) argument is the default debug level.
% A third (optional) argument is the installation directory of
% OpenOffice.org or clones.

function  [ retval ]  = chk_spreadsheet_support (path_to_jars, dbug, path_to_ooo)

% Copyright (C) 2009,2010,2011 Philip Nienhuis <prnienhuis at users.sf.net>
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Octave; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.

% Author: Philip Nienhuis
% Created 2010-11-03
% Updates:
% 2010-12-19 Found that dom4j-1.6.1.jar is needed regardless of ML's dom4j
%            presence in static classpath (ML r2007a)
% 2011-01-04 Adapted for general checks, debugging & set up, both Octave & ML
% 2011-04-04 Rebuilt into general setup/debug tool for spreadsheet I/O support
%            and renamed chk_spreadsheet_support()
% 2011-05-04 Added in UNO support (OpenOffice.org & clones)
%     ''     Improved finding jar names in javaclasspath
% 2011-05-07 Improved help text
% 2011-05-15 Better error msg if OOo instal dir isn't found
% 2011-05-16 Added missing end %if
%     ''     Improved java pkg install dir for Octave
%     ''     Distinguish URE subdir tree buildup between *nix & Windows OOo install

	jcp = []; retval = 0;
    if (nargin < 2), dbug = 0; path_to_ooo = []; end %if
	isOctave = exist ('OCTAVE_VERSION', 'builtin') ~= 0;
	if (ispc), filesep = '\'; else, filesep = '/'; end %if
    fprintf ('\n');

	% Check if MS-Excel COM ActiveX server runs
	if (dbug), fprintf ('Checking Excel/ActiveX/COM... '); end %if
	try
		app = actxserver ('Excel.application');
		% If we get here, the call succeeded & COM works.
		xlsinterfaces.COM = 1;
		% Close Excel to avoid zombie Excel invocation
		app.Quit();
		delete(app);
		if (dbug), fprintf ('OK.\n\n'); retval = 1; end %if
	catch
		% COM not supported
		if (dbug), fprintf ('not working.\n\n'); end %if
	end %try_catch

    % Check Java
	if (dbug), fprintf ('Checking Java support...\n'); end %if
	if (dbug > 1), fprintf ('  1. Checking Java JRE presence.... '); end %if
	% Try if Java is installed at all
	if (isOctave)
		if (ispc)
			jtst = (system ('java -version 2> nul'));
		else
			jtst = (system ('java -version 2> /dev/null'));
		end %if
	else
		tst1 = version ('-java');
        jtst = isempty (strfind (tst1, 'Java'));
	end %if
	if (jtst)
		error ('Apparently no Java JRE installed.');
	else
		if (dbug > 1), fprintf ('OK, found one.\n'); end %if
	end %if
	if (dbug > 1 && isOctave), fprintf ('  2. Checking Octave Java support... '); end %if
	try
		jcp = javaclasspath ('-all');					%# For Octave java pkg > 1.2.7
		if (isempty (jcp)), jcp = javaclasspath; end %if	%# For Octave java pkg < 1.2.8
		% If we get here, at least Java works.
		if (dbug > 1 && isOctave), fprintf ('Java package seems to work OK.\n'); end %if
		% Now check for proper version
		% (> 1.6.x.x)
		jver = char (javaMethod ('getProperty', 'java.lang.System', 'java.version'));
		cjver = strsplit (jver, '.');
		if (sscanf (cjver{2}, '%d') < 6)
			if (dbug)
				fprintf ('  Java version (%s) too old - you need at least Java 6 (v. 1.6.x.x)\n', jver);
				if (isOctave)
					warning ('    At Octave prompt, try "!system ("java -version")"'); 
				else
					warning ('    At Matlab prompt, try "version -java"');
				end %if
			end %if
			return
		else
			if (dbug > 2), fprintf ('  Java (version %s) seems OK.\n', jver); end %if
		end %if
		% Under *nix the classpath must first be split up.
		% Matlab is braindead here. For ML we need a replacement for Octave's builtin strsplit()
		% This is found on ML Central (BSD license so this is allowed) & adapted for input arg order
 		if (isunix) jcp = strsplit (char (jcp), ':'); end %if
		if (dbug > 1)
			% Check JVM virtual memory settings
			jrt = javaMethod ('getRuntime', 'java.lang.Runtime');
			jmem = jrt.maxMemory ();
			if (isOctave), jmem = jmem.doubleValue(); end %if
			jmem = int16 (jmem/1024/1024);
			fprintf ('  Maximum JVM memory: %5d MiB; ', jmem);
			if (jmem < 400)
				fprintf ('should better be at least 400 MB!\n');
				fprintf ('    Hint: adapt setting -Xmx in file "java.opts" (supposed to be here:)\n');
				if (isOctave)
					tmp = eval ("which javaclasspath");
				  jidx = strfind (tmp, filesep);
				  fprintf ('    %s\n', tmp(jidx(1) : jidx(end))); 
				else
					fprintf ('    $matlabroot/bin/<arch>]\n');
				end %if
			else
				fprintf ('sufficient.\n');
			end %if
		end %if
		if (dbug), fprintf ('Java support OK\n'); end %if
	catch
		error ('No Java support found.');
	end %try_catch

	if (dbug), fprintf ('\nChecking javaclasspath for .jar class libraries needed for spreadsheet I/O...:\n'); end %if

	% Try Java & UNO
	if (dbug > 1), fprintf ('UNO/Java (.ods, .xls, .xlsx, .sxc) <OpenOffice.org>:\n'); end %if
	% entries0(1) = not a jar but a directory (<000_install_dir/program/>)
	jpchk = 0; entries0 = {'program', 'unoil', 'jurt', 'juh', 'unoloader', 'ridl'};
	missing0 = zeros (1, numel (entries0));
	% Only under *nix we might use brute force: e.g., strfind (javaclasspath, classname)
	% as javaclasspath is one long string. Under Windows however classpath is a cell array
	% so we need the following more subtle, platform-independent approach:
	for jj=1:numel (entries0)
		found = 0;
		for ii=1:numel (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
			if (~isempty (strfind (lower (jcpentry), lower (entries0{jj}))))
				jpchk = jpchk + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end %if
		end %for
		if (~found)
			if (dbug > 2)
				if (jj == 1)
					# Just a dir
					fprintf ('  %s.... (directory) not found\n', entries0{jj}); 
				else
					fprintf ('  %s....jar missing\n', entries0{jj}); 
				end %if
			end %if 
			missing0(jj) = 1; 
		end %if
	end %for
	if (dbug > 1)
		if (jpchk >= numel (entries0))
			fprintf ('  => UNO (OOo) OK\n');
			retval = 1;
		else
			fprintf ('  => One or more UNO classes (.jar) missing in javaclasspath\n');
		end %if
	end %if

	% Try Java & Apache POI. First Check basic .xls (BIFF8) support
	if (dbug > 1), fprintf ('\nBasic POI (.xls) <poi-3> <poi-ooxml>:\n'); end %if
	jpchk1 = 0; entries1 = {'poi-3', 'poi-ooxml-3'}; missing1 = zeros (1, numel (entries1));
	% Only under *nix we might use brute force: e.g., strfind (javaclasspath, classname)
	% as javaclasspath is one long string. Under Windows however classpath is a cell array
	% so we need the following more subtle, platform-independent approach:
	for jj=1:length (entries1)
		found = 0;
		for ii=1:length (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
			if (~isempty (strfind (lower (jcpentry), lower (entries1{jj}))))
				jpchk1 = jpchk1 + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end %if
		end %for
		if (~found)
			if (dbug > 2), fprintf ('  %s....jar missing\n', entries1{jj}); end %if 
			missing1(jj) = 1; 
		end %if
	end %for
	if (dbug > 1)
		if (jpchk1 >= numel (entries1))
			fprintf ('  => Apache (POI) OK\n');
			retval = 1;
		else
			fprintf ('  => Not all classes (.jar) required for POI in classpath\n');
		end %if
	end %if
	% Next, check OOXML support
    if (dbug > 1), fprintf ('\nPOI OOXML (.xlsx) <xbean> <poi-ooxml-schemas> <dom4j>:\n'); end %if
	jpchk2 = 0; entries2 = {'xbean', 'poi-ooxml-schemas', 'dom4j-1.6.1'}; 
	missing2 = zeros (1, numel (entries2));
	for jj=1:length (entries2)
		found = 0;
		for ii=1:length (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
			if (~isempty (strfind (lower (jcpentry), lower (entries2{jj}))))
				jpchk2 = jpchk2 + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end %if
		end % for
		if (~found)
			if (dbug > 2), fprintf ('  %s....jar missing\n', entries2{jj}); end %if
			missing2(jj) = 1;
		end %if
	end % for
	if (dbug > 1)
		if (jpchk2 >= numel (entries2)) 
			fprintf ('  => POI OOXML OK\n');
		else
			fprintf ('  => Some classes for POI OOXML support missing\n'); 
		end %if
	end %if

	% Try Java & JExcelAPI
	if (dbug > 1), fprintf ('\nJExcelAPI (.xls (incl. BIFF5 read)) <jxl>:\n'); end %if
	jpchk = 0; entries3 = {'jxl'}; missing3 = zeros (1, numel (entries3));
	for jj=1:length (entries3)
		found = 0;
		for ii=1:length (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
			if (~isempty (strfind (lower (jcpentry), lower (entries3{jj}))))
				jpchk = jpchk + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end % if
		end %for
		if (~found) 
			if (dbug > 2), fprintf ('  %s....jar missing\n', entries3{jj}); end %if 
			missing3(jj) = 1; 
		end %if
	end %for
	if (dbug > 1)
		if (jpchk >= numel (entries3))
			fprintf ('  => Java/JExcelAPI (JXL) OK.\n');
			retval = 1;
		else
			fprintf ('  => Not all classes (.jar) required for JXL in classpath\n');
		end %if
	end %if

	% Try Java & OpenXLS
	if (dbug > 1), fprintf ('\nOpenXLS (.xls (BIFF8)) <OpenXLS>:\n'); end %if
	jpchk = 0; entries6 = {'OpenXLS'}; missing6 = zeros (1, numel (entries3));
	for jj=1:length (entries6)
		found = 0;
		for ii=1:length (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
			if (~isempty (strfind (lower (jcpentry), lower (entries6{jj}))))
				jpchk = jpchk + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end % if
		end %for
		if (~found) 
			if (dbug > 2), fprintf ('  %s....jar missing\n', entries6{jj}); end %if 
			missing6(jj) = 1; 
		end %if
	end %for
	if (dbug > 1)
		if (jpchk >= numel (entries6))
			fprintf ('  => Java/OpenXLS (OXS) OK.\n');
			retval = 1;
		else
			fprintf ('  => Not all classes (.jar) required for OXS in classpath\n');
		end %if
	end %if

	% Try Java & ODF toolkit
	if (dbug > 1), fprintf ('\nODF Toolkit (.ods) <odfdom> <xercesImpl>:\n'); end %if
	jpchk = 0; entries4 = {'odfdom', 'xercesImpl'}; missing4 = zeros (1, numel (entries4));
	% Only under *nix we might use brute force: e.g., strfind(classpath, classname)
	% as classpath is one long string. Under Windows however classpath is a cell array
	% so we need the following more subtle, platform-independent approach:
	for jj=1:length (entries4)
		found = 0;
		for ii=1:length (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
			if (~isempty (strfind ( lower (jcpentry), lower (entries4{jj}))))
				jpchk = jpchk + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end %if
		end %for
		if (~found) 
			if (dbug > 2), fprintf ('  %s....jar missing\n', entries4{jj}); end %if
			missing4(jj) = 1; 
		end %if
	end %for
	if (jpchk >= numel (entries4))		% Apparently all requested classes present.
		% Only now we can check for proper odfdom version (only 0.7.5 & 0.8.6 work OK).
		% The odfdom team deemed it necessary to change the version call so we need this:
		odfvsn = ' ';
		try
			% New in 0.8.6
			odfvsn = javaMethod ('getOdfdomVersion', 'org.odftoolkit.odfdom.JarManifest');
		catch
			% Worked in 0.7.5
			odfvsn = javaMethod ('getApplicationVersion', 'org.odftoolkit.odfdom.Version');
		end %try_catch
		if ~(strcmp (odfvsn, '0.7.5') || strcmp (odfvsn, '0.8.6'))
			warning ('  *** odfdom version (%s) is not supported - use v. 0.7.5 or 0.8.6.\n', odfvsn);
		else	
			if (dbug > 1), fprintf ('  => ODFtoolkit (OTK) OK.\n'); end %if
			retval = 1;
		end %if
    elseif (dbug > 1)
		fprintf ('  => Not all required classes (.jar) in classpath for OTK\n');
	end %if

	% Try Java & jOpenDocument
	if (dbug > 1), fprintf ('\njOpenDocument (.ods + experimental .sxc readonly) <jOpendocument>:\n'); end %if
	jpchk = 0; entries5 = {'jOpenDocument'}; missing5 = zeros (1, numel (entries5));
	for jj=1:length (entries5)
		found = 0;
		for ii=1:length (jcp)
			jcplst = strsplit (jcp{ii}, filesep);
			jcpentry = jcplst {end};
 			if (~isempty (strfind (lower (jcpentry), lower (entries5{jj}))))
				jpchk = jpchk + 1; found = 1;
				if (dbug > 2), fprintf ('  - %s OK\n', jcp{ii}); end %if
			end %if
		end %for
		if (~found) 
			if (dbug > 2), fprintf ('  %s....jar missing\n', entries5{jj}); end %if 
			missing5(jj) = 1; 
		end %if
	end %for
	if (dbug > 1)
		if (jpchk >= numel(entries5))
			fprintf ('  => jOpenDocument (JOD) OK.\n');
			retval = 1;
		else
			fprintf ('  => Not all required classes (.jar) in classpath for JOD\n');
		end %if
	end %if

	% If requested, try to add UNO stuff to javaclasspath
	ujars_complete = isempty (find (missing0));
	if (dbug > 1)
		if (ujars_complete)
			fprintf ('UNO bridge (OpenOffice.org) supported.\n\n');
		else
			fprintf ('Some UNO class libs lacking yet...\n\n'); 
		end %if
	end %if

	if (~ujars_complete && nargin > 2 && ~isempty (path_to_ooo))
		if (dbug), fprintf ('Trying to add missing UNO java class libs to javaclasspath...\n'); end %if
		if (~ischar (path_to_jars)), error ('Path expected for arg # 1'); end %if
		% Add missing jars to javaclasspath. First combine all entries
		targt = sum (missing0);
		if (missing0(1))
			% Add program dir (= where soffice or soffice.exe or ooffice resides)
			programdir = [path_to_ooo filesep entries0{1}];
			if (exist (programdir, 'dir') == 7)
%			if (fexist (programdir, 'd'))
				if (dbug > 2), fprintf ('  Found %s, adding it to javaclasspath ... ', programdir); end %if
				try
					javaaddpath (programdir);
					targt = targt - 1;
					if (dbug > 2), fprintf ('OK\n'); end %if
				catch
					if (dbug > 2), fprintf ('FAILED\n'); end %if
				end% try_catch
			else
				if (dbug > 2), error ('Suggested OpenOffice.org install directory: %s not found!\n', path_to_ooo); end %if
			end %if
		end %if
		% Rest of missing entries. Find where URE is located
		uredirlst = dir ([path_to_ooo]);
		jj = 1;
		while (jj <= size (uredirlst, 1) && jj > 0)
			uredir = uredirlst(jj).name;
			if (uredirlst(jj).isdir && ~isempty (strfind (lower (uredirlst(jj).name), 'ure')))
				uredir = uredirlst(jj).name;
				jj = 0;
			else
				++jj;
			end %if
		end %while
		% Now search for UNO jars
		for ii=2:length (entries0)
			if (missing0(ii))
				if (ii == 2)
					% Special case as unoil.jar usuaally resides in ./Basis.../program/classes
					% Find out the exact name of Basis.....
					basisdirlst = dir ([path_to_ooo filesep 'basis' '*']);
					jj = 1;
					while (jj < size (basisdirlst, 1) && jj > 0)
						% basisdir = basisdirlst(jj).name;
						if (basisdirlst(jj).isdir)
							basisdir = basisdirlst(jj).name;
							jj = 0;
						else
							++jj;
						end %if
					end %while
					unojarpath = [ path_to_ooo filesep basisdir filesep 'program' filesep 'classes' filesep ];
					file = dir ([ unojarpath entries0{ii} '*' ]);
				else
					% Rest of jars in ./ure/share/java (case not sure)
					if (ispc)
						unojarpath = [ path_to_ooo filesep uredir filesep 'java' filesep ];
					else
						unojarpath = [ path_to_ooo filesep uredir filesep 'share' filesep 'java' filesep ]
					end %if
					file = dir ([unojarpath entries0{ii} '*']);
				end %if
				if (isempty (file))
					if (dbug > 2), fprintf ('  ? %s<...>.jar ?\n', entries0{ii}); end %if
				else
					if (dbug > 2), fprintf ('  Found %s, adding it to javaclasspath ... ', file.name); end %if
					try
						javaaddpath ([unojarpath file.name]);
						targt = targt - 1;
						if (dbug > 2), fprintf ('OK\n'); end %if
					catch
						if (dbug > 2), fprintf ('FAILED\n'); end %if
					end %try_catch
				end %if
			end %if
		end %for
		if (dbug)
			if (targt)
				fprintf ('Some class libs still lacking...\n\n'); 
			else
				fprintf ('All interfaces fully supported.now.\n\n');
				retval = 1;
			end %if
		end %f
	end %if

	% Rest of Java interfaces
	missing = [missing1 missing2 missing3 missing4 missing5 missing6];
	jars_complete = isempty (find (missing));
	if (dbug)
		if (jars_complete)
			fprintf ('All interfaces already fully supported.\n\n');
		else
			fprintf ('Some class libs lacking yet...\n\n'); 
		end %if
	end %if

	if (~jars_complete && nargin > 0 && ~isempty (path_to_jars))
		if (dbug), fprintf ('Trying to add missing java class libs to javaclasspath...\n'); end %if
		if (~ischar (path_to_jars)), error ('Path expected for arg # 1'); end %if
		% Add missing jars to javaclasspath. First combine all entries
		entries = [entries1 entries2 entries3 entries4 entries5 entries6];
		targt = sum (missing);
		% Search tru list of missing entries
		for ii=1:length (entries)
			if (missing(ii))
				file = dir ([path_to_jars filesep entries{ii} '*']);
				if (isempty (file))
					if (dbug > 2), fprintf ('  ? %s<...>.jar ?\n', entries{ii}); end %if
				else
					if (dbug > 2), fprintf ('  Found %s, adding it to javaclasspath ... ', file.name); end %if
					try
						javaaddpath ([path_to_jars filesep file.name]);
						targt = targt - 1;
						if (dbug > 2), fprintf ('OK\n'); end %if
					catch
						if (dbug > 2), fprintf ('FAILED\n'); end %if
					end% try_catch
				end %if
			end %if
		end %for
		if (dbug)
			if (targt)
				fprintf ('Some class libs still lacking...\n\n'); 
			else
				fprintf ('All interfaces fully supported.now.\n\n');
				retval = 1;
			end %if
		end %f
	end %if

end %function
