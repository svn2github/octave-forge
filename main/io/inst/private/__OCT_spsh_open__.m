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
## 2013-10-02 More comments
## 2013-10-20 Adapted parts of Markus' .xlxs code
## 2013-11-10 (MB) Compacted sheet names & rid code in xlsx section

function [ xls, xlssupport, lastintf] = __OCT_spsh_open__ (xls, xwrite, filename, xlssupport, chk2, chk3, chk5)

  ## Open and unzip file to temp location (code by Markus Bergholz)
  ## create current work folder
  tmpdir = tmpnam;

  if (chk5)
    ## Gnumeric xml files are gzipped
    system (sprintf ("gzip -d -c -S=gnumeric %s > %s", filename, tmpdir));
    fid = fopen (tmpdir, 'r');
    xml = fgetl (fid);
    ## Remember length of 1st line
    st_xml = ftell (fid) - 1;
    xml = fread (fid, "char=>char").';
  else
    ## xlsx and ods are zipped
    ## Below is needed for a silent delete of our tmpdir
    confirm_recursive_rmdir (0);

    ## http://savannah.gnu.org/bugs/index.php?39148
    ## unpack.m taken from bugfix: http://hg.savannah.gnu.org/hgweb/octave/rev/45165d6c4738
    ## needed for octave 3.6.x and added to ./private subdir
    ## FIXME delete unpack.m for release 1.3.x
    unpack (filename, tmpdir, "unzip");
  endif  

  ## First check if we're reading ODS
  if (chk3)
    ## ============== ODS. Read the actual data part in content.xml ============
    fid = fopen (sprintf ("%s/content.xml", tmpdir), "r");
    if (fid < 0)
      ## File open error
      error ("file %s couldn't be opened for reading", filename);
    else
      ## Read file contents. For some reason fgets needs to be called twice
      xml = fgets (fid);
      ## Remember length of 1st line
      st_xml = ftell (fid) - 1;
      xml = fgets (fid);
      
      ## Close file but keep it around, store file name in struct pointer
      fclose (fid);

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
      xls.workbook        = tmpdir;         # subdir containing content.xml
      xls.sheets.sh_names = sh_names;       # sheet names
      xls.sheets.shtidx   = shtidx + st_xml;# start & end indices of sheets
      xls.xtype           = "OCT";          # OCT is fall-back interface
      xls.app             = 'ods';          #
                                            # must NOT be an empty string!
      xls.filename = filename;              # spreadsheet filename
      xls.changed = 0;                      # Dummy

    endif

  elseif (chk2)
    ## =======================  XLSX ===========================================
    ## From xlsxread by Markus Bergholz <markuman+xlsread@gmail.com>
    ## https://github.com/markuman/xlsxread
    
    ## Fill xlsx pointer 
    xls.workbook          = tmpdir;         # subdir containing content.xml
    xls.xtype             = "OCT";          # OCT is fall-back interface
    xls.app               = 'xlsx';         # must NOT be an empty string!
    xls.filename = filename;                # spreadsheet filename
    xls.changed = 0;                        # Dummy

    ## Get sheet names. Speeds up other functions a lot if we can do it here
    fid = fopen (sprintf ('%s/xl/workbook.xml', tmpdir));
    if (fid < 0)
      ## File open error
      error ("xls2oct: file %s couldn't be unzipped", filename);
    else
      ## Get content.xml
      fgetl (fid);
      xml = fgetl (fid);
      ## Close file
      fclose (fid);

      ## Get sheet names and indices
      xls.sheets.sh_names = cell2mat (regexp (xml, '<sheet name="(.*?)" sheetId="\d+"', "tokens"));
      xls.sheets.rid = str2double (cell2mat (regexp (xml, '<sheet name=".*?" sheetId="(\d+)"', "tokens")));

    endif

  elseif (chk5)
    ## ====================== Gnumeric =========================================
    xls.workbook = tmpdir;              # location of unzipped files
    xls.xtype    = "OCT";               # interface
    xls.app      = 'gnumeric';          #
    xls.filename = filename;            # file name
    xls.changed  = 0;                   # Dummy

    ## Get nr of sheets & pointers to start of Sheet nodes & end of Sheets node
    shtidx = strfind (xml, "<gnm:Sheet ");
    ## Add offset caused by first line
    xls.sheets.shtidx = [ shtidx index(xml, "</gnm:Sheets>") ] + st_xml;
    xls.sheets.sh_names = cell (1, numel (shtidx));
    sh_names = getxmlnode (xml, "gnm:SheetNameIndex");
    jdx = 1;
    for ii=1:numel (shtidx)
      [xls.sheets.sh_names(ii), ~, jdx] = getxmlnode (sh_names, "gnm:SheetName", jdx, 1);
    endfor

  endif  

  xlssupport += 1;
  lastintf = "OCT";

endfunction
