## w = rotparams (r)            - Inverse to rotv()
## 
## w    = rotparams(r)  is such that rotv(w)*r' == eye(3).
## 
## [v,a]=rotparams(r)   idem, with v (1 x 3) s.t. w == a*v.
## 
##     0 <= norm(w)==a <= pi
## 
##     :-O !!  Does not check if 'r' is a rotation matrix.
##
##  Ignores matrices with zero rows or with NaNs. (returns 0 for them)

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function [vstacked,astacked]=rotparams(rstacked)

N = size(rstacked,1)/3;

## ang = 0 ;
## if length(varargin),
##   if strcmp(varargin{1},'ang'),    ang = 1;  end
## end
ok = all( ! isnan(rstacked') ) & any( rstacked' ) ;
ok = min( reshape(ok,3,N) ) ;
ok = find(ok) ;
## keyboard
vstacked = zeros(N,3);
astacked = zeros(N,1);
for j = ok,
  r = rstacked(3*j-2:3*j,:);
  [v,f]=eig(r); f=diag(f);

  [m,i]=min(abs(real(f)-1));
  v=v(:,i);

  w=null(v');
  u=w(:,1);
  a = u'*r*u;
  if a<1,
    a = acos(u'*r*u);
  else
    a = 0;
  end
  ## Check orientation
  x=r*u;
  if v'*[0 -u(3) u(2); u(3) 0 -u(1);-u(2) u(1) 0]*x < 0,  v=-v; end 


  if nargout <= 1,   v = v*a; end
  vstacked(j,:) = -v';
  astacked(j) = a;
end
