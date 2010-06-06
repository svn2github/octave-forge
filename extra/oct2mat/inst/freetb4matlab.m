function freetb4matlab(indir,outdir)
% freetb4matlab convert free toolboxes from Octave and Octave-forge  
% for the use in Matlab(TM). 
%
%  freetb4matlab(indir)
%  freetb4matlab(indir,[])
%    converts the directory indir and all its subdirectories  
%    and stores the result in ./freetb4matlab 
%
%  freetb4matlab(indir, outdir)
%    stores the resulting m-files in directory outdir
%
%  freetb4matlab('.', ...)
%    converts current directory (and all its subdirectories) 
%
%  freetb4matlab([], ...)
%  freetb4matlab('', ...)
%  freetb4matlab
%    convert the m-functions of octave 

%       $Id$
%       Copyright (C) 2009,2010 by Alois Schloegl <a.schloegl@ieee.org>
%       This is part of Octave-Forge's Oct2Mat
%
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

PWD = pwd;
if nargin<1, 
	indir=[];
end;	
if nargin<2, 
	outdir=[];
end;	
if isempty(outdir)
	outdir=fullfile(pwd,'freetb4matlab');
end; 

if isempty(indir)
	if exist('OCTAVE_VERSION','builtin');
		% heuristic to find octave toolboxes
		p = fileparts(which('help'));
		p = fileparts(p);
		freetb4matlab(p,outdir);
		return;
	else
		p = pwd;
	end;
end;

if ~exist(outdir,'dir')
	unix(['mkdir ',outdir]);
end;

global OCT2MAT_CMD
if isempty(OCT2MAT_CMD)
        % invoke only once
	p = fileparts(which('freetb4matlab'));
	OCT2MAT_CMD = [p, filesep,'oct2mat '];
	p0 = fullfile(outdir,'oct2mat'); 
        if ~exist(p0,'dir')
        	unix(['mkdir ',p0]);
        end;
	generate_basics(p0);
end; 

p0 = '/tmp/oct2mat';
if ~exist(p0,'dir')
	unix(['mkdir ',p0]);
end;

disp(indir);
cd(indir);

fn=dir(indir);
unix(['rm -rf ',p0,'/* ']);

for k=1:length(fn),
	f = fullfile(indir,fn(k).name);
	if (fn(k).name(1)=='.')
		;
	elseif (fn(k).name(end)=='~')
		;
	elseif fn(k).isdir,
		if strmatch(fn(k).name,{'freetb4matlab','language','admin','deprecated'},'exact')
			; % ignore these directories 
			; % some files conflict with (matlab-) functions used in this script 
			; % freetb4matlab is the default target directory, this would result in endless recursion
		elseif (fn(k).name(1)=='@')
			; % same as above
		elseif (isequal(fn(k).name,'doc') ...
			 || isequal(fn(k).name,'inst') ...
			 || isequal(fn(k).name,'src')  ...
			 || isequal(fn(k).name,'main')  ...
			 || isequal(fn(k).name,'extra') )
		 	%% pruning of directory tree
			freetb4matlab(f,outdir);
		elseif 0, ~exist('OCTAVE_VERSION','builtin') && any(strmatch(fn(k).name,{'general','string'},'exact'))
		        %% this is very slow
		        cmd = ['cd ',f,'; ',OCT2MAT_CMD,';']
		        unix(cmd);
		        cmd = ['cp /tmp/oct2mat ',fullfile(outdir,fn(k).name)]
		        unix(cmd); 
		        break;
		else
			freetb4matlab(f,fullfile(outdir,fn(k).name));
		end;

	elseif (fn(k).name(end)=='m') && (fn(k).name(end-1)=='.'),
		%disp(['cd ',indir ]);
		%disp([oct2mat fn(k).name]);
		unix(['cd ',indir ]);
		unix([OCT2MAT_CMD fn(k).name]);
		if (fn(k).name(1)=='_')
        		unix(['cp ',fullfile(p0,fn(k).name),' ',fullfile(outdir,['b2o_tmp_',fn(k).name])]);
		else
        		unix(['cp ',fullfile(p0,fn(k).name),' ',outdir]);
        	end;	

        elseif any(strfind(fn(k).name,'.o')==length(fn(k).name)-1) || any(strfind(fn(k).name,'.mex')==length(fn(k).name)-3) 
                ;         % skip *.o and *.mex files  

	else 
		%% copy all other files, too. They might contain information to fix some problems.
		unix(['cp ',f,' ',outdir]);
		fprintf(1,'DoNotConvert %s\n',fullfile(indir,fn(k).name));
	end; 		

end; 
unix(['rm -rf ',p0,'/* ']);

cd(PWD);
