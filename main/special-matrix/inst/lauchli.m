## Author: Paul Kienzle <pkienzle@users.sf.net>
## This program is granted to the public domain.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{a}} = lauchli (@var{n})
## @deftypefnx {Function File} {@var{a}} = lauchli (@var{n},@var{mu})
## Creates the matrix [ ones(1,@var{n}); @var{mu}*eye(@var{n}) ]
## The value @var{mu} defaults to sqrt(eps).
## This is an ill-conditioned system for testing the
## accuracy of the QR routine.
##
## @example
## @group
##       A = lauchli(15);
##       [Q, R] = qr(A);
##       norm(Q*R - A)
##       norm(Q'*Q - eye(rows(Q)))
## @end group
## @end example
## @end deftypefn
## @seealso {ones,zeros,eye}
## @end deftypefn

function A = lauchli(n,mu)
  if (nargin < 1 || nargin > 2)
    usage("A = lauchli(n [, mu])");
  endif

  if (nargin < 2), mu = sqrt(eps); endif

  A = [ ones(1,n); mu*eye(n) ];

endfunction
