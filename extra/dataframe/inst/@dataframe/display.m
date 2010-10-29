function resu = display(df)

  %# function resu = display(df)
  %# Tries to produce a nicely formatted output of a dataframe.

  %% Copyright (C) 2009-2010 Pascal Dupuis <Pascal.Dupuis@uclouvain.be>
  %%
  %% This file is part of Octave.
  %%
  %% Octave is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 2, or (at your option) any later version.
  %%
  %% Octave is distributed in the hope that it will be useful,
  %% but WITHOUT ANY WARRANTY; without even the implied
  %% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  %% PURPOSE.  See the GNU General Public License for more
  %% details.
  %%
  %% You should have received a copy of the GNU General Public
  %% License along with Octave; see the file COPYING.  If not,
  %% write to the Free Software Foundation, 59 Temple Place -
  %% Suite 330, Boston, MA 02111-1307, USA.
  
  %#
  %# $Id$
  %#

%# generate header name
if 2 == length(df._cnt),
  head = sprintf("Dataframe with %d rows and %d columns", df._cnt);
else
  head = sprintf("Dataframe with %d rows and %d columns (%d unfolded)", ...
		 df._cnt);
endif
if all(df._cnt > 0), %# stop for empty df
  vspace = repmat(' ', df._cnt(1), 1);
  indi = 1; %# the real, unfolded index
  %# loop over columns where the corresponding _data really exists
  for indc = 1:min(df._cnt(2), size(df._data, 2)), 
    %# emit column names and type
    if 1 == size(df._data{indc}, 2),
      dummy{1, 2+indi} = deblank(disp(df._name{2}{indc}));
      dummy{2, 2+indi} = deblank(df._type{indc});
    else
      %# append a dot and the third-dimension index to column name
      tmp_str = [deblank(disp(df._name{2}{indc})) "."];
      tmp_str = arrayfun(@(x) horzcat(tmp_str, num2str(x)), ...
			 (1:size(df._data{indc}, 2)), 'UniformOutput', false); 
      dummy{1, 2+indi} = tmp_str{1};
      dummy{2, 2+indi} = deblank(df._type{indc});
      indk = 1; while indk < size(df._data{indc}, 2),
	dummy{1, 2+indi+indk} = tmp_str{1+indk};
	dummy{2, 2+indi+indk} = dummy{2, 2+indi};
	indk = indk + 1;
      endwhile
    endif
    %# "print" each column
    switch df._type{indc}
      case {'char'}
	indk = 1; while indk <= size(df._data{indc}, 2),
	  tmp_str = df._data{indc}(:, indk); %#get the whole column
	  indj = cellfun('isprint', tmp_str, 'UniformOutput', false); 
	  indj = ~cellfun('all', indj);
	  for indr = 1:length(indj),
	    if indj(indr),
	      if isna(tmp_str{indr}),
		tmp_str{indr} = "NA";
	      else
		tmp_str{indr} = undo_string_escapes(tmp_str{indr});
	      endif
	    endif
	  endfor
	  %# keep the whole thing, and add a vertical space
	  dummy{3, 2+indi} = disp(char(tmp_str));
	  dummy{3, 2+indi} = horzcat...
	      (vspace, char(regexp(dummy{3, 2+indi}, '.*', ...
				   'match', 'dotexceptnewline')));
	  indi = indi + 1; indk = indk + 1;
	endwhile
      otherwise
	%# keep only one horizontal space per line
	indk = 1; while indk <= size(df._data{indc}, 2),
	  dummy{3, 2+indi} = disp(df._data{indc}(:, indk));
	  tmp_str = char(regexp(dummy{3, 2+indi}, ' \S.*', ...
				'match', 'dotexceptnewline'));
	  if size(tmp_str, 1) < df._cnt(1),
	    tmp_str = horzcat...
		(vspace, char(regexp(dummy{3, 2+indi}, '\S.*', ...
				     'match', 'dotexceptnewline')));
	  endif
	  dummy{3, 2+indi} = tmp_str;
	  indi = indi + 1; indk = indk + 1;
	endwhile
    endswitch
  endfor

  vspace = [' '; ' '; vspace];
  %# second line content
  if 1 == size(df._ridx, 2),
    dummy{2, 1} = ["_"; "Nr"];
    dummy{3, 1} = disp(df._ridx(:)); 
    indi = regexp(dummy{3, 1}, '\b.*\b', 'match', 'dotexceptnewline');
    resu = strjust(char(dummy{2, 1}, indi), 'right');
  else
    resu = [];
    for indi = 1:size(df._ridx, 2)-1,
      dummy{2, 1} = [["_." num2str(indi)]; "Nr"];
      dummy{3, 1} = disp(df._ridx(:, indi)); 
      indj = regexp(dummy{3, 1}, '\b.*\b', 'match', 'dotexceptnewline');
      resu = horzcat(resu, strjust(char(dummy{2, 1}, indj), 'right'), vspace);
    endfor
    dummy{2, 1} = [["_." num2str(indi+1)]; "Nr"];
    dummy{3, 1} = disp(df._ridx(:, end)); 
    indj = regexp(dummy{3, 1}, '\b.*\b', 'match', 'dotexceptnewline');
    resu = horzcat(resu, strjust(char(dummy{2, 1}, indj), 'right'));
  endif
  %# emit row names
  if isempty(df._name{1}),
    dummy{2, 2} = []; dummy{3, 2} = [];
  else
    dummy{2, 2} = [" ";" "];
    dummy{3, 2} = df._name{1};
  endif
  
  if size(dummy, 2) > 1,
    %# resu contains the ridx
   
    %# insert a vertical space
    if !isempty(dummy{3, 2}),
      indi = ~cellfun('isempty', dummy{3, 2});
      if any(indi),
	resu = horzcat(resu, vspace);
	resu = horzcat(resu, strjust(char(dummy{2, 2}, dummy{3,2}), 'right'));
      endif
    endif
    
    %# emit each colum
    for indi = 1: size(dummy, 2) - 2,
      %# was max(df._cnt(2:end)),
      try
	%# avoid this column touching the previous one
	if any(cellfun('size', dummy(1:2, 2+indi), 2) >= ...
	       size(dummy{3, 2+indi}, 2)),
	  resu = horzcat(resu, vspace);
	endif
	resu = horzcat(resu, strjust(char(dummy{:, 2+indi}), 'right'));
      catch
	tmp_str = sprintf("Emitting %d lines, expecting %d", ...
			  size(dummy{3, 2+indi}, 1), df._cnt(1));
	error(tmp_str);
      end_try_catch
    endfor
  else
    resu = '';
  endif
else
  resu = '';
endif

resu = char(head, resu); disp(resu)


