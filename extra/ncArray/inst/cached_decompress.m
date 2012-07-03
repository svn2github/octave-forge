% [fname,success]=cached_decompress(filename)
%
% Decompress a file if it is not already in cache
%
% Input:
%  filename: name of the file which is possibly compressed
%
% Output:
%  fname: the filename of the uncompressed file
%

% Alexander Barth, 2012-06-13
%


function [fname]=cached_decompress(url)
global CASHED_GUNZIP_DIR
global CASHED_GUNZIP_LOG_FID


cache_dir = CASHED_GUNZIP_DIR;
if isempty(cache_dir)
%    cache_dir = fullfile(getenv('HOME'),'tmp','Cache');
    cache_dir = fullfile(getenv('HOME'),'tmp','Cache');
end


if endswith(url,'.gz') || endswith(url,'.bz2')
    if exist(cache_dir,'dir') ~= 7
        error(['cache directory for compressed files does not exist. '...
            'Please create the directory %s or change le value of the '...
            'global variable CASHED_GUNZIP_DIR'],cache_dir);
    end
else
    fname = url;
    return    
end
    
% where to print logs? default to screen

fid=CASHED_GUNZIP_LOG_FID;

if (isempty(fid))
    fid=1;
end

% form filename for cache

fname = url;
fname = strrep(fname,'/','_SLASH_');
fname = strrep(fname,'*','_STAR_');
fname = fullfile(cache_dir,fname);

% test if in cache

if exist(fname,'file') ~= 2
    if endswith(url,'.gz')
        syscmd('gunzip --stdout "%s" > "%s"',url,fname);
    else
        syscmd('bunzip2 --stdout "%s" > "%s"',url,fname);
    end    
else
%    fprintf(fid,'retrieve from cache %s\n',url);
end

% check cache size

d=dir(cache_dir);
cashe_size = sum([d.bytes]);
max_cache_size = 1e10;

if (cashe_size > max_cache_size)
    
    % look for oldest files
    fdate = zeros(1,length(d));
    for i=1:length(d);
        fdate(i) = datenum(d(i).date);
    end
    
    [fdate,index] = sort(fdate,'descend');
    d=d(index);
    
    cum_size = cumsum([d(:).bytes]);
    todelete = find(cum_size > max_cache_size);
    
    for i=todelete
        if (d(i).isdir == 0)
            fprintf(fid,'clean cashe: delete %s\n', d(i).name);
            delete(fullfile(cache_dir,d(i).name));
        end
    end
end
end

function t = endswith(s,ext)

if length(ext) <= length(s)
    t = strcmp(s(end-length(ext)+1:end),ext);
else
    t = 0;
end
end


function syscmd(varargin)

cmd = sprintf(varargin{:});
%disp(cmd)
status = 0;
[status, output] = system(cmd);

disp(output);
if status ~= 0
  error(['command "' cmd '" failed: ' output]);
end
end


% Copyright (C) 2012 Alexander Barth <barth.alexander@gmail.com>
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
% along with this program; If not, see <http://www.gnu.org/licenses/>.

