function [R,X]=histo3(Y)
% Calculates histogram using optimal overall binwidth. 
% HIS=HISTO3(Y)
% 	HIS is a struct with th fields 
%       HIS.X  are the bin-values 
%       HIS.H  is the frequency of occurence of value X 
%  	HIS.N  are the number of valid (not NaN) samples 
%
% HISTO(Y) 
%	plots the histogram bar(X,H)
%
% more histogram-based results can be obtained by HIST2RES2  
%
% see also: HIST2RES2, HISTO
%
% REFERENCE(S):
%  C.E. Shannon and W. Weaver "The mathematical theory of communication" University of Illinois Press, Urbana 1949 (reprint 1963).

%          05.04.2002   docu modified
%  	   21.02.2002	major changes, single X for all channels
%  V 2.84  16.02.2002	minor bug fixed	
%  V 2.83  06.02.2002	
%  V 2.82  31.01.2002	AUTO changed to non-equidistant bins
%  V 2.75  30.08.2001	semicolon 
%          10.07.2001   Entropy of multiple channels fixed
%          04.05.2001   display improved
%  V 2.74  20.04.2001   bug fixed for case N==1, x =minY;
%          13.03.2001	scaling of x corrected
%  V 2.72  08.03.2001   third argin, specifies the number of bins
%          26.11.2000 	bug fixed (entropy calculation)
%  V 2.69  25.10.2000   revised (nan's are considered)
%  V 2.68  28.07.2000   revised
%  V 2.63  18.10.1999   multiple rows implemented
%          26.11.1999   bug fixed (size of H corrected);

%	Version 2.84
%	last revision 21 Feb 2002
%	Copyright (c) 1996-2002 by Alois Schloegl
%	e-mail: a.schloegl@ieee.org	

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
% Free Software Foundation, Inc., 59 Temple Place - Suite 330,
% Boston, MA  02111-1307, USA.

[yr,yc]=size(Y);
if yr==1,
        %make sure there is a second row
        % Due to a bug in SUM with DIM=1 for row vectors, 
        % this function would not work correctly with Octave
        % Once the bug is fixed, this part can be removed. 
        Y=[Y; NaN+ones(size(Y))];  
end;

% identify all possible X's and overall Histogram
sY  = sort(Y(:));
[ix,iy] = find(diff(sY,1)>0);
tmp = [ix; sum(~isnan(sY))];
H   = diff([0; tmp]);
X   = sY(tmp);
N   = sum(~isnan(Y),1);

% if yc==1, we are all set; else 
if yc>1,	% a few more steps are necessary
        H0 = H; %overall histogram	
        % allocate memory
        H = zeros(size(X,1),yc);
        
        % scan each channel
        for k=1:yc,
		sY = sort(Y(:,k));
		ix = find(diff(sY,1)>0);
                if size(ix,1)>0,
                        tmp = [ix; N(k)];
                else
                        tmp = N(k);
                end;
                
                t = 0;
                j = 1;
                for x = tmp',
                        acc = sY(x);
                        while X(j)~=acc, j=j+1; end;
                        %j = find(sY(x)==X);   % identify position on X 
                        H(j,k) = H(j,k) + (x-t);  % add diff(tmp)
                        t = x;
                end;
        end;
        
        if any(H0~=sum(H,2)),  %%% CHECK 
                fprintf(2,'ERROR HISTO\n');
        end;	
end;

if nargout == 0,
        if exist('OCTAVE_VERSION')<5
                bar(X,H,'stacked');
        else
                bar(X,H0);   % multidim H is not possible in OCTAVE 2.1.35
        end
        
elseif nargout==1,
        R.datatype = 'HISTOGRAM';
        R.H = H;
        R.X = X;
        R.N = N; %sumskipnan(H,1);
else
        R   = H;
end;

 