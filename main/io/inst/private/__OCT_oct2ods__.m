## Copyright (C) 2014 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} {@var{ods}, @var{status} =} __OCT_oct2ods__ (@var{obj}, @var{ods}, @var{wsh}, @var{crange}, @var{spsh_opts})
## Internal function for writing to ODS sheet
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2014-01-18
## Updates:
## 2014-01-23 Fix writing repeated empty cells

function [ ods, status ] = __OCT_oct2ods__ (obj, ods, wsh, crange, spsh_opts=0)

  ## A. Analyze data and requested range
  ## Get size of data to write
  [nnr, nnc ] = size (obj);

  ## Parse requested cell range
  [~, nr, nc, tr, lc] = parse_sp_range (crange);

  ## First check row size
  if (nnr > nr)
    ## Truncate obj
    obj = obj(1:nr, :);
  elseif (nnr < nr)
    ## Truncate requested range
    nr = nnr;
  endif
  ## Next, column size
  if (nnc > nc)
    ## Truncate obj
    obj = obj(:, 1:nc);
  elseif (nnc < nc)
    ## Truncate requested range
    nc = nnc;
  endif
  br = tr + nr - 1;
  rc = lc + nc - 1;

  ## B. Find out if we write to existing or new sheet
  new_sh = 0;
  if (isnumeric (wsh))
    if (wsh < 1)
      error ("ods2oct: sheet number (%d) should be > 0", wsh);
    elseif (wsh > numel (ods.sheets.sh_names))
      ## New sheet
      ods.sheets.sh_names(wsh) = sprintf ("Sheet%d", wsh);
      new_sh = 1; 
      wsh = numel (ods.sheets.sh_names) + 1;
    endif
  elseif (ischar (wsh))
    idx = strmatch (wsh, ods.sheets.sh_names);
    if (isempty (idx))
      ## New sheet
      ods.sheets.sh_names(end+1) = wsh;
      new_sh = 1;
      idx = numel (ods.sheets.sh_names);
    endif
    wsh = idx;
  endif
  ## Check if we made a new file from template
  if (strcmpi (ods.sheets.sh_names{1}, " ") && numel (ods.sheets.sh_names) == 2 && new_sh)
    ods.sheets.sh_names(1) = [];
    new_sh = 0;
    wsh--;
    ods.changed = 2;
  endif

  if (new_sh)
    wsh = numel (ods.sheets.sh_names);
    idx_s = ods.sheets.shtidx(wsh) ;               ## First position after last sheet
    idx_e = idx_s - 1;
    rawarr = {};
  else
    idx_s = ods.sheets.shtidx(wsh);
    idx_e = ods.sheets.shtidx(wsh+1) - 1;
    ## Get all data in sheet and row/column limits
    [rawarr, ods]  = __OCT_ods2oct__ (ods, wsh, "", struct ("formulas_as_text", 1));
    lims = ods.limits;
  endif

  ## C . If required, adapt current data array size to disjoint new data
  if (! isempty (rawarr))
    ## Merge new & current data. Assess where to augment/overwrite current data
    [onr, onc] = size (rawarr);
    if (tr < lims(2, 1))
      ## New data requested above current data. Add rows above current data
      rawarr = [ cell(lims(2, 1) - tr, onc) ; rawarr];
      lims(2, 1) = tr;
    endif
    if (br > lims(2, 2))
      ## New data requested below current data. Add rows below current data
      rawarr = [rawarr ; cell(br - lims(2, 2), onc)];
      lims (2, 2) = br;
    endif
    ## Update number of rawarr rows
    onr = size (rawarr, 1);
    if (lc < lims(1, 1))
      ## New data requested to left of curremnt data; prepend columns
      rawarr = [cell(onr, lims(1, 1) - lc), rawarr];
      lims(1, 1) = lc;
    endif
    if (rc > lims(1, 2))
      ## New data to right of current data; append columns
      rawarr = [rawarr, cell(onr, rc - lims(1, 2))];
      lims(1, 2) = rc;
    endif
    ## Update number of columns
    onc = size (rawarr, 2);

    ## Copy new data into place
    objtr = tr - lims(2, 1) + 1;
    objbr = br - lims(2, 1) + 1;
    objlc = lc - lims(1, 1) + 1;
    objrc = rc - lims(1, 1) + 1;
    rawarr(objtr:objbr, objlc:objrc) = obj; 

  else
    ## New sheet
    lims = [lc, rc; tr, br];
    onc = nc;
    onr = nr;
    rawarr = obj;
  endif


  ## D. Create a temporary file to hold the new sheet xml
  ## Open sheet file (new or old)
  tmpfil = tmpnam;
  fid = fopen (tmpnam, "w+");
  if (fid < 0)
    error ("oct2ods: unable to write to file %s", tmpfil);
  endif

  ## Write data to sheet (actually table:table section in content.xml)
  status  = __OCT__oct2ods_sh__ (fid, rawarr, wsh, lims, onc, onr, ods.sheets.sh_names{wsh});

  ## E. Merge new/updated sheet into content.xml
  ## Read first chunk of content.xml until sht_idx<xx>
  fidc = fopen (sprintf ("%s/content.xml", ods.workbook), "r+");
  ## Go to start of requested sheet
  fseek (fidc, 0, 'bof');
  ## Read and concatenate just adapted/created sheet/table:table
  content_xml = fread (fidc, idx_s - 1, "char=>char").';

  ## Rewind sheet and read it behind content_xml
  fseek (fid, 0, "bof");
  sheet = fread (fid, Inf, "char=>char").';
  lsheet = length (sheet);
  ## Close & delete sheet file
  fclose (fid);
  unlink (tmpfil);
  content_xml = [ content_xml  sheet] ;

  ## Read rest of content.xml, optionally delete overwritten sheet/table:table
  fseek (fidc, idx_e, 'bof');
  content_xml = [ content_xml  fread(fidc, Inf, "char=>char").' ];
  ## Write updated content.xml back to disk.
  fseek (fidc, 0, 'bof');
  fprintf (fidc, "%s", content_xml);
  fclose (fidc);

  ## F. Update sheet pointers in ods file pointer
  if (new_sh)
    ods.sheets.shtidx(wsh+1) = idx_s + lsheet;
    ods.changed = 2;
  else
    offset = lsheet - (idx_e - idx_s) - 1;
    ods.sheets.shtidx(wsh+1 : end) += offset;
  endif
  ods.changed = max (ods.changed, 1);

endfunction


## ===========================================================================
function [ status ] = __OCT__oct2ods_sh__ (fid, rawarr, wsh, lims, onc, onr, tname)

  ## Write out the lot to requested sheet

  ## 1. Sheet open tag
  fprintf (fid, '<table:table table:name="%s" table:style-name="ta1">', tname);

  ## 2. Default column styles
  fprintf (fid, '<table:table-column table-style-name="co1" table:number-columns-repeated="%d" table:default-cell-style-name="Default" />', lims(1, 2));
  
  ## 3. Optional empty rows before data are copied
  ## FIXME actually these empty rows should be combined with upper empty rows in rawarr
  if (lims(2, 1) > 1)
    if (lims(2, 1) > 2)
      tnrr = sprintf (' table:number-rows-repeated="%d"', lims(2, 1) - 1);
    else
      tnrr = "";
    endif
    tncr = "";
    if (lims(1, 2) > 1)
      tncr = sprintf (' table:number-columns-repeated="%d"', lims(1, 2));
    endif
    fprintf (fid, '<table:table-row%s><table:table-cell%s /></table:table-row>', tnrr, tncr);
  endif

  ## 4. Spreadsheet rows
  ii = 1;
  while (ii <= onr)
    ## Check for empty rows
    ## FIXME should actually be combined with empty rows above data (see above)
    if (all (cellfun ("isempty", rawarr(ii, :))))
      tnrr = 1;
      while ((ii + tnrr - 1) < onr && all (cellfun ("isempty", rawarr(++ii, :))))
        ++tnrr;
      endwhile
      if (tnrr > 1)
        tnrr = sprintf (' table:number-rows-repeated="%d"', tnrr);
        ii += tnrr - 1;
      else
        tnrr = "";
      endif
      tcell = sprintf ('<table:table-cell table:number-columns-repeated="%d" />', lims(1, 2));
      fprintf (fid, '<table:table-row%s>%s', tnrr, tcell);
      ## Row closing tag is written below matching endif below next while loop
    else
      ## Write table row opening tag
      fprintf (fid, '<table:table-row table:style-name="ro1">');
      ## 4.1 Optional empty left spreadsheet columns
      if (lims(1, 1) > 1)
        if (lims(1, 1) > 2)
          fprintf (fid, '<table:table-cell table:number-columns-repeated="%d" />', lims(1, 1) - 1);
        else
          fprintf (fid, '<table:table-cell />')
        endif
      endif
      ## 4.2 Value cells
      jj = 1;
      while (jj <= onc)
        ## 4.2.1 Check if empty
        if (isempty (rawarr{ii, jj}))
          ## if empty determine consecutive empty & adapt ncr attr and write
          tncr = 1; 
          while ((jj + tncr - 1) < onc && isempty (rawarr{ii, jj+tncr}))
            ++tncr;
          endwhile
          if (tncr > 1)
%            tncr = sprintf (' table:number-columns-repeated="%d"', tncr);
            fprintf (fid, '<table:table-cell table:number-columns-repeated="%d" />', tncr);
            jj += tncr - 1;
          else
            fprintf (fid, '<table:table-cell />');
          endif
        else
          ## 4.2.2 Determine value class. Set formula attribute to empty
          of = "";
          switch class (rawarr{ii, jj})
            case {"double", "single"}
              ovt = ' office:value-type="float"';
              val = strtrim (sprintf ("%17.4f", rawarr{ii, jj}));
              txt = sprintf ('<text:p>%s</text:p>', val);
              ## Convert to attribute
              val = sprintf (' office:value="%17.10f"', rawarr{ii, jj});
            case {"int64", "int32", "int16", "int8", "uint64", "uint32", "uint16", "uint8"}
              ovt = "integer";
              val = strtrim (sprintf ("%d15", rawarr{ii, jj}));
              txt = sprintf ('<text:p>%s</text:p>', val);
              ## Convert to attribute
              val = sprintf (' office:value="%s"', val);
            case "logical"
              ovt = ' office:value-type="boolean"';
              val = "false";
              if (rawarr{ii, jj})
                val = "true";
              endif
              txt = sprintf ('<text:p>%s</text:p>', upper (val));
              ## Convert to attribute
              val = sprintf (' office:boolean-value="%s"', val);
            case "char"
              if (rawarr{ii, jj}(1) == "=")
                ## We guess a formula. Prepare formula attribute
                ovt = "";
                txt = "";
                val = "";
                of = sprintf (' table:formula="of:%s"', rawarr{ii, jj});
                ## FIXME We'd need to parse cell types in formula = may be formulas as well
                ## We cannot know, or parse, the resulting cell type, omit type info & text
              else
                ## Plain text
                ovt = ' office:value-type="string"';
                val = rawarr{ii, jj};
                txt = sprintf ('<text:p>%s</text:p>', val);
                ## Convert to attribute
                val = sprintf (' office:string-value="%s"', val);
              endif
            otherwise
              ## Unknown, illegal or otherwise unrecognized value
              ovt = "";
          endswitch
          # write out table-cell w office-value-type / office:value
          fprintf (fid, '<table:table-cell%s%s%s>%s</table:table-cell>', of, ovt, val, txt);
        endif
        ++jj;
      endwhile
    endif
    ## Write table row closing tag
    fprintf (fid, '</table:table-row>');
    ++ii;
  endwhile

  ## 5. Closing tag
  fprintf (fid, '</table:table>');

  status = 1;

endfunction
