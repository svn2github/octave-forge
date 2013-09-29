## Copyright (C) 2013 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {Function File} {@var{retval} =} __OCT_spsh_open__ (@var{x} @var{y})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## File open stuff by Markus Bergholz
## Created: 2013-09-08
## Updates:
## 2013-09-09 Wipe temp dir after opening as all content is in memory
##            FIXME this needs to be adapted for future OOXML support
## 2013-09-23 Fix copyright messages

function [ xls, xlssupport, lastintf] = __OCT_spsh_open__ (xls, xwrite, filename, xlssupport, chk2, chk3)

  ## Open and unzip file to temp location (code by Markus Bergholz)
  ## create current work folder
  tmpdir = tmpnam;
  confirm_recursive_rmdir (0);      # this is needed for a silent delete of our tmpdir

  %% http://savannah.gnu.org/bugs/index.php?39148
  %% unpack.m taken from bugfix: http://hg.savannah.gnu.org/hgweb/octave/rev/45165d6c4738
  %% needed for octave 3.6.x
  unpack (filename, tmpdir, "unzip");

  ## First check if we're reading ODS
  if (chk3)
    ## Yep. Read the actual data part in content.xml
    fid = fopen (sprintf ("%s/content.xml", tmpdir), "r");
    if (fid < 0)
      ## File open error
      error ("file %s couldn't be opened for reading", filename);
    else
      ## Read file contents. For some reason fgetl needs to be called twice
      xml = fgets (fid);
      xml = fgets (fid);
      
      ## File & expanded subdir are no longer needed for ODS
      fclose (fid);
      rmdir (tmpdir, "s");

      ## To speed things up later on, get sheet names and starting indices
      shtidx = strfind (xml, "<table:table table:name=");
      shtidx = [ shtidx length(xml) ];
      nsheets = numel (shtidx) - 1;
      ## Get sheet names
      sh_names = cell (1, nsheets);
      for ii=1:nsheets
        sh_names(ii) = xml(shtidx(ii)+25 : shtidx(ii)+23+index (xml(shtidx(ii)+25:end), '"'));
      endfor

      ## Fill ods pointer.
      ## FIXME find a class that doesn't display as one looooong string
      xls.workbook = xml;               # content.xml
      xls.sheets.sh_names = sh_names;   # sheet names
      xls.sheets.shtidx = shtidx;       # start &end indices of sheets
      xls.xtype = "OCT";                # OCT is fall-back interface
      xls.app = ' ';                    # location (subdir) of unzipped file for OOXML
                                        # must NOT be an empty string!
      xls.filename = filename;          # spreadsheet filename

      lastintf = "OCT";
      xlssupport += 1;

    endif

  elseif (chk2)
    ## xlsx
    ## FIXME  not implemented yet - Markus' job

  endif  

endfunction
