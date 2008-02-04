function [R,tix]=histo4(Y)
% HISTO4 calculates histogram for rows and supports data compression
%
% R = HISTO4(Y)
% 	R is a struct with th fields 
%       R.X  are the bin-values 
%       R.H  is the frequency of occurence of value X 
%  	R.N  are the number of samples 
%
% HISTO4 might be useful for data compression, because
% [R,tix] = histo4(Y) 
%     	is the compression step
% R.X(tix,:) 
%  	is the decompression step
%
% The effort (in memory and speed) for compression is O(n*log(n))
% The effort (in memory and speed) for decompression is only O(n)
% 
% see also: HISTO, HISTO2, HISTO3, HISTO4
%
% REFERENCE(S):
%  C.E. Shannon and W. Weaver "The mathematical theory of communication" University of Illinois Press, Urbana 1949 (reprint 1963).


%	$Id$
%	Copyright (C) 1996-2005 by Alois Schloegl <a.schloegl@ieee.org>	
%    	This is part of the TSA-toolbox 
%	http://www.dpmi.tugraz.at/~schloegl/matlab/tsa/

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 2 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Library General Public License for more details.
%
% You should have received a copy of the GNU Library General Public
% License along with this library; if not, write to the
% Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA  02110-1301, USA.


[yr, yc] = size(Y);
if yr==1,
        % Makes sure there is a second row
        % Sort does not support the DIM-argument, therefore,
        % this function would not work correctly with this software
        % Once this is fixed, this part can be removed. 
        Y = [Y; NaN+ones(size(Y))];  
end;


% identify all possible X's and overall Histogram
[Y,   idx] = sortrows(Y);
[tmp, idx] = sort(idx);        % inverse index

%[ix, iy] = (diff(Y,1)>0);
ix = logical(zeros(yr-1,1));
for k = 1:yr-1,
        ix(k) = any(Y(k,:)~=Y(k+1,:));
end;

tmp = [find(ix); yr];
R.H = diff([0; tmp]);
R.X = Y(tmp,:);
R.N = yr;
R.datatype = 'HISTOGRAM';

% generate inverse index
if nargout>1,
        tix = cumsum([1;ix]);	% rank 
        cc  = 1;
        tmp = sum(ix)+1;
	if 0, exist('OCTAVE_VERSION','builtin'),
		; % NOP; no support for integer datatyp 
        elseif tmp <= 2^8;
                tix = uint8(tix);
                cc = 8/1;
        elseif tmp <= 2^16;
                tix = uint16(tix);
                cc = 8/2;
        elseif tmp <= 2^32;
                tix = uint32(tix);
                cc = 8/4;
        end;
        tix = tix(idx);		% inverse sort rank
        
        R.compressionratio = (prod(size(R.X)) + yr/cc) / (yr*yc);
        R.tix = tix;
end;
