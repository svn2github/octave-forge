%% Copyright (c) 2011, INRA
%% 2006-2011, David Legland <david.legland@grignon.inra.fr>
%% 2011 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%% All rights reserved.
%% (simplified BSD License)
%%
%% Redistribution and use in source and binary forms, with or without
%% modification, are permitted provided that the following conditions are met:
%%
%% 1. Redistributions of source code must retain the above copyright notice, this
%%    list of conditions and the following disclaimer.
%%     
%% 2. Redistributions in binary form must reproduce the above copyright notice, 
%%    this list of conditions and the following disclaimer in the documentation
%%    and/or other materials provided with the distribution.
%%
%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
%% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%% POSSIBILITY OF SUCH DAMAGE.
%%
%% The views and conclusions contained in the software and documentation are
%% those of the authors and should not be interpreted as representing official
%% policies, either expressed or implied, of copyright holder.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{b} = } isPerpendicular (@var{v1}, @var{v2})
%% @deftypefnx {Function File} {@var{b} = } isPerpendicula (@var{v1}, @var{v2},@var{tol})
%% heck orthogonality of two vectors.
%%
%%   @var{v1} and @var{v2} are 2 row vectors of length Nd, Nd being the dimension, 
%%   returns @code{true} if the vectors are perpendicular, and @code{false} otherwise.
%%
%%   Also works when @var{v1} and @var{v2} are two [NxNd] arrays with same number of
%%   rows. In this case, return a [Nx1] array containing @code{true} at the positions
%%   of parallel vectors.
%%
%%   @var{tol} specifies the accuracy of numerical computation. Default value is 1e-14.
%%
%%   Example
%%
%% @example
%   isPerpendicular([1 2 0], [0 0 2])
%%   ans = 
%%     1
%   isPerpendicular([1 2 1], [1 3 2])
%%   ans = 
%%     0
%% @end example
%%
%%   @seealso{vectors2d, isParallel, lines2d}
%% @end deftypefn

%% FIXME or erase me
%%   Also works when one of @var{v1} or @var{v2} is scalar and the other one is [NxNd]
%%   array, in this case return [Nx1] results.

function b = isPerpendicular(v1, v2, varargin)

  % default accuracy
  acc = 1e-14;
  if ~isempty (varargin)
      acc = abs (varargin{1});
  end

  % adapt size of inputs
  n1 = size (v1, 1);
  n2 = size (v2, 1);
  if n1~=n2
      if n1==1
          v1 = v1(ones (n2, 1), :);
      elseif n2==1
          v2 = v2(ones (n1, 1), :);
      else
          error('Inputs must either have same size, or one must be scalar');
      end
  end

  % performs test
  b = abs (dot (v1, v2, 2)) < acc;

endfunction

%!assert (isPerpendicular ([1 2 0], [0 0 2]))
%!assert (!isPerpendicular([1 2 1], [1 3 2]))
%!error (isPerpendicular(1, rand(4,3)))

