function o=std(i,opt,DIM)
% STD calculates the standard deviation.
% 
% y = std(x [, opt[, DIM]])
% 
% opt   option (not supported)
% DIM	dimension
%	1 STD of columns
%	2 STD of rows
% 	N STD of  N-th dimension 
%	default or []: first DIMENSION, with more than 1 element
%
% features:
% - can deal with NaN's (missing values)
% - dimension argument also in Octave
% - compatible to Matlab and Octave
%
% see also: RMS, SUMSKIPNAN, MEAN, VAR, MEANSQ,


%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%	$Revision$
%	$Id$
%	Copyright (c) 2000-2003 by Alois Schloegl <a.schloegl@ieee.org>	


if nargin<3,
        o=sqrt(var(i));
        if nargin==2,
                if ~isempty(opt) & opt~=0, 
                        fprintf(2,'Warning STD: OPTION not supported.\n');
                end;
        end;
else
        o=sqrt(var(i,opt,DIM));
end;   
