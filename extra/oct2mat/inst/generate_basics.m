function []=generate_basics(p)
% GENERATE_BASICS generates basic functions for freetb4matlab 
%   These are needed by several Octave functions converted with Oct2Mat

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

% $Id$
% Copyright (C) 2010 by Alois Schloegl <a.schloegl@ieee.org>
% This is part of Octave-Forge's Oct2Mat

f = {'arg',     'function phi = arg(x)\n  phi = angle(x);'; ...
     'rows',    'function n = rows(x)\n  n = size(x,1);'; ...
     'columns', 'function n = columns(x)\n  n = size(x,2);'; ...
     'tolower', 'function n = tolower(x)\n  n = lower(x);'; ...
     'toupper', 'function n = toupper(x)\n  n = upper(x);'; ...
     'toascii', 'function n = toascii(x)\n  n = abs(x);'; ...
     'vec',     'function x = vec(x)\n  x = x(:);'; ...
     'rindex',  'function x = rindex(s,t)\n  idx = findstr(s,t);\n  if isempty(idx), x = 0;\n  else x = idx(end); end'; ... 
     'substr',  'function y = substr(s,i,j)\n  if i<0, i=length(s)+i+1; end;\n  if nargin<3, y = s(i:end);\n  else y = s(i:i+j-1); end'; ...
     'file_in_loadpath',  'function name=file_in_loadpath(file)\n   name=file_in_path(path,file);' ...
    };

if nargin<1,
        p = fileparts(mfilename);
end;        
for k = 1:size(f,1),
        fn = fullfile(p,[f{k,1},'.m']);
        fid = fopen(fn,'w');
        if fid<0,
                fprintf(1,'Warning: file %s could not be generated\n',fn);
                continue;
        end;         
        fprintf(fid,'%% %s - has been generated by OCT2MAT for providing compatibility with Octave functions\n',upper(f{k,1}));
        fprintf(fid,f{k,2});
        fclose(fid); 
end;