% TEST_FSS test of fss.m 

%	$Id$
%	Copyright (C) 2009,2010 by Alois Schloegl <a.schloegl@ieee.org>	
%       This function is part of the NaN-toolbox
%       http://hci.tu-graz.ac.at/~schloegl/matlab/NaN/

% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3
% of the  License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

clear 
if ~exist('ue6.mat','file')	
	if strncmp(computer,'PCWIN',5)
		fprintf(1,'Download http://hci.tugraz.at/~schloegl/LV/SMBS/UE6/ue6.mat and save in local directory %s\nPress any key to continue ...\n',pwd);
		pause;
	else 	
		unix('wget http://hci.tugraz.at/~schloegl/LV/SMBS/UE6/ue6.mat'); 
	end; 	
end
load ue6; 

N = 50;   % select N highest ranked features
[ix,score] = fss(data, C, N);


%% compute cross-validated result; 
for k=1:N
        R{k}=xval(data(:,ix(1:k)),C);
        ACC(k)=R{k}.ACC;
end


%% display 
plot(ACC*100); 
set(gca,'YLim',[0,100])
ylabel('Accuracy [%]')
title('selection of N out of 2540 features')

ix,
