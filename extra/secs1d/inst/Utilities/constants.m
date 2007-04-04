
Kb           = 1.3806503e-23;
q            = 1.602176462e-19;
e0           = 8.854187817e-12;
esir 	     = 11.7;
esio2r 	     = 3.9;
esi 	     = e0 * esir;
esio2 	     = e0 * esio2r;
hplanck	     = 6.626e-34;
hbar         = ( hplanck/ (2*pi));
mn0          = 9.11e-31;
mn           = 0.26*mn0;
mh           = 0.18*mn0;


qsue         = q / esi;
T0           = 300 ;
Vth 	     = Kb * T0 / q;
un           = 1417e-4;
up           = 480e-4;
tp           = 1e-7;
tn           = 1e-7;

mnl          = 0.98*mn0;
mnt          = 0.19*mn0;
mndos        = (mnl*mnt*mnt)^(1/3); 

mhh             = 0.49*mn0;
mlh             = 0.16*mn0;
mhdos           = (mhh^(3/2)+mlh^(3/2))^(2/3);

rn              = .1;
aleph           = hbar^2/(4*rn*q*mn);
alephn          = aleph;
rp              = .1;
alephp          = hbar^2/(4*rp*q*mh);

Nc              = (6/4)*(2*mndos*Kb*T0/(hbar^2*pi))^(3/2);   
Nv              = (1/4)*(2*mhdos*Kb*T0/(hbar^2*pi))^(3/2);
Eg0             = 1.16964*q;
alfaEg          = 4.73e-4*q;
betaEg          = 6.36e2;
Egap            = Eg0-alfaEg*((T0^2)/(T0+betaEg));

ni              = sqrt(Nc*Nv)*exp(-Egap/(2*(Kb * T0)));
Phims           = - Egap /(2*q);


## This file is part of 
##
## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
## -------------------------------------------------------------------
## Copyright (C) 2004-2007  Carlo de Falco
##
##
##
##  SECS1D is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  SECS1D is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with SECS1D; if not, write to the Free Software
##  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
##  USA

% Last Revision:
% $Author$
% $Date$

