%% Copyright (c) 2011, INRA
%% 2010-2011, David Legland <david.legland@grignon.inra.fr>
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
%% @deftypefn {Function File} angles2d ()
%% ANGLES2D  Description of functions for manipulating angles
%%
%%   Angles are normalized in an interval of width 2*PI. Most geom2d
%%   functions return results in the [0 2*pi] interval, but it can be
%%   convenient to consider the [-pi pi] interval as well. See the
%%   normalizeAngle function to switch between conventions.
%%
%%   Angles are usually oriented. The default orientation is the CCW
%%   (Counter-Clockwise) orientation.
%% 
%% @seealso{angle2Points, angle3Points, angleAbsDiff, normalizeAngle, vectorAngle,
%%          angleDiff, angleSort, lineAngle, edgeAngle, deg2rad, rad2deg}
%% @end deftypefn

function angles2d

  help('angles2d');

endfunction
