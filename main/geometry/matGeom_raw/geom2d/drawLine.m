%% Copyright (c) 2011, INRA
%% 2007-2011, David Legland <david.legland@grignon.inra.fr>
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


function varargout = drawLine(lin, varargin)
%DRAWLINE Draw the line on the current axis
%
%   drawline(LINE);
%   Draws the line LINE on the current axis, by using current axis to clip
%   the line. 
%
%   drawline(LINE, PARAM, VALUE);
%   Specifies drawing options.
%
%   H = drawLine(...)
%   Returns a handle to the created line object. If clipped line is not
%   contained in the axis, the function returns -1.
%   
%   Example
%   figure; hold on; axis equal;
%   axis([0 100 0 100]);
%   drawLine([30 40 10 20]);
%   drawLine([30 40 20 -10], 'color', 'm', 'linewidth', 2);
%
%   See also:
%   lines2d, createLine, drawEdge
%
%   ---------
%   author : David Legland 
%   INRA - TPV URPOI - BIA IMASTE
%   created the 31/10/2003.
%

%   HISTORY
%   25/05/2004 add support for multiple lines (loop)
%   23/05/2005 add support for arguments
%   03/08/2010 bug for lines outside box (thanks to Reto Zingg)
%   04/08/2010 rewrite using clipLine

% default style for drawing lines
varargin = [{'color', 'b'}, varargin];

% extract bounding box of the current axis
xlim = get(gca, 'xlim');
ylim = get(gca, 'ylim');

% clip lines with current axis box
clip = clipLine(lin, [xlim ylim]);
ok   = isfinite(clip(:,1));

% initialize result array to invalide handles
h = -1*ones(size(lin, 1), 1);

% draw valid lines
h(ok) = line(clip(ok, [1 3])', clip(ok, [2 4])', varargin{:});

% return line handle if needed
if nargout>0
    varargout{1}=h;
end
