## Copyright (C) 2003 David Bateman
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} galois ('help')
## @deftypefnx {Function File} {} galois ('info')
## @deftypefnx {Function File} {} galois ('test')
## Manual and test code for the Galois Fields package for Octave. There are
## 3 possible ways to call this function.
##
## @table @code
## @item galois ('help')
## Display this help message. Called with no arguments, this function also
## displays this help message
## @item galois ('info')
## Open the Galois Fields Manual
## @item galois ('test')
## Run the test code for the Galois Fields code
## @end table
##
## Please note that this function file should be used as an example of the 
## use of this package.
## @end deftypefn
## @seealso{gf}

## PKG_ADD: mark_as_command galois
function retval = galois(a)

  infofile = 'comms.info';
  nodename = 'Galois Fields';
  m = 3;			## must be greater than 2
  
  if (nargin ~= 1)
    help ('galois');
  else
    if (strcmp(a,'help'))
      help ('galois');
    elseif (strcmp(a,'info'))
      infopaths = ['.'];
      if (!isempty(split(path,':')))
        infopaths =[infopaths; split(path,':')];
      end
      if (!isempty(split(DEFAULT_LOADPATH,':')))
        infopaths =[infopaths; split(DEFAULT_LOADPATH,':')];
      end
      for i=1:size(infopaths,1)
        infopath = deblank(infopaths(i,:));
        len = length(infopath);
        if (len)
          if (len > 1 && strcmp(infopath([len-1 len]),'//'))
            showfile = system(['find ' infopath(1:len-1) ' -name ' ...
                               infofile]);
          else
            showfile = system(['find ' infopath ' -name ' infofile ...
                               ' -maxdepth 1']);
          end
          if (length(showfile))
            break;
          end
        end
      end
      if (!exist('showfile') || !length(showfile))
        error('galois: info file not found');
      end
      
      if (exist('INFO_PROGAM')) 
        [testout testret] = system([INFO_PROGRAM ' --version']);
        if (testret)
          error('galois: info command not found');
        else
          system([INFO_PROGRAM ' --file ' infofile ' --node "' ...
                  nodename '"']); 
        end
      else
        [testout testret] = system('info --version');
        if (testret)
          error('galois: info command not found');
        else
          system(['info --file ' infofile ' --node "' nodename '"']); 
        end
      end
    elseif (strcmp(a,'test'))
      fprintf('Find primitive polynomials:               ')
      prims = primpoly(m,'all','nodisplay');
      for i=2^m:2^(m+1)-1
        if (find(prims == i))
          if (!isprimitive(i))
            error('Error in primitive polynomials');
          end
        else
          if (isprimitive(i))
            error('Error in primitive polynomials');
          end
        end
      end
      fprintf('PASSED\n');
      fprintf('Create Galois variables:                  ')
      n = 2^m-1;
      gempty = gf([],m);
      gzero = gf(0,m);
      gone = gf(1,m);
      gmax = gf(n,m);
      grow = gf(0:n,m);
      gcol = gf([0:n]',m);
      matlen = ceil(sqrt(2^m));
      gmat = gf(reshape(mod([0:matlen*matlen-1],2^m),matlen,matlen),m);
      fprintf('PASSED\n');
      fprintf('Access Galois structures:                 ')
      if (gcol.m ~= m || gcol.prim_poly ~= primpoly(m,'min', ...
                                                    'nodisplay'))
        error('FAILED');
      end
      fprintf('PASSED\n');
      fprintf('Miscellaneous functions:                  ')
      if (size(gmat) != [matlen matlen])
        error('FAILED');
      end
      if (length(grow) != 2^m)
        error('FAILED');
      end
      if (!any(grow) || all(grow) || any(gzero) || !all(gone))
        error('FAILED');
      end
      if (isempty(gone) || !isempty(gempty))
        error('FAILED');
      end
      tmp = gdiag(grow);
      if (size(tmp,1) ~= 2^m || size(tmp,2) ~= 2^m)
        error('FAILED');
      end
      for i=1:2^m
        for j=1:2^m
          if ((i == j) && (tmp(i,j) != grow(i)))
            error('FAILED');
          elseif ((i ~= j) && (tmp(i,j) ~= 0))
            error('FAILED');
          end
        end
      end
      tmp = gdiag(gmat);
      if (length(tmp) ~= matlen)
        error('FAILED');
      end
      for i=1:matlen
        if (gmat(i,i) ~= tmp(i))
          error('FAILED');
        end
      end          
      tmp = greshape(gmat,prod(size(gmat)),1);
      if (length(tmp) ~= prod(size(gmat)))
        error('FAILED');
      end
      fprintf('PASSED\n');
      fprintf('Unary operators:                          ')
      tmp = - grow;
      if (tmp ~= grow)
        error('FAILED');
      end
      tmp = !grow;
      if (tmp(1) ~= 1)
        error('FAILED');
      end
      if (any(tmp(2:length(tmp))))
        error('FAILED');
      end
      tmp = gmat';
      for i=1:size(gmat,1)
        for j=1:size(gmat,2)
          if (gmat(i,j) ~= tmp(j,i))
            error('FAILED');
          end
        end
      end
      fprintf('PASSED\n');
      fprintf('Arithmetic operators:                     ')
      if (any(gmat + gmat))
        error('FAILED');
      end         
      multbl = gcol * grow;
      elsqr = gcol .* gcol;
      elsqr2 = gcol .^ gf(2,m);
      for i=1:length(elsqr)
        if (elsqr(i) ~= multbl(i,i))
          error('FAILED');
        end         
      end
      for i=1:length(elsqr)
        if (elsqr(i) ~= elsqr2(i))
          error('FAILED');
        end         
      end
      tmp = grow(2:length(grow)) ./ gcol(2:length(gcol))';
      if (length(tmp) ~= n || any(tmp ~= ones(1,length(grow)-1)))
        error('FAILED');
      end         
      fprintf('PASSED\n');
      fprintf('Logical operators:                        ')
      if (grow(1) ~= gzero || grow(2) ~= gone || grow(2^m) ~= n)
        error('FAILED');
      end         
      if (!(grow(1) == gzero) || any(grow ~= gcol'))
        error('FAILED');
      end         
      fprintf('PASSED\n');

      fprintf('Polynomial manipulation:                  ')
      poly1 = gf([2 4 5 1],3);
      poly2 = gf([1 2],3);
      sumpoly = poly1 + [0 0 poly2];   ## Already test '+'
      mulpoly = conv(poly1, poly2);    ## multiplication
      poly3 = [poly remd] = deconv(mulpoly, poly2);
      if (!isequal(poly1,poly3))
        error('FAILED');
      end
      if (any(remd))
        error('FAILED');
      end         
      x0 = gf([0 1 2 3],3);
      y0 = polyval(poly1, x0);
      alph = gf(2,3);
      y1 = alph * x0.^3 + alph.^2 * x0.^2 + (alph.^2+1) *x0 + 1;
      if (!isequal(y0,y1))
        error('FAILED');
      end         
      roots1 = groots(poly1);
      ck1 = polyval(poly1, roots1);
      if (any(ck1))
        error('FAILED');
      end         
      b = minpol(alph);
      bpoly = bi2de(b.x,'left-msb');
      if (bpoly != alph.prim_poly)
        error('FAILED');
      end         
      c = cosets(3);
      c2 = c{2};
      mpol = minpol(c2(1));
      for i=2:length(c2)
        if (mpol != minpol(c2(i)))
          error('FAILED');
        end
       end
      fprintf('PASSED\n');

      fprintf('Linear Algebra:                           ')
      [l u p] = glu(gmat);
      if (any(l*u-p*gmat))       
        error('FAILED');
      end
      g1 = ginv(gmat);
      g2 = gmat ^ -1;
      if (any(g1*gmat != eye(matlen)))
        error('FAILED');
      end
      if (any(g1 != g2))
        error('FAILED');
      end
      matdet = 0;
      while (!matdet)
        granmat = gf(floor(2^m*rand(matlen)),m);
        matdet = gdet(granmat);
      end
      matrank = grank(granmat);
      smallcol = gf([0:matlen-1],m)';
      sol1 = granmat \ smallcol;
      sol2 = smallcol' / granmat;
      if (any(granmat * sol1 != smallcol))
        error('FAILED');
      end
      if (any(sol2 * granmat != smallcol'))
        error('FAILED');
      end
      fprintf('PASSED\n');
      fprintf('Signal Processing functions:              ')
      b = gf([1 0 0 1 0 1 0 1],m);
      a = gf([1 0 1 1],m);
      x = gf([1 zeros(1,99)],m);
      y0 = filter(b, a, x);
      y1 = gconv(grow+1, grow);
      y2 = grow * gconvmtx(grow+1, length(grow));
      if (any(y1 != y2))
        error('FAILED');
      end
      [y3 remd] = gdeconv(y2, grow+1);
      if (any(y3 != grow))
        error('FAILED');
      end
      if (any(remd))
        error('FAILED');
      end         
      alph = gf(2,m);
      x = gf(floor(2^m*rand(n,1)),m);
      fm = gdftmtx(alph);
      ifm = gdftmtx(1/alph);
      y0 = gfft(x);
      y1 = fm * x;
      if (any(y0 != y1))
        error('FAILED');
      end
      z0 = gifft(y0);
      z1 = ifm * y1;
      if (any(z0 != x))
        error('FAILED');
      end
      if (any(z1 != x))
        error('FAILED');
      end
      fprintf('PASSED\n');
    
      fprintf('Reed-Solomon Coding:                      ')
      ## Test for a CCSDS like coder, but without dual-basis translation
      mrs = 8;
      nrs = 2^mrs -1;
      krs = nrs - 32;
      prs = 391;
      fcr = 112;
      step = 11;
      
      ## CCSDS generator polynomial
      ggrs = rsgenpoly(nrs, krs, prs, fcr, step);

      ## Code two blocks
      msg = gf(floor(2^mrs*rand(2,krs)),mrs,prs);
      cde = rsenc(msg,nrs,krs,ggrs);
      
      ## Introduce errors
      noisy = cde + [ 255 0 255 0 255 zeros(1,250); 0 255 0 255 zeros(1,251)];
      
      # Decode (better to pass fcr and step rather than gg for speed)
      dec = rsdec(noisy,nrs,krs,fcr,step);
      
      if (any(dec != msg))
        error('FAILED');
      end         
      fprintf('PASSED\n');
      
    else
      usage('galois: Unknown argument');
    end
  end
 
endfunction
