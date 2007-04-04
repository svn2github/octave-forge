function SG=Uscharfettergummel(mesh,v,acoeff)

%
% SG=Ufastscharfettergummel(mesh,v,acoeff)
% 
%
% Builds the Scharfetter-Gummel  matrix for the 
% the discretization of the LHS 
% of the Drift-Diffusion equation:
%
% $ -\div (a(x) (\grad u -  u \grad v'(x) ))= f $
%
% where a(x) is piecewise constant
% and v(x) is piecewise linear, so that 
% v'(x) is still piecewise constant
% b is a constant independent of x
% and u is the unknown
%


% This file is part of 
%
%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004-2006  Carlo de Falco
%
%
%
%  SECS2D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  SECS2D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with SECS2D; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%  USA


Nnodes = length(mesh.p);
Nelements = length(mesh.t);

%%fprintf(1,'*--------------------*\n');
%%fprintf(1,'building SG Matrix\n*');

areak   = reshape (sum( mesh.wjacdet,1),1,1,Nelements);
shg     = mesh.shg(:,:,:);
M       = reshape (acoeff,1,1,Nelements);	


% build local (+)Laplacian matrix	
Lloc=zeros(3,3,Nelements);	
for inode=1:3
  for jnode=1:3

    ginode(inode,jnode,:)=mesh.t(inode,:);
    gjnode(inode,jnode,:)=mesh.t(jnode,:);
    Lloc(inode,jnode,:) = M .* sum( shg(:,inode,:) .* shg(:,jnode,:),1) .* areak;
    
    %%fprintf(1,'-');
          
  end
end		

vloc = v(mesh.t(1:3,:));
[bp12,bm12] = Ubern(vloc(2,:)-vloc(1,:));
[bp13,bm13] = Ubern(vloc(3,:)-vloc(1,:));
[bp23,bm23] = Ubern(vloc(3,:)-vloc(2,:));

bp12 = reshape(bp12,1,1,Nelements).*Lloc(1,2,:);
bm12 = reshape(bm12,1,1,Nelements).*Lloc(1,2,:);
bp13 = reshape(bp13,1,1,Nelements).*Lloc(1,3,:);
bm13 = reshape(bm13,1,1,Nelements).*Lloc(1,3,:);
bp23 = reshape(bp23,1,1,Nelements).*Lloc(2,3,:);
bm23 = reshape(bm23,1,1,Nelements).*Lloc(2,3,:);

SGloc(1,1,:) = -bm12-bm13;
SGloc(1,2,:) = bp12;
SGloc(1,3,:) = bp13;

SGloc(2,1,:) = bm12;
SGloc(2,2,:) = -bp12-bm23; 
SGloc(2,3,:) = bp23;

SGloc(3,1,:) = bm13;
SGloc(3,2,:) = bm23;
SGloc(3,3,:) = -bp13-bp23;

%%SGloc=[-bm12-bm13,   bp12     ,   bp13
	 %%        bm12     ,  -bp12-bm23,   bp23
	 %%        bm13     ,   bm23     ,  -bp13-bp23];

%%fprintf(1,'-');

SG = sparse(ginode(:),gjnode(:),SGloc(:));
%%fprintf(1,'--*\nDONE!\n\n\n');


