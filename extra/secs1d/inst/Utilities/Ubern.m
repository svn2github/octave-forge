function [bp,bn]=Ubern(x)

% [bp,bn]=Ubern(x)
%
% Bernoulli function
% bp = B(x)=x/(exp(x)-1)
% bn = B(-x)=x+B(x)


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

     
xlim=1e-2;
ax=abs(x);

%
% Calcola la funz. di Bernoulli per x=0
%

if (ax == 0)
   bp=1.;
   bn=1.;
   return
end;

%
% Calcola la funz. di Bernoulli per valori
% asintotici dell'argomento
%

if (ax > 80),
   if (x >0),
      bp=0.;
      bn=x;
      return
   else
      bp=-x;
      bn=0.;
      return
   end;
end;

%
% Calcola la funz. di Bernoulli per valori
% intermedi dell'argomento
%

if (ax > xlim),
   bp=x/(exp(x)-1);
   bn=x+bp;
   return
else

%
% Calcola la funz. di Bernoulli per valori
% piccoli dell'argomento mediante sviluppo
% di Taylor troncato dell'esponenziale
%
   ii=1;
   fp=1.;
   fn=1.;
   df=1.;
   segno=1.;
   while (abs(df) > eps),
     ii=ii+1;
     segno=-segno;
     df=df*x/ii;
     fp=fp+df;
     fn=fn+segno*df;
     bp=1./fp;
     bn=1./fn;
   end;
   return
end


% Last Revision:
% $Author$
% $Date$
