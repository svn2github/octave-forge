%% Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    (at your option) any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{q3} = } quatprod (@var{q1}, @var{q2})
%% Product of two quaternions.
%% @end deftypefn

function q3 = quatprod (q1,q2)

q3 = [ q1(:,1).*q2(:,1) - q1(:,2).*q2(:,2) - q1(:,3).*q2(:,3) - q1(:,4).*q2(:,4) ...
       q1(:,1).*q2(:,2) + q1(:,2).*q2(:,1) + q1(:,3).*q2(:,4) - q1(:,4).*q2(:,3) ...
       q1(:,1).*q2(:,3) - q1(:,2).*q2(:,4) + q1(:,3).*q2(:,1) + q1(:,4).*q2(:,2) ...
       q1(:,1).*q2(:,4) + q1(:,2).*q2(:,3) - q1(:,3).*q2(:,2) + q1(:,4).*q2(:,1) ];

endfunction
