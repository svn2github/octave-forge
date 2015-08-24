% Create a derived array
%
% V = DerivedArray(function,{params})
%
% Example:
% Temp_in_C = DerivedArray(@(t) t-273.15,{Temp_in_K})
%
% see also ncArray
% Web: http://modb.oce.ulg.ac.be/mediawiki/index.php/ncArray


function retval = DerivedArray(fun,params)

self.fun = fun;
self.params = params;

retval = class(self,'DerivedArray',BaseArray(size(params{1})));






% Copyright (C) 2015 Alexander Barth <barth.alexander@gmail.com>
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

