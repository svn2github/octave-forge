function [num,status] = str2double(s,cdelim,rdelim)
## STR2DOUBLE converts strings into numeric values
##    [NUM, STATUS] = STR2DOUBLE(STR) 
##  
##    STR can be the form '[+-]d[.]dd[[eE][+-]ddd]' 
##	d can be any of digit from 0 to 9, [] indicate optional elements
##    NUM is the corresponding numeric value. 
##       if the conversion fails, status is -1 and NUM is NaN.  
##    STATUS = 0: conversion was successful
##    STATUS = -1: couldnot convert string into numeric value
##
##    STR can also contain multiple elements.
##    Row-delimiters are: 
##        NEWLINE, CARRIAGE RETURN and SEMICOLON i.e. ASCII 10, 13 and 59. 
##    Column-delimiters are: 
##        TAB, SPACE and COMMA i.e. ASCII 9, 32, and 44.
##    Elements which are not defined or not valid return NaN and 
##        the STATUS becomes -1 
##    STR can be also a character array or a cell array of strings.   
##        Then, NUM and STATUS return matrices of appropriate size. 
##
##    Examples: 
##	str2double('-.1e-5')
##	   ans = -1.0000e-006
##
## 	str2double('.314e1, 44.44e-1, .7; -1e+1')
##	ans =
##	    3.1400    4.4440    0.7000
##	  -10.0000       NaN       NaN
##
##	line ='200,300,400,cd,yes,no,999,maybe,NaN';
##	[x,status]=str2double(line)
##	x =
##	   200   300   400   NaN   NaN   NaN   999   NaN   NaN
##	status =
##	   0   0   0  -1  -1  -1   0  -1   0


## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

##	$Id$
##	Copyright (C) 2004 by Alois Schloegl
##	a.schloegl@ieee.org	


%%valid_char='0123456789eE+-.nNaAiIfF';	% digits, sign, exponent,NaN,Inf
cdelim = char([9,32,abs(',')]);		% column delimiter
rdelim = char([0,10,13,abs(';')]);	% row delimiter

if iscell(s),
        strarray = s;
elseif ischar(s) & all(size(s)>1),	%% char array transformed into a string. 
        strarray = cellstr(s);
elseif ischar(s),
        num = [];
        status = 0;
        strarray = {};
        
        k1 = 0; % current row
        nc = 0;	% number of columns 
        while ~isempty(s),
                [u,s] = strtok(s,rdelim);	%% get next row 
                if isempty(u), return; end;
                k1 = k1 + 1;
                k2 = 0;
                
                while ~isempty(u),
                        [t,u] = strtok(u,cdelim);	%% get next element
                        if ~isempty(t),
                                k2 = k2 + 1;
                                if k2 > nc,			%% add column if neccessary
                                        nc = k2;
                                end;
                                strarray{k1,k2} = t;
                        end;
                end; 
        end;
else
        error('invalid input argument');
end;

[nr,nc]= size(strarray);
status = zeros(nr,nc);
num    = repmat(NaN,nr,nc);

for k1=1:nr,
for k2=1:nc,
        t = strarray{k1,k2};
        epos=find((t=='e') | (t=='E'));		%% positon of E 
        if (length(epos)>1), 			%% if more than one E is found 
		status(k1,k2) = -1;		%% return error code
        else				
                if length(epos)==0, 		%% no E found 
                        e = 0;
                        epos = length(t)+1;	
                elseif (length(epos)==1), 	%% one E found
                        l = epos+1;
                        if ~any(t(length(t))=='0123456789'); %last character must be a digit
                                e = nan;
                                status(k1,k2) = -1;
                        else
                                % get exponent
                                v = 0;
                                g = 1;
                                if t(l)=='-',
                                        g = -1; l = l+1;
                                elseif t(l)=='+',
                                        l = l+1;
                                end;
                                while l <= length(t),
                                        if any(t(l)=='0123456789');
                                                v = v*10 + t(l) - '0';        
                                        else
                                                v = nan;        
		                                status(k1,k2) = -1;
                                        end;
                                        l = l+1;
                                end;
                                e = g*v;
                        end;
                end;
                
                %% get mantisse
                g = 0;
                v = 1;
                if t(1)=='-',
                        v = -1; 
                        l = min(2,length(t));
                elseif t(1)=='+',
                        l = min(2,length(t));
                else
                        l = 1;
                end;

                if strcmpi(t(l:epos-1),'inf')
                        v = v*inf;
                        
                elseif strcmpi(t,'NaN');
                        v = NaN;
                        
                elseif all(sum(t(1:epos-1)=='.')<[2,epos-1]), 	% at most one dot, and at least one digit is needed 
                        p = 0;
                        while l < epos,
                                if any(t(l)=='0123456789');
                                        g = g*10 + t(l) - '0';        
                                elseif t(l)=='.',
                                        p = epos - 1 - l;
                                else
                                        v = nan;        
					status(k1,k2) = -1;
                                end;
                                l = l+1;        
                        end;
                        v = g*v*10^(e-p);
                else
			status(k1,k2) = -1;
                        v = NaN;
                end;
                num(k1,k2) = v;
	end;
end;
end;        
