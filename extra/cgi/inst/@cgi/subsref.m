%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{val} =} subsref(@var{cgi},@var{idx})
%% @deftypefnx {Function File} {@var{val} =} getfirst(@var{cgi},@var{name},@var{default})
%% Return CGI parmaters with cgi.form.name or cgi.form.('name').
%% The object @var{cgi} was 
%% created using the cgi() constructor.
%% @end deftypefn
%% @seealso{cgi}



function val = subsref(self,idx)

assert(length(idx) == 2)
assert(strcmp(idx(1).type,'.'))
assert(strcmp(idx(1).subs,'form'))
assert(strcmp(idx(2).type,'.'))

val = getfirst(self,idx(2).subs);


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