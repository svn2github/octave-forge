## x = trisolve(d,e,b)
##
## Solves the symmetric positive definite tridiagonal system:
##
##  / d1 e1  0  . . .  0    0 \     / b11 b12 . . . b1k \
##  | e1 d2 e2  . . .  0    0 |     | b21 b22 . . . b2k |
##  |  0 e2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |
##  |           . . .         |     |         . . .     |
##  \  0  0  0  . . . en-1 dn /     \ bn1 bn2 . . . bnk /
##
## If the system is not positive definite, then use the following form.
##
## x = trisolve(l,d,u,b)
##
## Solves the tridiagonal system:
##
##  / d1 u1  0  . . .  0    0 \     / b11 b12 . . . b1k \
##  | l1 d2 u2  . . .  0    0 |     | b21 b22 . . . b2k |
##  |  0 l2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |
##  |           . . .         |     |         . . .     |
##  \  0  0  0  . . . ln-1 dn /     \ bn1 bn2 . . . bnk /
##
## x = trisolve(d,e,b,cl,cu)
##
## Solves the cyclic system with symmetric positive definite tridiagonal:
##
##  / d1 e1  0  . . .  0   cu \     / b11 b12 . . . b1k \
##  | e1 d2 e2  . . .  0    0 |     | b21 b22 . . . b2k |
##  |  0 e2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |
##  |           . . .         |     |         . . .     |
##  \ cl  0  0  . . . en-1 dn /     \ bn1 bn2 . . . bnk /
##
## If the system is not positive definite, then use the following form.
##
## x = trisolve(l,d,u,b,cl,cu)
##
## Solves the cyclic tridiagonal system:
##
##  / d1 u1  0  . . .  0   cu \     / b11 b12 . . . b1k \
##  | l1 d2 u2  . . .  0    0 |     | b21 b22 . . . b2k |
##  |  0 l2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |
##  |           . . .         |     |         . . .     |
##  \ cl  0  0  . . . ln-1 dn /     \ bn1 bn2 . . . bnk/
##
## Constructs a full matrix for the tridiagonal system and solves it.
## The compiled version in trisolve.cc uses tridiagonal solvers, and so
## will be much faster and more memory efficient.  Use this routine
## to verify the results of trisolve.cc or if you cannot use dynamically
## linked routines on your version of Octave.

## This program is granted to the public domain.

function x = trisolve(l, d, u, b, cl, cu)

  if (nargin == 3)
    b = u; u = d; d = l; l = u;
    cl = 0; cu = 0;
  elseif (nargin == 4)
    cl = 0; cu = 0;
  elseif (nargin == 5)
    cu = cl; cl = b; b = u; u = d; d = l; l = u;
  elseif (nargin ~= 6)
    usage ('x = trisolve ([l, ] d, u, b [, cl, cu])');
  end

  n = length(d);
  if any ( [ length(l)+1, length(u)+1, size(b,1) ] ~= n )
    error ('trisolve: incorrect arguments');
  else
    A = diag (l, -1) + diag (d) + diag (u, 1);
    A(n,1) = cl; A(1,n) = cu;
    x = A\b;
  end

endfunction
