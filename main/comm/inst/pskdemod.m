## Copyright (C) 2006 Charalampos C. Tsimenidis
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
##

## usage: y = pskdemod (x, M, [phi, [type]])
##
## Demodulates a complex-baseband phase shift keying modulated signal 
## into an information sequence of intergers in the range [0..M-1]. 
## phi controls the initial phase and type ('Bin' or 'Gray') controls 
## the symbol ordering that was used for encoding.
##
## EXAMPLE: Demodulation of Gray-encoded 8-PSK 
##
##	d=randint(1,1e3,8);
##	y=pskmod(d,8,0,'Gray');
##	z=awgn(y,20);
##	d_est=pskdemod(z,8,0,'Gray');
##	plot(z,'rx')
##	biterr(d,d_est)
##

function y=pskdemod(x,M,phi,type)

if nargin<2
	usage("y = pskdemod (x, M, [phi, [type]])");   
endif    

if nargin<3
	phi=0;
endif

if nargin<4
	type="Bin";
endif

m=0:M-1;
index=mod(round((arg(x)-phi)*M/2/pi),M)+1;

if (strcmp(type,"Bin")||strcmp(type,"bin"))
        y=index-1;
elseif (strcmp(type,"Gray")||strcmp(type,"gray"))
	map=bitxor(m,bitshift(m,-1));
	y=map(index);
else
    usage("y = pskdemod (x, M, [phi, [type]])");   
endif

%!assert (pskdemod([1 j -1 -j],4,0,'Bin'),[0:3])
%!assert (pskdemod([1 j -j -1],4,0,'Gray'),[0:3])
