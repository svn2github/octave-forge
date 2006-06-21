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

## usage: y = pamdemod (x, M, [phi, [type]])
##
## Demodulates a pulse amplitude modulated signal x into an information sequence 
## of intergers in the range [0..M-1]. phi controls the initial phase and type 
## ('Bin' or 'Gray') controls the symbol ordering that was used for encoding.
##
## EXAMPLE: Demodulation of Gray-encoded 8-PAM 
##
##	d=randint(1,1e4,8);
##	y=pammod(d,8,0,'Gray');
##	z=awgn(y,20);
##	d_est=pamdemod(z,8,0,'Gray');
##	plot(z,'rx')
##	biterr(d,d_est)
##
## See also: pammod

function y=pamdemod(x,M,phi,type)

if nargin<2
	usage("y = pamdemod (x, M, [phi, [type]])");   
endif    

if nargin<3
	phi=0;
endif

if nargin<4
	type="Bin";
endif

index=genqamdemod(x,[-M+1:2:M-1].*exp(-1j*phi));

if (strcmp(type,"Bin")||strcmp(type,"bin"))
        y=index;
elseif (strcmp(type,"Gray")||strcmp(type,"gray"))
	m=0:M-1;
	map=bitxor(m,bitshift(m,-1));
	y=map(index+1);
else
    usage("y = pamdemod (x, M, [phi, [type]])");   
endif

%!assert (pamdemod([-7:2:7],8,0,'Bin'),[0:7])
%!assert (pamdemod([-7:2:7],8,0,'Gray'),[0 1 3 2 6 7 5 4])
