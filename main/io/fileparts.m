function [p,f,e]=fileparts(fn)
## FILEPARTS separates the parts of the filename
##  [PATH,FILE,EXT]=FILEPARTS(FN)
## 
## The filename FN can be reconstructed by [PATH,FILE,EXT]

##	Version 1.00  Date: 03 Jan 2003
##	CopyLeft (C) 2002-2003 by Alois Schloegl
##	a.schloegl@ieee.org	


ix1=max(find(fn==filesep));
ix2=max(find(fn=='.'));

if isempty(ix1), ix1 = 0; end;
if isempty(ix1), ix1 = length(fn); end;

p = fn(1:ix1);
f = fn(ix1+1:ix2-1);
e = fn(ix2:length(fn));



