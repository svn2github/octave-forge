## test function for argument pass through version of fsolve

## Author: Paul Kienzle
## This program is public domain.

x_opt = [ 0.599054;
          2.395931;
          2.005014 ];

tol = 1.0e-5;

function retval = f (p, a, b, c, d)

  x = p(1);
  y = p(2);
  z = p(3);

  retval = zeros (3, 1);

  retval(1) = sin(x) + y**2 + log(z) + a;
  retval(2) = b*x + 2**y -z**3 + c;
  retval(3) = x + y + z + d;

end

[x, info] = fsolve ("f", [ 0.5, 2.0, 2.5 ], -7, 3, 1, -5);

val = f (x, -7, 3, 1, -5);

info_bad = (info != 1);
solution_bad = sum (abs (x - x_opt) > tol);
value_bad = sum (abs (val) > tol);

if (info_bad)
  printf ("info bad\n");
else
  printf ("info good\n");
endif

if (solution_bad)
  printf ("solution bad\n");
else
  printf ("solution good\n");
endif

if (value_bad)
  printf ("value bad\n");
else
  printf ("value good\n");
endif

