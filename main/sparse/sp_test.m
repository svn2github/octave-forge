%!/usr/local/bin/octave -qf 
% Test script for the build of the octave sparse functions
%
% Copyright (C) 1998,1999 Andy Adler
% 
%    This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of
% the License, or (at your option) any later version.
%    This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%    You should have received a copy of the GNU General Public
% License along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
%
% $Id$

OCTAVE=  exist('OCTAVE_VERSION');
do_fortran_indexing= 1;
warn_fortran_indexing= 0;
prefer_zero_one_indexing= 0;
page_screen_output=1;
SZ=10;
NTRIES=1  ;

errortol= 1e-10;
res=zeros(1,300); % should be enough space

for tries = 1:NTRIES;

% print some relevant info from ps
if 0
   printf('t=%03d: %s', tries, system(['ps -uh ', num2str(getpid)],1 ) );
end

% choose some random sizes for the test matrices   
   sz=floor(abs(randn(1,5))*SZ + 1);
   sz1= sz(1); sz2=sz(2); sz3=sz(3); sz4=sz(4); sz5=sz(5);
   sz12= sz1*sz2;
   sz23= sz2*sz3;

% choose random test matrices
   arf=zeros( sz1,sz2 );
   nz= ceil(sz12*rand(1)/2+0);
   arf(ceil(rand(nz,1)*sz12))=randn(nz,1);

   brf=zeros( sz1,sz2 );
   nz= ceil(sz12*rand(1)/2+0);
   brf(ceil(rand(nz,1)*sz12))=randn(nz,1);

   crf=zeros( sz2,sz3 );
   nz= ceil(sz23*rand(1)/2+0);
   crf(ceil(rand(nz,1)*sz23))=randn(nz,1);

   while (1)
% Choose eye to try to force a non singular a 
% I wish we could turn off warnings here!
      drf=eye(sz4) * 1e-4;
      nz= ceil(sz4^2 *rand(1)/2);
      drf(ceil(rand(nz,1)*sz4^2))=randn(nz,1);

      if abs(det(drf)) >1e-10 ; break ; end
   end
   erf= rand(sz4,ceil(rand(1)*4));

% choose a number != 0
   while (1)
      frn= randn;
      if (abs(frn) >=1e-2) break; end
   end

% complex sparse
   acf=zeros( sz1,sz2 );
   nz= ceil(sz12*rand(1)/2+1);
   acf(ceil(rand(nz,1)*sz12))=randn(nz,1) + 1i*randn(nz,1);

   bcf=zeros( sz1,sz2 );
   nz= ceil(sz12*rand(1)/2+1);
   bcf(ceil(rand(nz,1)*sz12))=randn(nz,1) + 1i*randn(nz,1);

   ccf=zeros( sz2,sz3 );
   nz= ceil(sz23*rand(1)/2+1);
   ccf(ceil(rand(nz,1)*sz23))=randn(nz,1) + 1i*randn(nz,1);

   while (1)
% Choose eye to try to force a non singular a 
% I wish we could turn off warnings here!
      dcf=eye(sz4) * 1e-4;
      nz= ceil(sz4^2 *rand(1)/2);
      dcf(ceil(rand(nz,1)*sz4^2))=randn(nz,1) + 1i*randn(nz,1);

      if abs(det(dcf)) >1e-10 ; break ; end
   end
   ecf= randn(sz4,sz5) + 1i*randn(sz4,sz5);

   fcn= frn+ 1i*randn;

% generate L and U masks
   [xx,yy]=meshgrid( 1:sz4, -( 1:sz4) );
   LL= xx+yy<=0;
   UU= xx+yy>=0;

% select masks
   selx= ceil( sz2*rand(1,2*ceil( rand(1)*sz2 )) );
   sely= ceil( sz1*rand(1,2*ceil( rand(1)*sz1 )) );
   sel1= ceil(sz12*rand(1,2*ceil( rand(1)*sz12 )))';

%  save save_fil arf brf crf erf acf bcf ccf dcf ecf selx sely sel1 fcn
%  load -force save_fil

   ars= sparse(arf);
   brs= sparse(brf);
   crs= sparse(crf);
   drs= sparse(drf);
   ers= sparse(erf);


   acs= sparse(acf);
   bcs= sparse(bcf);
   ccs= sparse(ccf);
   dcs= sparse(dcf);
   ecs= sparse(ecf);

   i=1   ;     % i= 1

   res(i)= res(i)     +( is_sparse(ars) == 1 );
   i=i+1;      % i= 2
   res(i)= res(i)     +( is_real_sparse(ars) == 1 );
   i=i+1;      % i= 3
   res(i)= res(i)     +( is_complex_sparse(ars) == 0 );
   i=i+1;      % i= 4

   res(i)= res(i)     +( is_sparse(acs) == 1 );
   i=i+1;      % i= 5
   res(i)= res(i)     +( is_real_sparse(acs) == 0 );
   i=i+1;      % i= 6
   res(i)= res(i)     +( is_complex_sparse(acs) == 1 );
   i=i+1;      % i= 7

   res(i)= res(i)     +( is_sparse(acf) == 0 );
   i=i+1;      % i= 8
   res(i)= res(i)     +( is_real_sparse(acf) == 0 );
   i=i+1;      % i= 9
   res(i)= res(i)     +( is_complex_sparse(acf) == 0 );
   i=i+1;      % i=10

   if ~isempty(ars)
      res(i)= res(i)     + all( abs(spsum(ars) - sum(arf)) < errortol );
      i=i+1;      % i=11
      res(i)= res(i)     + all( abs(spsum(ars,2) - sum(arf,2)) < errortol );
      i=i+1;      % i=12
      res(i)= res(i)     + all( abs(spsum(acs,1) - sum(acf,1)) < errortol );
      i=i+1;      % i=13
   else      
      res(i)= res(i)+1;
      i=i+1;
      res(i)= res(i)+1;
      i=i+1;
      res(i)= res(i)+1;
      i=i+1;
   endif
%
% test sparse assembly and disassembly
%
   res(i)= res(i)     +all(all( ars == ars ));
   i=i+1;      % i=14
   res(i)= res(i)     +all(all( ars == arf ));
   i=i+1;      % i=15
   res(i)= res(i)     +all(all( arf == ars ));
   i=i+1;      % i=16
   res(i)= res(i)     +all(all( acs == acs ));
   i=i+1;      % i=17
   res(i)= res(i)     +all(all( acs == acf ));
   i=i+1;      % i=18
   res(i)= res(i)     +all(all( acf == acs ));
   i=i+1;      % i=19

   [ii,jj,vv,nr,nc] = spfind( ars );
   res(i)= res(i)     +all(all( arf == full( sparse(ii,jj,vv,nr,nc) ) ));
   i=i+1;      % i=20
   [ii,jj,vv,nr,nc] = spfind( acs );
   res(i)= res(i)     +all(all( acf == full( sparse(ii,jj,vv,nr,nc) ) ));
   i=i+1;      % i=21
   res(i)= res(i)     +( nnz(ars) == sum(sum( arf!=0 )) );
   i=i+1;      % i=22
   res(i)= res(i)     +   (  nnz(ars) == nnz(arf));  
   i=i+1;      % i=23
   res(i)= res(i)     +( nnz(acs) == sum(sum( acf!=0 )) );
   i=i+1;      % i=24
   res(i)= res(i)     +   (  nnz(acs) == nnz(acf));  
   i=i+1;      % i=25

%
% spabs, spimag, spreal
%
   res(i)= res(i)     +   all(all(  full(spabs(ars)) == abs(arf) ));  
   i=i+1;      % i=26
   res(i)= res(i)     +   all(all(  full(spabs(acs)) == abs(acf) ));  
   i=i+1;      % i=27
   res(i)= res(i)     +   all(all(  full(spreal(ars)) == real(arf) ));  
   i=i+1;      % i=28
   res(i)= res(i)     +   all(all(  full(spreal(acs)) == real(acf) ));  
   i=i+1;      % i=29
   res(i)= res(i)     +   all(all(  full(spimag(ars)) == imag(arf) ));  
   i=i+1;      % i=30
   res(i)= res(i)     +   all(all(  full(spimag(acs)) == imag(acf) ));  
   i=i+1;      % i=31
%    
% test sparse op scalar operations
%
   res(i)= res(i)     +all(all( (ars==frn) == (arf==frn) ));
   i=i+1;      % i=32
   res(i)= res(i)     +all(all( (frn==ars) == (frn==arf) ));
   i=i+1;      % i=33
   res(i)= res(i)     +all(all( (frn+ars) == (frn+arf) ));
   i=i+1;      % i=34
   res(i)= res(i)     +all(all( (ars+frn) == (arf+frn) ));
   i=i+1;      % i=35
   res(i)= res(i)     +all(all( (frn-ars) == (frn-arf) ));
   i=i+1;      % i=36
   res(i)= res(i)     +all(all( (ars-frn) == (arf-frn) ));
   i=i+1;      % i=37
   res(i)= res(i)     +all(all( (frn*ars) == (frn*arf) ));
   i=i+1;      % i=38
   res(i)= res(i)     +all(all( (ars*frn) == (arf*frn) ));
   i=i+1;      % i=39
   res(i)= res(i)     +all(all( (frn.*ars) == (frn.*arf) ));
   i=i+1;      % i=40
   res(i)= res(i)     +all(all( (ars.*frn) == (arf.*frn) ));
   i=i+1;      % i=41
   res(i)= res(i)     +all(all( abs( (frn\ars) - (frn\arf) )<errortol ));
   i=i+1;      % i=42
   res(i)= res(i)     +all(all( abs( (ars/frn) - (arf/frn) )<errortol ));
   i=i+1;      % i=43
   [jnk1,jnk2, sp_values] = spfind( ars.^frn );
   full_vals=                       arf.^frn;
   full_vals= full_vals(~isnan(full_vals) & ~isinf(full_vals) & (full_vals~=0));
   res(i)= res(i)     +all(all( (sp_values(:) - full_vals(:)) <errortol ));
   i=i+1;      % i=44
%    
% test sparse op complex scalar operations
%
   res(i)= res(i)     +all(all( (ars==fcn) == (arf==fcn) ));
   i=i+1;      % i=45
   res(i)= res(i)     +all(all( (fcn==ars) == (fcn==arf) ));
   i=i+1;      % i=46
   res(i)= res(i)     +all(all( (fcn+ars) == (fcn+arf) ));
   i=i+1;      % i=47
   res(i)= res(i)     +all(all( (ars+fcn) == (arf+fcn) ));
   i=i+1;      % i=48
   res(i)= res(i)     +all(all( (fcn-ars) == (fcn-arf) ));
   i=i+1;      % i=49
   res(i)= res(i)     +all(all( (ars-fcn) == (arf-fcn) ));
   i=i+1;      % i=50
   res(i)= res(i)     + issparse( (fcn*ars) );
   i=i+1;      % i=51
   res(i)= res(i)     +all(all( (fcn*ars) == (fcn*arf) ));
   i=i+1;      % i=52
   res(i)= res(i)     + issparse( (ars*fcn) );
   i=i+1;      % i=53
   res(i)= res(i)     +all(all( (ars*fcn) == (arf*fcn) ));
   i=i+1;      % i=54
   res(i)= res(i)     + issparse( (fcn.*ars) );
   i=i+1;      % i=55
   res(i)= res(i)     +all(all( (fcn.*ars) == (fcn.*arf) ));
   i=i+1;      % i=56
   res(i)= res(i)     + issparse( (ars.*fcn) );
   i=i+1;      % i=57
   res(i)= res(i)     +all(all( (ars.*fcn) == (arf.*fcn) ));
   i=i+1;      % i=58
   res(i)= res(i)     + issparse( (fcn\ars) );
   i=i+1;      % i=59
   res(i)= res(i)     +all(all( abs( (fcn\ars) - (fcn\arf) )<errortol ));
   i=i+1;      % i=60
   res(i)= res(i)     + issparse( (ars/fcn) );
   i=i+1;      % i=61
   res(i)= res(i)     +all(all( abs( (ars/fcn) - (arf/fcn) )<errortol ));
   i=i+1;      % i=62
   [jnk1,jnk2, sp_values] = spfind( ars.^fcn );
   full_vals=                       arf.^fcn;
   full_vals= full_vals(~isnan(full_vals) & ~isinf(full_vals) & (full_vals~=0));
   res(i)= res(i)     +all(all( (sp_values(:) - full_vals(:)) <errortol ));
   i=i+1;      % i=63
%    
% test complex sparse op scalar operations
%
   res(i)= res(i)     + issparse( (acs*frn) );
   i=i+1;      % i=64
   res(i)= res(i)     +all(all( (acs==frn) == (acf==frn) ));
   i=i+1;      % i=65
   res(i)= res(i)     + issparse( (frn*acs) );
   i=i+1;      % i=66
   res(i)= res(i)     +all(all( (frn==acs) == (frn==acf) ));
   i=i+1;      % i=67
   res(i)= res(i)     +all(all( (frn+acs) == (frn+acf) ));
   i=i+1;      % i=68
   res(i)= res(i)     +all(all( (acs+frn) == (acf+frn) ));
   i=i+1;      % i=69
   res(i)= res(i)     +all(all( (frn-acs) == (frn-acf) ));
   i=i+1;      % i=70
   res(i)= res(i)     +all(all( (acs-frn) == (acf-frn) ));
   i=i+1;      % i=71
   res(i)= res(i)     + issparse( (frn*acs) );
   i=i+1;      % i=72
   res(i)= res(i)     +all(all( (frn*acs) == (frn*acf) ));
   i=i+1;      % i=73
   res(i)= res(i)     +all(all( (acs*frn) == (acf*frn) ));
   i=i+1;      % i=74
   res(i)= res(i)     + issparse( (frn.*acs) );
   i=i+1;      % i=75
   res(i)= res(i)     +all(all( (frn.*acs) == (frn.*acf) ));
   i=i+1;      % i=76
   res(i)= res(i)     +all(all( (acs.*frn) == (acf.*frn) ));
   i=i+1;      % i=77
   res(i)= res(i)     + issparse( (frn\acs) );
   i=i+1;      % i=78
   res(i)= res(i)     +all(all( abs( (frn\acs) - (frn\acf) )<errortol ));
   i=i+1;      % i=79
   res(i)= res(i)     +all(all( abs( (acs/frn) - (acf/frn) )<errortol ));
   i=i+1;      % i=80
   [jnk1,jnk2, sp_values] = spfind( acs.^frn );
   full_vals=                       acf.^frn;
   full_vals= full_vals(~isnan(full_vals) & ~isinf(full_vals) & (full_vals~=0));
   res(i)= res(i)     +all(all( sp_values(:) == full_vals(:) ));
   i=i+1;      % i=81
%    
% test complex sparse op complex scalar operations
%
   res(i)= res(i)     +all(all( (acs==fcn) == (acf==fcn) ));
   i=i+1;      % i=82
   res(i)= res(i)     +all(all( (fcn==acs) == (fcn==acf) ));
   i=i+1;      % i=83
   res(i)= res(i)     +all(all( (fcn+acs) == (fcn+acf) ));
   i=i+1;      % i=84
   res(i)= res(i)     +all(all( (acs+fcn) == (acf+fcn) ));
   i=i+1;      % i=85
   res(i)= res(i)     +all(all( (fcn-acs) == (fcn-acf) ));
   i=i+1;      % i=86
   res(i)= res(i)     +all(all( (acs-fcn) == (acf-fcn) ));
   i=i+1;      % i=87
   res(i)= res(i)     +all(all( (fcn*acs) == (fcn*acf) ));
   i=i+1;      % i=88
   res(i)= res(i)     +all(all( (acs*fcn) == (acf*fcn) ));
   i=i+1;      % i=89
   res(i)= res(i)     +all(all( (fcn.*acs) == (fcn.*acf) ));
   i=i+1;      % i=90
   res(i)= res(i)     +all(all( (acs.*fcn) == (acf.*fcn) ));
   i=i+1;      % i=91
   res(i)= res(i)     +all(all( abs( (fcn\acs) - (fcn\acf) )<errortol ));
   i=i+1;      % i=92
   res(i)= res(i)     +all(all( abs( (acs/fcn) - (acf/fcn) )<errortol ));
   i=i+1;      % i=93
   [jnk1,jnk2, sp_values] = spfind( acs.^fcn );
   full_vals=                       acf.^fcn;
   full_vals= full_vals(~isnan(full_vals) & ~isinf(full_vals) & (full_vals~=0));
   res(i)= res(i)     +all(all( sp_values(:) == full_vals(:) ));
   i=i+1;      % i=94

%
% sparse uary ops
%
   res(i)= res(i)     +all(all( ars.' ==  arf.' ));  
   i=i+1;      % i=95
   res(i)= res(i)     +all(all( ars'  ==  arf' ));  
   i=i+1;      % i=96
   res(i)= res(i)     +all(all( -ars  == -arf ));  
   i=i+1;      % i=97
   res(i)= res(i)     +all(all( ~ars  == ~arf ));  
   i=i+1;      % i=98
%
% complex sparse uary ops
%
   res(i)= res(i)     +all(all( acs.' ==  acf.' ));  
   i=i+1;      % i=99
   res(i)= res(i)     +all(all( acs'  ==  acf' ));  
   i=i+1;      % i=100
   res(i)= res(i)     +all(all( -acs  == -acf ));  
   i=i+1;      % i=101
   res(i)= res(i)     +all(all( ~acs  == ~acf ));  
   i=i+1;      % i=102

%
% sparse op sparse and  sparse op matrix
%

   df_ef= drf\erf;
   mag =  errortol*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(drs\erf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=103

   rdif= abs(drf\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=104

   rdif= abs(drs\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=105

   res(i)= res(i)     +all(all( ars+brs == arf+brf )); 
   i=i+1;      % i=106
   res(i)= res(i)     +all(all( arf+brs == arf+brf ));  
   i=i+1;      % i=107
   res(i)= res(i)     +all(all( ars+brf == arf+brf ));  
   i=i+1;      % i=108
   res(i)= res(i)     +all(all( ars-brs == arf-brf ));  
   i=i+1;      % i=109
   res(i)= res(i)     +all(all( arf-brs == arf-brf ));  
   i=i+1;      % i=110
   res(i)= res(i)     +all(all( ars-brf == arf-brf ));  
   i=i+1;      % i=111
   res(i)= res(i)     +all(all( (ars>brs) == (arf>brf) ));  
   i=i+1;      % i=112
   res(i)= res(i)     +all(all( (ars<brs) == (arf<brf) ));  
   i=i+1;      % i=113
   res(i)= res(i)     +all(all( (ars!=brs) == (arf!=brf) ));  
   i=i+1;      % i=114
   res(i)= res(i)     +all(all( (ars>=brs) == (arf>=brf) ));  
   i=i+1;      % i=115
   res(i)= res(i)     +all(all( (ars<=brs) == (arf<=brf) ));  
   i=i+1;      % i=116
   res(i)= res(i)     +all(all( (ars==brs) == (arf==brf) ));  
   i=i+1;      % i=117
   res(i)= res(i)     +all(all( ars.*brs == arf.*brf ));  
   i=i+1;      % i=118
   res(i)= res(i)     +all(all( arf.*brs == arf.*brf ));  
   i=i+1;      % i=119
   res(i)= res(i)     +all(all( ars.*brf == arf.*brf ));  
   i=i+1;      % i=120
   res(i)= res(i)     +all(all( ars*crs == arf*crf ));  
   i=i+1;      % i=121
   res(i)= res(i)     +all(all( arf*crs == arf*crf ));  
   i=i+1;      % i=122
   res(i)= res(i)     +all(all( ars*crf == arf*crf ));  
   i=i+1;      % i=123

%
% sparse op complex sparse and  sparse op complex matrix
%

   df_ef= drf\ecf;
   mag =  errortol*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(drs\ecf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=124

   rdif= abs(drf\ecs - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=125

# TODO: not avail yet
#  rdif= abs(drs\ecs - df_ef) < abs(mag*df_ef);
#  res(i)= res(i)     +all(all( rdif ));
#  i=i+1;      % i=126

   res(i)= res(i)     +all(all( ars+bcs == arf+bcf )); 
   i=i+1;      % i=127
   res(i)= res(i)     +all(all( arf+bcs == arf+bcf ));  
   i=i+1;      % i=128
   res(i)= res(i)     +all(all( ars+bcf == arf+bcf ));  
   i=i+1;      % i=129
   res(i)= res(i)     +all(all( ars-bcs == arf-bcf ));  
   i=i+1;      % i=130
   res(i)= res(i)     +all(all( arf-bcs == arf-bcf ));  
   i=i+1;      % i=131
   res(i)= res(i)     +all(all( ars-bcf == arf-bcf ));  
   i=i+1;      % i=132
   res(i)= res(i)     +all(all( (ars>bcs) == (arf>bcf) ));  
   i=i+1;      % i=133
   res(i)= res(i)     +all(all( (ars<bcs) == (arf<bcf) ));  
   i=i+1;      % i=134
   res(i)= res(i)     +all(all( (ars!=bcs) == (arf!=bcf) ));  
   i=i+1;      % i=135
   res(i)= res(i)     +all(all( (ars>=bcs) == (arf>=bcf) ));  
   i=i+1;      % i=136
   res(i)= res(i)     +all(all( (ars<=bcs) == (arf<=bcf) ));  
   i=i+1;      % i=137
   res(i)= res(i)     +all(all( (ars==bcs) == (arf==bcf) ));  
   i=i+1;      % i=138
   res(i)= res(i)     +all(all( ars.*bcs == arf.*bcf ));  
   i=i+1;      % i=139
   res(i)= res(i)     +all(all( arf.*bcs == arf.*bcf ));  
   i=i+1;      % i=140
   res(i)= res(i)     +all(all( ars.*bcf == arf.*bcf ));  
   i=i+1;      % i=141
   res(i)= res(i)     +all(all( ars*ccs == arf*ccf ));  
   i=i+1;      % i=142
   res(i)= res(i)     +all(all( arf*ccs == arf*ccf ));  
   i=i+1;      % i=143
   res(i)= res(i)     +all(all( ars*ccf == arf*ccf ));  
   i=i+1;      % i=144

%
% complex sparse op sparse and  complex sparse op matrix
%

   df_ef= dcf\erf;
   mag =  errortol*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(dcs\erf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=145

   rdif= abs(dcf\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=146

   df_ef= dcf\erf;
   rdif= abs(dcs\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=147

   df_ef= drf\ecf;
   rdif= abs(drs\ecs - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=148

   res(i)= res(i)     +all(all( acs+brs == acf+brf )); 
   i=i+1;      % i=149
   res(i)= res(i)     +all(all( acf+brs == acf+brf ));  
   i=i+1;      % i=150
   res(i)= res(i)     +all(all( acs+brf == acf+brf ));  
   i=i+1;      % i=151
   res(i)= res(i)     +all(all( acs-brs == acf-brf ));  
   i=i+1;      % i=152
   res(i)= res(i)     +all(all( acf-brs == acf-brf ));  
   i=i+1;      % i=153
   res(i)= res(i)     +all(all( acs-brf == acf-brf ));  
   i=i+1;      % i=154
   res(i)= res(i)     +all(all( (acs>brs) == (acf>brf) ));  
   i=i+1;      % i=155
   res(i)= res(i)     +all(all( (acs<brs) == (acf<brf) ));  
   i=i+1;      % i=156
   res(i)= res(i)     +all(all( (acs!=brs) == (acf!=brf) ));  
   i=i+1;      % i=157
   res(i)= res(i)     +all(all( (acs>=brs) == (acf>=brf) ));  
   i=i+1;      % i=158
   res(i)= res(i)     +all(all( (acs<=brs) == (acf<=brf) ));  
   i=i+1;      % i=159
   res(i)= res(i)     +all(all( (acs==brs) == (acf==brf) ));  
   i=i+1;      % i=160
   res(i)= res(i)     +all(all( acs.*brs == acf.*brf ));  
   i=i+1;      % i=161
   res(i)= res(i)     +all(all( acf.*brs == acf.*brf ));  
   i=i+1;      % i=162
   res(i)= res(i)     +all(all( acs.*brf == acf.*brf ));  
   i=i+1;      % i=163
   res(i)= res(i)     +all(all( acs*crs == acf*crf ));  
   i=i+1;      % i=164
   res(i)= res(i)     +all(all( acf*crs == acf*crf ));  
   i=i+1;      % i=165
   res(i)= res(i)     +all(all( acs*crf == acf*crf ));  
   i=i+1;      % i=166

%
% complex sparse op complex sparse and  complex sparse op complex matrix
%

   df_ef= dcf\ecf;
   mag =  errortol*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(dcs\ecf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=167

   rdif= abs(dcf\ecs - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=168

   rdif= abs(dcs\ecs - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1;      % i=169

   res(i)= res(i)     +all(all( acs+bcs == acf+bcf )); 
   i=i+1;      % i=170
   res(i)= res(i)     +all(all( acf+bcs == acf+bcf ));  
   i=i+1;      % i=171
   res(i)= res(i)     +all(all( acs+bcf == acf+bcf ));  
   i=i+1;      % i=172
   res(i)= res(i)     +all(all( acs-bcs == acf-bcf ));  
   i=i+1;      % i=173
   res(i)= res(i)     +all(all( acf-bcs == acf-bcf ));  
   i=i+1;      % i=174
   res(i)= res(i)     +all(all( acs-bcf == acf-bcf ));  
   i=i+1;      % i=175
   res(i)= res(i)     +all(all( (acs>bcs) == (acf>bcf) ));  
   i=i+1;      % i=176
   res(i)= res(i)     +all(all( (acs<bcs) == (acf<bcf) ));  
   i=i+1;      % i=177
   res(i)= res(i)     +all(all( (acs!=bcs) == (acf!=bcf) ));  
   i=i+1;      % i=178
   res(i)= res(i)     +all(all( (acs>=bcs) == (acf>=bcf) ));  
   i=i+1;      % i=179
   res(i)= res(i)     +all(all( (acs<=bcs) == (acf<=bcf) ));  
   i=i+1;      % i=180
   res(i)= res(i)     +all(all( (acs==bcs) == (acf==bcf) ));  
   i=i+1;      % i=181
   res(i)= res(i)     +all(all( acs.*bcs == acf.*bcf ));  
   i=i+1;      % i=182
   res(i)= res(i)     +all(all( acf.*bcs == acf.*bcf ));  
   i=i+1;      % i=183
   res(i)= res(i)     +all(all( acs.*bcf == acf.*bcf ));  
   i=i+1;      % i=184
   res(i)= res(i)     +all(all( abs( acs*ccs - acf*ccf ) < errortol ));  
   i=i+1;      % i=185
   res(i)= res(i)     +all(all( abs( acf*ccs - acf*ccf ) < errortol ));  
   i=i+1;      % i=186
   res(i)= res(i)     +all(all( abs( acs*ccf - acf*ccf ) < errortol ));  
   i=i+1;      % i=187

%
% sparse select operations
%
   %this is necessary until we get the orientations sorted
   r1= ars(sel1); r2=arf(sel1);
   res(i)= res(i)     +all( r1(:) == r2(:) );
%  res(i)= res(i)     +all( ars(sel1) == arf(sel1 ));
   i=i+1;      % i=188
   res(i)= res(i)     +all( ars(:) == arf(:));
   i=i+1;      % i=189
   res(i)= res(i)     +all(all( ars(sely,selx) == arf(sely,selx) ));
   i=i+1;      % i=190
   res(i)= res(i)     +all(all( ars( :  ,selx) == arf( :  ,selx) ));
   i=i+1;      % i=191
   res(i)= res(i)     +all(all( ars(sely, :  ) == arf(sely, :  ) ));
   i=i+1;      % i=192
   res(i)= res(i)     +all(all( ars(:,:) == arf(:,:) ));
   i=i+1;      % i=193

%
% complex sparse select operations
%
   r1= acs(sel1); r2=acf(sel1);
   res(i)= res(i)     +all( r1(:) == r2(:) );
%  res(i)= res(i)     +all( ars(sel1) == arf(sel1 ));
   i=i+1;      % i=194
   res(i)= res(i)     +all( ars(:) == arf(:));
   i=i+1;      % i=195
   res(i)= res(i)     +all(all( ars(sely,selx) == arf(sely,selx) ));
   i=i+1;      % i=196
   res(i)= res(i)     +all(all( ars( :  ,selx) == arf( :  ,selx) ));
   i=i+1;      % i=197
   res(i)= res(i)     +all(all( ars(sely, :  ) == arf(sely, :  ) ));
   i=i+1;      % i=198
   res(i)= res(i)     +all(all( ars(:,:) == arf(:,:) ));
   i=i+1;      % i=199

%
% sparse LU and inverse
%
   mag = errortol;
   [Lf2,Uf2]     =   lu( drf );
   [Lf4,Uf4,Pf4] =   lu( drf );

   if OCTAVE
      [Ls2,Us2]     = splu( drs );
   else
      [Ls2,Us2]     = lu( drs );
   end

% LU decomp may be different but U must be Upper and LU==d
   res(i)= res(i) + all( [  ...
               all(all( abs(Ls2*Us2 - Lf2*Uf2 )< mag )) ; ...
                      1 ] );
   i=i+1;      % i=200
                                        
   if OCTAVE
      [Ls4,Us4,PsR,PsC] = splu( drs );
      res(i)= res(i) + ...
            all([ all(all(abs( PsR'*Ls4*Us4*PsC  - Pf4'*Lf4*Uf4 )<mag)) ;
                  all(all(abs( PsR'*Ls4*Us4*PsC  - drf )< mag)) ;
                  all(all( Ls4 .* LL == Ls4 )) ;
                  all(all( Us4 .* UU == Us4 )) ] );
   end 
   i=i+1;      % i=200
       
   if 0 % OCTAVE
      [Ls4,Us4,Ps4] = lu( drs );
      res(i)= res(i) + ...
            all([ all(all(abs( Ps4'*Ls4*Us4 - Pf4'*Lf4*Uf4 )<mag)) ;
                  all(all(abs( Ps4'*Ls4*Us4 - drf )< mag)) ;
                  all(all( Ls4 .* LL == Ls4 )) ;
                  all(all( Us4 .* UU == Us4 )) ] );
   end
   i=i+1;      % i=201

   dsi = spinv( drs );
   mag= errortol;
   res(i)= res(i) + all(all( ...
           abs( inv(drf) - dsi ) <= mag*(1+abs(inv(drf))) ));
   i=i+1;      % i=202

   if OCTAVE
      res(i)= res(i)    +all( spfind(ars) == find(arf) );
      [I,J,S,N,M]= spfind(ars);
   else
      res(i)= res(i)    +all( find(ars) == find(arf) );
      [I,J,S]= find(ars);
      [N,M]  = size(ars);
   end
   i=i+1;      % i=203

   asnew= sparse(I,J,S,N,M);
   res(i)= res(i)    +all( all( asnew == ars ));
   i=i+1;      % i=204

%
% complex sparse LU and inverse
%
   mag = errortol;
   [Lf2,Uf2]     =   lu( dcf );
   [Lf4,Uf4,Pf4] =   lu( dcf );

   if OCTAVE
      [Ls2,Us2]     = splu( dcs );
   else
      [Ls2,Us2]     = lu( dcs );
   end

% LU decomp may be different but U must be Upper and LU==d
   res(i)= res(i) + all( [  ...
               all(all( abs(Ls2*Us2 - Lf2*Uf2 )< mag )) ; ...
                      1 ] );
   i=i+1;      % i=205

   if OCTAVE
      [Ls4,Us4,PsR,PsC] = splu( dcs );
      res(i)= res(i) + ...
            all([ all(all(abs( PsR'*Ls4*Us4*PsC  - Pf4'*Lf4*Uf4 )<mag)) ;
                  all(all(abs( PsR'*Ls4*Us4*PsC  - dcf )< mag)) ;
                  all(all( Ls4 .* LL == Ls4 )) ;
                  all(all( Us4 .* UU == Us4 )) ] );
   elseif 0
      [Ls4,Us4,Ps4] = lu( dcs );
      res(i)= res(i) + ...
            all([ all(all(abs( Ps4'*Ls4*Us4 - Pf4'*Lf4*Uf4 )<mag)) ;
                  all(all(abs( Ps4'*Ls4*Us4 - dcf )< mag)) ;
                  all(all( Ls4 .* LL == Ls4 )) ;
                  all(all( Us4 .* UU == Us4 )) ] );
   end
   i=i+1;      % i=206

   dci = spinv( dcs );
   mag= errortol;
   res(i)= res(i) + all(all( ...
           abs( inv(dcf) - dci ) <= mag*(1+abs(inv(dcf))) ));
   i=i+1;      % i=207

   if OCTAVE
      res(i)= res(i)    +all( spfind(acs) == find(acf) );
      [I,J,S,N,M]= spfind(acs);
   else
      res(i)= res(i)    +all( find(acs) == find(acf) );
      [I,J,S]= find(acs);
      [N,M]  = size(acs);
   end
   i=i+1;      % i=208

   asnew= sparse(I,J,S,N,M);
   res(i)= res(i)    +all( all( asnew == acs ));
   i=i+1;      % i=209

   % test sparse assembly using 'sum' or 'unique'
   tf1= zeros(N,M);
   tf2= zeros(N,M);
   ts= sparse(N,M);
   nn= mean([N,M]);
   rr= floor(rand(5,nn)*N)+1;
   cc= floor(rand(5,nn)*M)+1;
   tf1( rr(:)+N*(cc(:)-1) ) =ones(5,nn);
   for k=1:length(rr(:))
      tf2( rr(k),cc(k) )+=1;
   end


   % test normal assembly
   res(i)= res(i)    +all( all( sparse(rr,cc,1,N,M) == tf2 ));
   i=i+1;      % i=210

   % test 'unique' assembly
   res(i)= res(i)    +all( all( sparse(rr,cc,1,N,M,'unique') == tf1 ));
   i=i+1;      % i=211

   % test 'sum' assembly
   res(i)= res(i)    +all( all( sparse(rr,cc,1,N,M,'sum') == tf2 ));
   i=i+1;      % i=212

   % test 'sphcat' 'spvcat'
   res(i)= res(i)    +all( all(
       sphcat( ars,brs,brs,ars ) == [ars,brs,brs,ars] ));
   i=i+1;      % i=213

   res(i)= res(i)    +all( all(
       spvcat( ars,brs,brs,ars ) == [ars;brs;brs;ars] ));
   i=i+1;      % i=214


end 

res= res(1:i-1);

printf( ...
    '%d operations tested sucessfully for %d iterations\n', ...
    sum( res==NTRIES) , NTRIES );

for i=find( res~= NTRIES)
   printf( [ 'operation #%d in sp_test.m exceeds error tolerance ', ...
             'with probability %5.2f%%\n' ], ...
    i, 100*(1 - res(i)/NTRIES) );
end           

% segfault test from edd@debian.org
n = 510; sparse(kron((1:n)', ones(n,1)), kron(ones(n,1), (1:n)'), ones(n));

% segfault test from Fabian@isas-berlin.de
% expected behaviour is to emit error
printf( 'Test for crash: expected behaviour is to emit error...\n');
eval("spinv( sparse( [1,1;1,1]   ) );");
eval("spinv( sparse( [1,1;1,1+i] ) );");
eval("spinv( sparse( [0,0;0,1]   ) );");
eval("spinv( sparse( [0,0;0,1+i] ) );");
eval("spinv( sparse( [0,0;0,0]   ) );");
eval( "splu( sparse( [1,1;1,1]   ) );");
eval( "splu( sparse( [1,1;1,1+i] ) );");
eval( "splu( sparse( [0,0;0,1]   ) );");
eval( "splu( sparse( [0,0;0,1+i] ) );");
eval( "splu( sparse( [0,0;0,0]   ) );");

% clear up variables - so dmalloc works
#clear L* U* a* b* c* d* e* P*


%
% $Log$
% Revision 1.17  2003/10/21 14:35:12  aadler
% minor test and error mods
%
% Revision 1.16  2003/10/18 04:55:47  aadler
% spreal spimag and new tests
%
% Revision 1.15  2003/09/12 14:22:42  adb014
% Changes to allow use with latest CVS of octave (do_fortran_indexing, etc)
%
% Revision 1.14  2003/08/30 03:03:05  aadler
% mods to prevent segfaults for sparse
%
% Revision 1.13  2003/08/29 21:21:16  aadler
% mods to fix bugs for empty sparse
%
% Revision 1.12  2003/05/21 18:20:07  aadler
% concatenate sparse matrices
%
% Revision 1.11  2003/04/03 22:06:40  aadler
% sparse create bug - need to use heap for large temp vars
%
% Revision 1.10  2003/02/20 22:51:45  pkienzle
% Default to 'sum' rather than 'unique' assembly
%
% Revision 1.9  2003/01/02 18:19:36  pkienzle
% make sure rand(n,m) receives integer input
%
% Revision 1.8  2002/12/25 01:33:00  aadler
% fixed bug which allowed zero values to be stored in sparse matrices.
% improved print output
%
% Revision 1.7  2002/12/11 17:19:31  aadler
% sparse .^ scalar operations added
% improved test suite
% improved documentation
% new is_sparse
% new spabs
%
% Revision 1.6  2002/11/05 19:21:07  aadler
% added indexing for complex_sparse. added tests
%
% Revision 1.5  2002/02/28 04:57:18  aadler
% global error threshold
%
% Revision 1.4  2001/11/16 03:09:42  aadler
% added spsum.m, is_sparse, is_real_sparse, is_complex_sparse
%
% Revision 1.3  2001/11/04 19:54:49  aadler
% fix bug with multiple entries in sparse creation.
% Added "summation" mode for matrix creation
%
% Revision 1.2  2001/10/12 02:24:28  aadler
% Mods to fix bugs
% add support for all zero sparse matrices
% add support fom complex sparse inverse
%
% Revision 1.8  2001/09/23 17:46:12  aadler
% updated README
% modified licence to GPL plus link to opensource programmes
%
% Revision 1.7  2001/04/08 20:14:34  aadler
% test cases for complex sparse
%
% Revision 1.6  2001/04/04 02:13:46  aadler
% complete complex_sparse, templates, fix memory leaks
%
% Revision 1.5  2001/03/30 04:36:30  aadler
% added multiply, solve, and sparse creation
%
% Revision 1.4  2001/03/15 15:47:58  aadler
% cleaned up duplicated code by using "defined" templates.
% used default numerical conversions
%
% Revision 1.3  2001/02/27 03:01:52  aadler
% added rudimentary complex matrix support
%
% Revision 1.2  2000/12/18 03:31:16  aadler
% Split code to multiple files
% added sparse inverse
%
% Revision 1.1  2000/11/11 02:47:11  aadler
% DLD functions for sparse support in octave
%
% Revision 1.3  2000/08/02 01:17:51  andy
% more careful tests including vaguely pathological cases
%
% Revision 1.2  2000/06/23 03:25:28  andy
% functions for sparse op scalar
%
% Revision 1.1  2000/04/01 02:42:02  andy
% Initial revision
%
% numbering of tests: (vim cmd)
% %perld BEGIN{$i=0};s/[#%] i=( *\d*) *$/sprintf("%% i=%2d",++$i)/e 
%
