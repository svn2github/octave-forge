%% Copyright (c) 2010 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%% 
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{fileStr} =} data2geo (@var{data}, @var{lc},@var{opt})
%% Builds a file compatible with gmsh form data.
%%
%% @var{data} is assumed to describe a polygon in @code{polygon2d} format.
%%
%% @seealso{polygon2d}
%% @end deftypefn

function strFile = data2geo(data,lc,varargin)

    nl = @()sprintf('\n');

    %% Parse options
    filegiven = [];
    spherical = [];
    if nargin > 2
      filegiven = find(cellfun(@(x)strcmpi(x,'output'),varargin));
      spherical = find(cellfun(@(x)strcmpi(x,'spherical'),varargin));
    end

    [n dim] = size(data);
    if dim == 2
        data(:,3) = zeros(n,1);
    end

    header = ' // File created with Octave';
    strFile = [];
    strFile = [strFile header nl()];

    % Points
    strFile = [strFile '// Points' nl()];

    for i=1:n
        strFile = [strFile pointGeo(i,data(i,:),lc)];
    end

    % Lines
    strFile = [strFile '// Lines' nl()];
    for i=1:n-1
        strFile = [strFile lineGeo(i,i,i+1)];
    end
    strFile = [strFile lineGeo(n,n,1)];

    % Loop
    strFile = [strFile lineLoopGeo(n+1,n,1:n)];

    % Surface
    if spherical
        sphr = varargin{spherical+1};
        if dim ==2
            sphr(1,3) = 0;
        end
        strFile = [strFile pointGeo(n+1,sphr,lc)];
        strFile = [strFile ruledSurfGeo(n+3,1,n+1,n+1)];
    else
        strFile = [strFile planeSurfGeo(n+2,1,n+1)];
    end

    if filegiven
        outfile = varargin{filegiven+1};
        fid = fopen(outfile,'w');
        fprintf(fid,'%s',strFile);
        fclose(fid);
        disp(['DATA2GEO: Geometry file saved to ' outfile])
    end
end

%!demo
%! points  = [0 0 0; 0.1 0 0; 0.1 .3 0; 0 0.3 0];
%! strFile = data2geo(points,0.009);
%! disp(strFile)
