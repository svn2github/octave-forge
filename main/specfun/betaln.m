%% Copyright (C) 1998 by Nicol N. Schraudolph
%%
%% This program is free software; you can redistribute and/or
%% modify it under the terms of the GNU General Public
%% License as published by the Free Software Foundation;
%% either version 2, or (at your option) any later version.
%%
%% This program is distributed in the hope that it will be
%% useful, but WITHOUT ANY WARRANTY; without even the implied
%% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
%% PURPOSE.  See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public
%% License along with Octave; see the file COPYING.  If not,
%% write to the Free Software Foundation, 59 Temple Place -
%% Suite 330, Boston, MA 02111-1307, USA.

%% usage: betaln(a,b)
%%
%% Return the log of the beta function of a and b.
%%
%% See also: beta, betai, lgamma.

%% Author:   Nicol N. Schraudolph <nic@idsia.ch>
%% Created:  06 Aug 1998
%% Keywords: log beta special function

function ret = betaln(a,b)
    if (nargin != 2)
        usage('betaln requires two arguments')
    end
    ret = lgamma(a) + lgamma(b) - lgamma(a + b);
end

