function FLAG_NANS_OCCURED=flag_nans_occured()
% The use of FLAG_NANS_OCCURED is in experimental state. 
%
% FLAG_NANS_OCCURED checkes whether the last call to sumskipnan 
% contained any not-a-numbers in the input argument. Because many other 
% functions like mean, std, etc. are also using sumskipnan, 
% also these functions can be checked for NaN's in the input data. 
%
% see also: SUMSKIPNAN

%	$Id$
%	Copyright (C) 2009 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://hci.tu-graz.ac.at/~schloegl/matlab/NaN/

%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

global FLAG_NANS_OCCURED;

%%% check whether FLAG was already defined 
if ~exist('FLAG_NANS_OCCURED','var'),
	FLAG_NANS_OCCURED = 0;  % default value 
end;
if isempty(FLAG_NANS_OCCURED),
	FLAG_NANS_OCCURED = 0;  % default value 
end;

return;
