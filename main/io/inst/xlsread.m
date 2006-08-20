function [num,strarray] = xlsread(fn)
%% XLSREAD reads EXCEL-files. 
%% Currently, only a hack to read excel tables is implemented.  
%% First, you need to convert your excel table into a tab-delimited 
%% text file. Then you can use XLSREAD to load that file. 
%%
%%  [NUM, STR] = XLSREAD(filename) 
%%      filename        tab-delimited text file
%%      NUM contains numeric data
%%      STR contains textual data
%%      
%% see also: STR2DOUBLE
%%
%% Reference(s): 
%%

%% This program is free software; you can redistribute it and/or
%% modify it under the terms of the GNU General Public License
%% as published by the Free Software Foundation; either version 2
%% of the License, or (at your option) any later version.
%% 
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%% 
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

%%	$Revision$
%%	$Id$
%%	Copyright (C) 2004 by Alois Schloegl <a.schloegl@ieee.org>	
%%      This function is part of Octave-Forge http://octave.sourceforge.net/


fid = fopen(fn,'rb','ieee-le');
if fid<0,
	fprintf(2,'Error XLSREAD: file %s not found\n',fn);
	return;
end

s   = fread(fid, [1,inf], 'uchar');
	

if ~any(s<9),
	fclose(fid);

	ddelim = '.';	% decimal delimiter 
	if sum(s==abs('.')) < sum(s==abs(',')),
		ddelim = ',';
		fprintf(1,'XLSREAD: decimal delimiter , assumed\n');
	end;	
	
	[num,status,strarray] = str2double(char(s),9,[10,13],ddelim);
	for k=1:length(status(:)),
    	        if ~status(k),
    		        strarray{k}=[];
    	        end;
	end;

else  %if 1,	% BIFF file 
        fprintf(2,'Error XLSREAD: reading EXCEL-file (BIFF-Format) not implemented yet.\n You need to convert file into a Tab-delimited text file first.\n');

	fseek(fid,0,'bof'); 
	if all(s(1:2)==[9,0]), 		% BIFF 2
	elseif all(s(1:2)==[9,2]), 	% BIFF 3
	elseif all(s(1:2)==[9,4]), 	% BIFF 4
	else 		% BIFF 5,7,8
		ix = min(find(s==9));
	end;	
	
	while ~feof(fid),
		tmp = fread(fid,2,'uint16');
		tag = tmp(1);
		len = tmp(2);
		tmp = fread(fid,len,'uint8');
	end;   
	fclose(fid);
end;	
	


