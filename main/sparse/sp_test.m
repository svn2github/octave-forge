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

OCTAVE=  exist('__OCTAVE_VERSION__');
do_fortran_indexing= 1;
prefer_zero_one_indexing= 0;
page_screen_output=1;
SZ=10;
NTRIES=1.0;

res=zeros(1,200); # should be enough space

for tries = 1:NTRIES;

# print some relevant info from ps
if 1
   printf("t=%03d: %s", tries, system(["ps -uh ", num2str(getpid)],1 ) );
endif

% choose some random sizes for the test matrices   
   sz=floor(abs(randn(1,5))*SZ + 1);
   sz1= sz(1); sz2=sz(2); sz3=sz(3); sz4=sz(4); sz5=sz(5);
   sz12= sz1*sz2;
   sz23= sz2*sz3;

% choose random test matrices
   arf=zeros( sz1,sz2 );
   nz= sz12*rand(1)/2+1;
   arf(ceil(rand(nz,1)*sz12))=randn(nz,1);

   brf=zeros( sz1,sz2 );
   nz= sz12*rand(1)/2+1;
   brf(ceil(rand(nz,1)*sz12))=randn(nz,1);

   crf=zeros( sz2,sz3 );
   nz= sz23*rand(1)/2+1;
   crf(ceil(rand(nz,1)*sz23))=randn(nz,1);

   while (1)
% Choose eye to try to force a non singular a 
% I wish we could turn off warnings here!
      drf=eye(sz4) * 1e-4;
      nz= sz4^2 *rand(1)/2;
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
   nz= sz12*rand(1)/2+1;
   acf(ceil(rand(nz,1)*sz12))=randn(nz,1) + 1i*randn(nz,1);

   bcf=zeros( sz1,sz2 );
   nz= sz12*rand(1)/2+1;
   bcf(ceil(rand(nz,1)*sz12))=randn(nz,1) + 1i*randn(nz,1);

   ccf=zeros( sz2,sz3 );
   nz= sz23*rand(1)/2+1;
   ccf(ceil(rand(nz,1)*sz23))=randn(nz,1) + 1i*randn(nz,1);

   while (1)
% Choose eye to try to force a non singular a 
% I wish we could turn off warnings here!
      dcf=eye(sz4) * 1e-4;
      nz= sz4^2 *rand(1)/2;
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

   i=1   ;     % i=  1

%
% test sparse assembly and disassembly
%
   res(i)= res(i)     +all(all( ars == ars ));
   i=i+1 ;     % i=  2
   res(i)= res(i)     +all(all( ars == arf ));
   i=i+1 ;     % i=  3
   res(i)= res(i)     +all(all( arf == ars ));
   i=i+1 ;     % i=  4
   res(i)= res(i)     +all(all( acs == acs ));
   i=i+1 ;     % i=  5
   res(i)= res(i)     +all(all( acs == acf ));
   i=i+1 ;     % i=  6
   res(i)= res(i)     +all(all( acf == acs ));
   i=i+1 ;     % i=  7

   [ii,jj,vv,nr,nc] = spfind( ars );
   res(i)= res(i)     +all(all( arf == full( sparse(ii,jj,vv,nr,nc) ) ));
   i=i+1 ;     % i=  8
   [ii,jj,vv,nr,nc] = spfind( acs );
   res(i)= res(i)     +all(all( acf == full( sparse(ii,jj,vv,nr,nc) ) ));
   i=i+1 ;     % i=  9
   res(i)= res(i)     +( nnz(ars) == sum(sum( arf!=0 )) );
   i=i+1 ;     % i= 10
   res(i)= res(i)     +   (  nnz(ars) == nnz(arf));  
   i=i+1 ;     % i= 11
   res(i)= res(i)     +( nnz(acs) == sum(sum( acf!=0 )) );
   i=i+1 ;     % i= 12
   res(i)= res(i)     +   (  nnz(acs) == nnz(acf));  
   i=i+1 ;     % i= 13
%    
% test sparse op scalar operations
%
   res(i)= res(i)     +all(all( (ars==frn) == (arf==frn) ));
   i=i+1 ;     % i= 14
   res(i)= res(i)     +all(all( (frn==ars) == (frn==arf) ));
   i=i+1 ;     % i= 15
   res(i)= res(i)     +all(all( (frn+ars) == (frn+arf) ));
   i=i+1 ;     % i= 16
   res(i)= res(i)     +all(all( (ars+frn) == (arf+frn) ));
   i=i+1 ;     % i= 17
   res(i)= res(i)     +all(all( (frn-ars) == (frn-arf) ));
   i=i+1 ;     % i= 18
   res(i)= res(i)     +all(all( (ars-frn) == (arf-frn) ));
   i=i+1 ;     % i= 19
   res(i)= res(i)     +all(all( (frn*ars) == (frn*arf) ));
   i=i+1 ;     % i= 20
   res(i)= res(i)     +all(all( (ars*frn) == (arf*frn) ));
   i=i+1 ;     % i= 21
   res(i)= res(i)     +all(all( (frn.*ars) == (frn.*arf) ));
   i=i+1 ;     % i= 22
   res(i)= res(i)     +all(all( (ars.*frn) == (arf.*frn) ));
   i=i+1 ;     % i= 23
   res(i)= res(i)     +all(all( abs( (frn\ars) - (frn\arf) )<1e-13 ));
   i=i+1 ;     % i= 24
   res(i)= res(i)     +all(all( abs( (ars/frn) - (arf/frn) )<1e-13 ));
   i=i+1 ;     % i= 25
%    
% test sparse op complex scalar operations
%
   res(i)= res(i)     +all(all( (ars==fcn) == (arf==fcn) ));
   i=i+1 ;     % i= 26
   res(i)= res(i)     +all(all( (fcn==ars) == (fcn==arf) ));
   i=i+1 ;     % i= 27
   res(i)= res(i)     +all(all( (fcn+ars) == (fcn+arf) ));
   i=i+1 ;     % i= 28
   res(i)= res(i)     +all(all( (ars+fcn) == (arf+fcn) ));
   i=i+1 ;     % i= 29
   res(i)= res(i)     +all(all( (fcn-ars) == (fcn-arf) ));
   i=i+1 ;     % i= 30
   res(i)= res(i)     +all(all( (ars-fcn) == (arf-fcn) ));
   i=i+1 ;     % i= 31
   res(i)= res(i)     +all(all( (fcn*ars) == (fcn*arf) ));
   i=i+1 ;     % i= 32
   res(i)= res(i)     +all(all( (ars*fcn) == (arf*fcn) ));
   i=i+1 ;     % i= 33
   res(i)= res(i)     +all(all( (fcn.*ars) == (fcn.*arf) ));
   i=i+1 ;     % i= 34
   res(i)= res(i)     +all(all( (ars.*fcn) == (arf.*fcn) ));
   i=i+1 ;     % i= 35
   res(i)= res(i)     +all(all( abs( (fcn\ars) - (fcn\arf) )<1e-13 ));
   i=i+1 ;     % i= 36
   res(i)= res(i)     +all(all( abs( (ars/fcn) - (arf/fcn) )<1e-13 ));
   i=i+1 ;     % i= 37
%    
% test complex sparse op scalar operations
%
   res(i)= res(i)     +all(all( (acs==frn) == (acf==frn) ));
   i=i+1 ;     % i= 38
   res(i)= res(i)     +all(all( (frn==acs) == (frn==acf) ));
   i=i+1 ;     % i= 39
   res(i)= res(i)     +all(all( (frn+acs) == (frn+acf) ));
   i=i+1 ;     % i= 40
   res(i)= res(i)     +all(all( (acs+frn) == (acf+frn) ));
   i=i+1 ;     % i= 41
   res(i)= res(i)     +all(all( (frn-acs) == (frn-acf) ));
   i=i+1 ;     % i= 42
   res(i)= res(i)     +all(all( (acs-frn) == (acf-frn) ));
   i=i+1 ;     % i= 43
   res(i)= res(i)     +all(all( (frn*acs) == (frn*acf) ));
   i=i+1 ;     % i= 44
   res(i)= res(i)     +all(all( (acs*frn) == (acf*frn) ));
   i=i+1 ;     % i= 45
   res(i)= res(i)     +all(all( (frn.*acs) == (frn.*acf) ));
   i=i+1 ;     % i= 46
   res(i)= res(i)     +all(all( (acs.*frn) == (acf.*frn) ));
   i=i+1 ;     % i= 47
   res(i)= res(i)     +all(all( abs( (frn\acs) - (frn\acf) )<1e-13 ));
   i=i+1 ;     % i= 48
   res(i)= res(i)     +all(all( abs( (acs/frn) - (acf/frn) )<1e-13 ));
   i=i+1 ;     % i= 49
%    
% test complex sparse op complex scalar operations
%
   res(i)= res(i)     +all(all( (acs==fcn) == (acf==fcn) ));
   i=i+1 ;     % i= 50
   res(i)= res(i)     +all(all( (fcn==acs) == (fcn==acf) ));
   i=i+1 ;     % i= 51
   res(i)= res(i)     +all(all( (fcn+acs) == (fcn+acf) ));
   i=i+1 ;     % i= 52
   res(i)= res(i)     +all(all( (acs+fcn) == (acf+fcn) ));
   i=i+1 ;     % i= 53
   res(i)= res(i)     +all(all( (fcn-acs) == (fcn-acf) ));
   i=i+1 ;     % i= 54
   res(i)= res(i)     +all(all( (acs-fcn) == (acf-fcn) ));
   i=i+1 ;     % i= 55
   res(i)= res(i)     +all(all( (fcn*acs) == (fcn*acf) ));
   i=i+1 ;     % i= 56
   res(i)= res(i)     +all(all( (acs*fcn) == (acf*fcn) ));
   i=i+1 ;     % i= 57
   res(i)= res(i)     +all(all( (fcn.*acs) == (fcn.*acf) ));
   i=i+1 ;     % i= 58
   res(i)= res(i)     +all(all( (acs.*fcn) == (acf.*fcn) ));
   i=i+1 ;     % i= 59
   res(i)= res(i)     +all(all( abs( (fcn\acs) - (fcn\acf) )<1e-13 ));
   i=i+1 ;     % i= 60
   res(i)= res(i)     +all(all( abs( (acs/fcn) - (acf/fcn) )<1e-13 ));
   i=i+1 ;     % i= 61

%
% sparse uary ops
%
   res(i)= res(i)     +all(all( ars.' ==  arf.' ));  
   i=i+1 ;     % i= 62
   res(i)= res(i)     +all(all( ars'  ==  arf' ));  
   i=i+1 ;     % i= 63
   res(i)= res(i)     +all(all( -ars  == -arf ));  
   i=i+1 ;     % i= 64
   res(i)= res(i)     +all(all( ~ars  == ~arf ));  
   i=i+1 ;     % i= 65
%
% complex sparse uary ops
%
   res(i)= res(i)     +all(all( acs.' ==  acf.' ));  
   i=i+1 ;     % i= 66
   res(i)= res(i)     +all(all( acs'  ==  acf' ));  
   i=i+1 ;     % i= 67
   res(i)= res(i)     +all(all( -acs  == -acf ));  
   i=i+1 ;     % i= 68
   res(i)= res(i)     +all(all( ~acs  == ~acf ));  
   i=i+1 ;     % i= 69

%
% sparse op sparse and  sparse op matrix
%

   df_ef= drf\erf;
   mag =  1e-12*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(drs\erf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i= 70

   rdif= abs(drf\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i= 71

   rdif= abs(drs\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i= 72

   res(i)= res(i)     +all(all( ars+brs == arf+brf )); 
   i=i+1 ;     % i= 73
   res(i)= res(i)     +all(all( arf+brs == arf+brf ));  
   i=i+1 ;     % i= 74
   res(i)= res(i)     +all(all( ars+brf == arf+brf ));  
   i=i+1 ;     % i= 75
   res(i)= res(i)     +all(all( ars-brs == arf-brf ));  
   i=i+1 ;     % i= 76
   res(i)= res(i)     +all(all( arf-brs == arf-brf ));  
   i=i+1 ;     % i= 77
   res(i)= res(i)     +all(all( ars-brf == arf-brf ));  
   i=i+1 ;     % i= 78
   res(i)= res(i)     +all(all( (ars>brs) == (arf>brf) ));  
   i=i+1 ;     % i= 79
   res(i)= res(i)     +all(all( (ars<brs) == (arf<brf) ));  
   i=i+1 ;     % i= 80
   res(i)= res(i)     +all(all( (ars!=brs) == (arf!=brf) ));  
   i=i+1 ;     % i= 81
   res(i)= res(i)     +all(all( (ars>=brs) == (arf>=brf) ));  
   i=i+1 ;     % i= 82
   res(i)= res(i)     +all(all( (ars<=brs) == (arf<=brf) ));  
   i=i+1 ;     % i= 83
   res(i)= res(i)     +all(all( (ars==brs) == (arf==brf) ));  
   i=i+1 ;     % i= 84
   res(i)= res(i)     +all(all( ars.*brs == arf.*brf ));  
   i=i+1 ;     % i= 85
   res(i)= res(i)     +all(all( arf.*brs == arf.*brf ));  
   i=i+1 ;     % i= 86
   res(i)= res(i)     +all(all( ars.*brf == arf.*brf ));  
   i=i+1 ;     % i= 87
   res(i)= res(i)     +all(all( ars*crs == arf*crf ));  
   i=i+1 ;     % i= 88
   res(i)= res(i)     +all(all( arf*crs == arf*crf ));  
   i=i+1 ;     % i= 89
   res(i)= res(i)     +all(all( ars*crf == arf*crf ));  
   i=i+1 ;     % i= 90

%
% sparse op complex sparse and  sparse op complex matrix
%

   df_ef= drf\ecf;
   mag =  1e-12*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(drs\ecf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i= 91

   rdif= abs(drf\ecs - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i= 92

# TODO: not avail yet
#  rdif= abs(drs\ecs - df_ef) < abs(mag*df_ef);
#  res(i)= res(i)     +all(all( rdif ));
#  i=i+1 ;     % i= 93

   res(i)= res(i)     +all(all( ars+bcs == arf+bcf )); 
   i=i+1 ;     % i= 94
   res(i)= res(i)     +all(all( arf+bcs == arf+bcf ));  
   i=i+1 ;     % i= 95
   res(i)= res(i)     +all(all( ars+bcf == arf+bcf ));  
   i=i+1 ;     % i= 96
   res(i)= res(i)     +all(all( ars-bcs == arf-bcf ));  
   i=i+1 ;     % i= 97
   res(i)= res(i)     +all(all( arf-bcs == arf-bcf ));  
   i=i+1 ;     % i= 98
   res(i)= res(i)     +all(all( ars-bcf == arf-bcf ));  
   i=i+1 ;     % i= 99
   res(i)= res(i)     +all(all( (ars>bcs) == (arf>bcf) ));  
   i=i+1 ;     % i=100
   res(i)= res(i)     +all(all( (ars<bcs) == (arf<bcf) ));  
   i=i+1 ;     % i=101
   res(i)= res(i)     +all(all( (ars!=bcs) == (arf!=bcf) ));  
   i=i+1 ;     % i=102
   res(i)= res(i)     +all(all( (ars>=bcs) == (arf>=bcf) ));  
   i=i+1 ;     % i=103
   res(i)= res(i)     +all(all( (ars<=bcs) == (arf<=bcf) ));  
   i=i+1 ;     % i=104
   res(i)= res(i)     +all(all( (ars==bcs) == (arf==bcf) ));  
   i=i+1 ;     % i=105
   res(i)= res(i)     +all(all( ars.*bcs == arf.*bcf ));  
   i=i+1 ;     % i=106
   res(i)= res(i)     +all(all( arf.*bcs == arf.*bcf ));  
   i=i+1 ;     % i=107
   res(i)= res(i)     +all(all( ars.*bcf == arf.*bcf ));  
   i=i+1 ;     % i=108
   res(i)= res(i)     +all(all( ars*ccs == arf*ccf ));  
   i=i+1 ;     % i=109
   res(i)= res(i)     +all(all( arf*ccs == arf*ccf ));  
   i=i+1 ;     % i=110
   res(i)= res(i)     +all(all( ars*ccf == arf*ccf ));  
   i=i+1 ;     % i=111

%
% complex sparse op sparse and  complex sparse op matrix
%

   df_ef= dcf\erf;
   mag =  1e-12*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(dcs\erf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i=112

   rdif= abs(dcf\ers - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i=113

# TODO: not avail yet
#  rdif= abs(dcs\ers - df_ef) < abs(mag*df_ef);
#  res(i)= res(i)     +all(all( rdif ));
#  i=i+1 ;     % i=114

   res(i)= res(i)     +all(all( acs+brs == acf+brf )); 
   i=i+1 ;     % i=115
   res(i)= res(i)     +all(all( acf+brs == acf+brf ));  
   i=i+1 ;     % i=116
   res(i)= res(i)     +all(all( acs+brf == acf+brf ));  
   i=i+1 ;     % i=117
   res(i)= res(i)     +all(all( acs-brs == acf-brf ));  
   i=i+1 ;     % i=118
   res(i)= res(i)     +all(all( acf-brs == acf-brf ));  
   i=i+1 ;     % i=119
   res(i)= res(i)     +all(all( acs-brf == acf-brf ));  
   i=i+1 ;     % i=120
   res(i)= res(i)     +all(all( (acs>brs) == (acf>brf) ));  
   i=i+1 ;     % i=121
   res(i)= res(i)     +all(all( (acs<brs) == (acf<brf) ));  
   i=i+1 ;     % i=122
   res(i)= res(i)     +all(all( (acs!=brs) == (acf!=brf) ));  
   i=i+1 ;     % i=123
   res(i)= res(i)     +all(all( (acs>=brs) == (acf>=brf) ));  
   i=i+1 ;     % i=124
   res(i)= res(i)     +all(all( (acs<=brs) == (acf<=brf) ));  
   i=i+1 ;     % i=125
   res(i)= res(i)     +all(all( (acs==brs) == (acf==brf) ));  
   i=i+1 ;     % i=126
   res(i)= res(i)     +all(all( acs.*brs == acf.*brf ));  
   i=i+1 ;     % i=127
   res(i)= res(i)     +all(all( acf.*brs == acf.*brf ));  
   i=i+1 ;     % i=128
   res(i)= res(i)     +all(all( acs.*brf == acf.*brf ));  
   i=i+1 ;     % i=129
   res(i)= res(i)     +all(all( acs*crs == acf*crf ));  
   i=i+1 ;     % i=130
   res(i)= res(i)     +all(all( acf*crs == acf*crf ));  
   i=i+1 ;     % i=131
   res(i)= res(i)     +all(all( acs*crf == acf*crf ));  
   i=i+1 ;     % i=132

%
% complex sparse op complex sparse and  complex sparse op complex matrix
%

   df_ef= dcf\ecf;
   mag =  1e-12*mean( df_ef(:))*sqrt(prod(size(df_ef)));
   # FIXME: this breaks if drs is 1x1
   rdif= abs(dcs\ecf - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i=133

   rdif= abs(dcf\ecs - df_ef) < abs(mag*df_ef);
   res(i)= res(i)     +all(all( rdif ));
   i=i+1 ;     % i=134

# TODO: not avail yet
#  rdif= abs(dcs\ecs - df_ef) < abs(mag*df_ef);
#  res(i)= res(i)     +all(all( rdif ));
#  i=i+1 ;     % i=135

   res(i)= res(i)     +all(all( acs+bcs == acf+bcf )); 
   i=i+1 ;     % i=136
   res(i)= res(i)     +all(all( acf+bcs == acf+bcf ));  
   i=i+1 ;     % i=137
   res(i)= res(i)     +all(all( acs+bcf == acf+bcf ));  
   i=i+1 ;     % i=138
   res(i)= res(i)     +all(all( acs-bcs == acf-bcf ));  
   i=i+1 ;     % i=139
   res(i)= res(i)     +all(all( acf-bcs == acf-bcf ));  
   i=i+1 ;     % i=140
   res(i)= res(i)     +all(all( acs-bcf == acf-bcf ));  
   i=i+1 ;     % i=141
   res(i)= res(i)     +all(all( (acs>bcs) == (acf>bcf) ));  
   i=i+1 ;     % i=142
   res(i)= res(i)     +all(all( (acs<bcs) == (acf<bcf) ));  
   i=i+1 ;     % i=143
   res(i)= res(i)     +all(all( (acs!=bcs) == (acf!=bcf) ));  
   i=i+1 ;     % i=144
   res(i)= res(i)     +all(all( (acs>=bcs) == (acf>=bcf) ));  
   i=i+1 ;     % i=145
   res(i)= res(i)     +all(all( (acs<=bcs) == (acf<=bcf) ));  
   i=i+1 ;     % i=146
   res(i)= res(i)     +all(all( (acs==bcs) == (acf==bcf) ));  
   i=i+1 ;     % i=147
   res(i)= res(i)     +all(all( acs.*bcs == acf.*bcf ));  
   i=i+1 ;     % i=148
   res(i)= res(i)     +all(all( acf.*bcs == acf.*bcf ));  
   i=i+1 ;     % i=149
   res(i)= res(i)     +all(all( acs.*bcf == acf.*bcf ));  
   i=i+1 ;     % i=150
   res(i)= res(i)     +all(all( acs*ccs == acf*ccf ));  
   i=i+1 ;     % i=151
   res(i)= res(i)     +all(all( acf*ccs == acf*ccf ));  
   i=i+1 ;     % i=152
   res(i)= res(i)     +all(all( acs*ccf == acf*ccf ));  
   i=i+1 ;     % i=153

%
% sparse select operations
%
   %this is necessary until we get the orientations sorted
   r1= ars(sel1); r2=arf(sel1);
   res(i)= res(i)     +all( r1(:) == r2(:) );
%  res(i)= res(i)     +all( ars(sel1) == arf(sel1 ));
   i=i+1 ;     % i=154
   res(i)= res(i)     +all( ars(:) == arf(:));
   i=i+1 ;     % i=155
   res(i)= res(i)     +all(all( ars(sely,selx) == arf(sely,selx) ));
   i=i+1 ;     % i=156
   res(i)= res(i)     +all(all( ars( :  ,selx) == arf( :  ,selx) ));
   i=i+1 ;     % i=157
   res(i)= res(i)     +all(all( ars(sely, :  ) == arf(sely, :  ) ));
   i=i+1 ;     % i=158
   res(i)= res(i)     +all(all( ars(:,:) == arf(:,:) ));
   i=i+1 ;     % i=159

%
% sparse select operations
%
% TODO

%
% sparse LU and inverse
%
   mag = 1e-12;
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
   i=i+1 ;     % i=160
                                        
   if OCTAVE
      [Ls4,Us4,PsR,PsC] = splu( drs );
      res(i)= res(i) + ...
            all([ all(all(abs( PsR'*Ls4*Us4*PsC  - Pf4'*Lf4*Uf4 )<mag)) ;
                  all(all(abs( PsR'*Ls4*Us4*PsC  - drf )< mag)) ;
                  all(all( Ls4 .* LL == Ls4 )) ;
                  all(all( Us4 .* UU == Us4 )) ] );
   elseif 0
      [Ls4,Us4,Ps4] = lu( drs );
      res(i)= res(i) + ...
            all([ all(all(abs( Ps4'*Ls4*Us4 - Pf4'*Lf4*Uf4 )<mag)) ;
                  all(all(abs( Ps4'*Ls4*Us4 - drf )< mag)) ;
                  all(all( Ls4 .* LL == Ls4 )) ;
                  all(all( Us4 .* UU == Us4 )) ] );
   end

   i=i+1 ;     % i=161

%  [Ls4,Us4,PsR,PsC,p1,p2] = splu( drs );
if 0 % test code for old spinv
   [dsi,Ls4,Lt,iL,Us4,iUt,iU] = spinv( drs );
   mag= 1e-10;
   res(i)= res(i) + all( [ ...
           all(all( abs( inv(Ls4) - iL ) <= mag*(1+abs(inv(Ls4))) )),
           all(all( abs( inv(Us4) - iU ) <= mag*(1+abs(inv(Us4))) ))
           ]);
   if ~all(all( abs( inv(Ls4) - iL ) < mag*(1+abs(inv(Ls4))) ));
      printf('%d:L size=%d\n', tries, size(iU,1));
      keyboard
   end 
   if ~all(all( abs( inv(Us4) - iU ) < mag*(1+abs(inv(Us4))) ));
      printf('%d:U size=%d\n', tries, size(iU,1));
           abs( inv(Us4) - iU ) <= mag*(1+abs(inv(iU)))
      keyboard
   end 
endif #0   

   dsi = spinv( drs );
   mag= 1e-10;
   res(i)= res(i) + all(all( ...
           abs( inv(drf) - dsi ) <= mag*(1+abs(inv(drf))) ));
   i=i+1 ;     % i=162

   if OCTAVE
      res(i)= res(i)    +all( spfind(ars) == find(arf) );
      [I,J,S,N,M]= spfind(ars);
   else
      res(i)= res(i)    +all( find(ars) == find(arf) );
      [I,J,S]= find(ars);
      [N,M]  = size(ars);
   end
   i=i+1 ;     % i=163

   asnew= sparse(I,J,S,N,M);
   res(i)= res(i)    +all( all( asnew == ars ));
   i=i+1 ;     % i=164

%
% complex sparse LU and inverse
%
% TODO

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

% clear up variables - so dmalloc works
clear L* U* a* b* c* d* e* P*

%
% $Log$
% Revision 1.1  2001/10/10 19:54:49  pkienzle
% Initial revision
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
