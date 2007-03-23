## Copyright (C) 2001 David Billinghurst
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## usage: [sn,cn,dn] = ellipj(u,m[,tol])
##
## Compute the Jacobi elliptic functions sn(u|m), cn(u|m) and dn(u|m)
## for complex argument u and parameter 0 <= m <= 1.
##
## WARNING: the approximation blows up for abs(u)>20 near m=1.
##
## tol is accepted for compatibility, but ignored
##
## Ref: Abramowitz, Milton and Stegun, Irene A
##      Handbook of Mathematical Functions, Dover, 1965
##      Chapter 16 (Sections 16.4, 16.13 and 16.15)
##
## Example
##    m = linspace(0,1,200); u=linspace(-10,10,200);
##    [U,M] = meshgrid(u,m);
##    [sn, cn, dn] = ellipj(U,M);
##    imagesc(sn);
##
## See also: ellipke

## Author: David Billinghurst <David.Billinghurst@riotinto.com>
## 2001-01-31 David Billinghurst <David.Billinghusrt@riotinto.com>
##   * initial revision
## 2001-02-01 Paul Kienzle <pkienzle@users.sf.net>
##   * vectorized
##   * added demos
##   * included function name in error messages
## 2001-12-15 Leopoldo Cerbaro <redbliss@libero.it>
##   * support for complex u

function [sn, cn, dn] = ellipj (u, m)

  if nargin < 2 || nargin > 3 
    usage("[sn, cn, dn] = ellipj (u, m)"); 
  endif
  [err, u, m] = common_size(u,m);
  if any(size(m) != size(u))
    error("ellipj m and u must have the same shape");
  endif
  if is_complex(m) || any(m(:) < 0.0 | m(:) > 1.0)
    error("ellipj must have m in the range [0,1]");
  endif

  sn=cn=dn=zeros(size(u));
  if (is_complex(u))
    m1 = 1.0-m;

    ## u is pure imaginary: Jacoby imag. transf.
    idx = (real(u) == 0. & imag(u) != 0.);
    [ss1,cc1,dd1] = ellipj( imag(u(idx)), m1(idx));
    sn(idx) = 1i * ss1./cc1; 
    cn(idx) = 1./cc1;
    dn(idx) = dd1./cc1;
    
    ## u is pure real
    idx = (imag(u) == 0.);
    [ss,cc,dd] = ellipj( real(u(idx)), m(idx));
    sn(idx) = ss;
    cn(idx) = cc;
    dn(idx) = dd;

    ## u is generic complex
    idx = (real(u) != 0. & imag(u) != 0.);
    [ss1,cc1,dd1] = ellipj( imag(u(idx)), m1(idx));
    [ss,cc,dd] = ellipj( real(u(idx)), m(idx));
    ddd = cc1.^2 + m(idx).*(ss.^2).*(ss1.^2);
    sn(idx) = (ss.*dd1 + 1i*cc.*dd.*ss1.*cc1)./ddd; 
    cn(idx) = (cc.*cc1 - 1i*ss.*dd.*ss1.*dd1)./ddd;
    dn(idx) = (dd.*cc1.*dd1 - 1i*m(idx).*ss.*cc.*ss1)./ddd;
    return
  endif

  lo = sqrt(eps);
  hi = 1-sqrt(eps);

  ## For small m, ( Abramowitz and Stegun, Section 16.13 )
  idx = ( m < lo );
  if any(idx(:))
    uidx = u(idx)(:);
    midx = m(idx)(:);
    sin_u = sin(uidx);
    cos_u = cos(uidx);
    t = 0.25 * midx .* (uidx - sin_u.*cos_u);
    sn(idx) = sin_u - t.*cos_u;
    cn(idx) = cos_u + t.*sin_u;
    dn(idx) = 1.0 - 0.5*midx.*sin_u.*sin_u;
  endif
    
  ## For m1 = (1-m) small ( Abramowitz and Stegun, Section 16.15 )
  idx = ( m > hi );
  if any(idx(:))
    uidx = u(idx)(:);
    midx = m(idx)(:);
    sinh_u = sinh(uidx);
    cosh_u = cosh(uidx);
    tanh_u = tanh(uidx);
    sech_u = 1.0./cosh_u;
    sechm1over4 = 0.25 * (1.0 - midx) ./ cosh_u;
    sinhcosh = sinh_u.*cosh_u;
    sn(idx) = tanh_u + sechm1over4 .* (sinhcosh-uidx) .* sech_u;
    cn(idx) = sech_u - sechm1over4 .* (sinhcosh-uidx) .* tanh_u;
    dn(idx) = sech_u + sechm1over4 .* (sinhcosh+uidx) .* tanh_u;
  endif
    
  ## Arithmetic-Geometric Mean (AGM) algorithm
  ## ( Abramowitz and Stegun, Section 16.4 )
  idx = ( lo <= m & m <= hi );
  if any(idx(:))
    uidx = u(idx)(:);
    midx = m(idx)(:);
    Nmax = 16;
    c = a = zeros(sum(idx(:)),Nmax);
    a(:,1) = ones(sum(idx(:)),1);
    b = sqrt(1.0 - midx);
    c(:,1) = sqrt(midx);
    for n = 2:Nmax
      a(:,n) = (a(:,n-1) + b) / 2.0;
      c(:,n) = (a(:,n-1) - b) / 2.0;
      b = sqrt ( a(:,n-1) .* b);
      if all (c(:,n)./a(:,n) < eps), break; endif
    endfor
    if n >= Nmax
      error("ellipj: Not enough workspace"); 
    endif
    phi = 2.^(n-1) * a(:,n) .* uidx;
    for j=n:-1:2
      t = phi;
      phi = ( asin ( (c(:,j)./a(:,j)) .* sin(phi)) + phi ) / 2;
    endfor
      
    sn(idx) = sin(phi);
    cn(idx) = cos(phi);
    dn(idx) = cos(phi)./cos(t-phi);
  endif
endfunction

%!demo
%! N = 150;
%! % m = [1-logspace(0,log(eps),N-1), 1]; ## m near 1
%! % m = [0, logspace(log(eps),0,N-1)];   ## m near 0
%!   m = linspace(0,1,N);                 ## m equally spaced
%! u = linspace(-20,20,N);
%! M = ones(length(u),1) * m;
%! U = u' * ones(1, length(m));
%! [sn, cn, dn] = ellipj(U,M);
%! c = colormap; colormap(hot(64)); 
%! image(m,u,32*clip(sn,[-1,1])+32,1); 
%! image(m,u,32*clip(cn,[-1,1])+32,1); 
%! image(m,u,32*clip(dn,[-1,1])+32,1);
%! colormap(c);

%!demo
%! N = 200;
%! % m = [1-logspace(0,log(eps),N-1), 1]; ## m near 1
%! % m = [0, logspace(log(eps),0,N-1)];   ## m near 0
%!   m = linspace(0,1,N);                 ## m equally spaced
%! u = linspace(0,20,5);
%! M = ones(length(u),1) * m;
%! U = u' * ones(1, length(m));
%! [sn, cn, dn] = ellipj(U,M);
%! grid("on"); 
%! subplot(131); title("sn"); semilogx(m, sn, ";;");
%! subplot(132); title("cn"); semilogx(m, cn, ";;");
%! subplot(133); title("dn"); semilogx(m, dn, ";;");
%! oneplot; grid("off"); title("");

%!test
%! ## Test Jacobi elliptic functions
%! ## against "exact" solution from Mathematica 3.0
%! ## David Billinghurst <David.Billinghurst@riotinto.com>
%! ## 1 February 2001
%! u = [ 0.25; 0.25; 0.20; 0.20; 0.672; 0.5];
%! m = [ 0.0;  1.0;  0.19; 0.81; 0.36;  0.9999999999];
%! S = [ sin(0.25); tanh(0.25);
%!  0.19842311013970879516;
%!  0.19762082367187648571;
%!  0.6095196917919021945;
%!  0.4621171572617320908 ];
%! C = [ cos(0.25); sech(0.25);
%!  0.9801164570409401062;
%!  0.9802785369736752032;
%!  0.7927709286533560550;
%!  0.8868188839691764094 ];
%! D = [ 1.0;  sech(0.25);
%!  0.9962526643271134302;
%!  0.9840560289645665155;
%!  0.9307281387786906491;
%!  0.8868188839812167635 ];
%! [sn,cn,dn] = ellipj(u,m);
%! assert(sn,S,8*eps);
%! assert(cn,C,8*eps);
%! assert(dn,D,8*eps);
