##  ----    test_ellipj.m

# Test ellipj.cc
# 
#

printf(" u real scalar, m scalar:\n");
printf("   if m=0   sn(u,m) = sin(u), cn(u) = cos(u), dn(u) = 1 :\n");
printf("      u = pi/3\n");
m = 0.0;
u = pi/3;
[sn,cn,dn] = ellipj(u,m);
printf("      sn(%f,%f) = %f     sin(%f) = %f\n", u,m, sn, u, sin(u));
printf("      cn(%f,%f) = %f     cos(%f) = %f\n", u,m, cn, u, cos(u));
printf("      dn(%f,%f) = %f                 \n", u,m, dn);

printf("   if m=1   sn(u,m) = tanh(u), cn(u) = 1/cosh(u), dn(u) = 1/cosh(u) :\n");
printf("      u = log(2.):  sn = 3/5, cn =dn = 4/5\n");
m = 1.0;
u = log(2.);
[sn,cn,dn] = ellipj(u,m);
printf("      sn(%f,%f) = %f     tanh(%f) = %f\n", u,m, sn, u, tanh(u));
printf("      cn(%f,%f) = %f   1/cosh(%f) = %f\n", u,m, cn, u, 1/cosh(u));
printf("      dn(%f,%f) = %f                 \n", u,m, dn);

printf("-------------------------\n");
printf(" u pure imaginary, m scalar:\n");
printf("   if real(u)=0   sn(u,m) = 0 + I * sn(I*u,m')/cn(I*u,m'), m'=1-m\n");
printf("                  cn(u,m) = 1/cn( I*u, m')\n");
printf("                  dn(u,m) = dn( I*u, m')/cn( I*u, m')\n");
printf("      u = I * log(2.)  m=0\n");
m = 0.;
u = log(2.)*I;
[sn,cn,dn] = ellipj(u,m);
printf("      sn(%f + I %f,%f) = %f + I %f\n",
 real(u), imag(u),m, real(sn), imag(sn));
printf("      cn(%f + I %f,%f) = %f + I %f\n",
 real(u), imag(u),m, real(cn), imag(cn));
printf("      dn(%f + I %f,%f) = %f + I %f\n",
 real(u), imag(u),m, real(dn), imag(dn));

printf(" u complex, m scalar:\n");
printf("   m = (tan(pi/8.))^4\n");
m = (tan(pi/8.))^4
u = -1. + I * 0.;
[sn,cn,dn] = ellipj(u,m);
printf("   u = %f + I * %f\n", real(u), imag(u));
printf("         sn(u,m) = -0.8392965923 + 0. * I\n");
printf(" ellipj: sn(u,m) = %f + I %f\n", real(sn), imag(sn));

printf("         cn(u,m) =  0.5436738271 + 0. * I\n");
printf(" ellipj: cn(u,m) = %f + I %f\n", real(cn), imag(cn));

printf("         dn(u,m) =  0.9895776106 + 0. * I\n");
printf(" ellipj: dn(u,m) = %f + I %f\n", real(dn), imag(dn));

u = -0.2 + I * 0.4;
[sn,cn,dn] = ellipj(u,m);
printf("\n   u = %f + I * %f\n", real(u), imag(u));
printf("         sn(u,m) = -0.2152524522 + 0.402598347 * I\n");
printf(" ellipj: sn(u,m) = %f + I %f\n", real(sn), imag(sn));

printf("         cn(u,m) =  1.059453907 + 0.08179712295 * I\n");
printf(" ellipj: cn(u,m) = %f + I %f\n", real(cn), imag(cn));

printf("         dn(u,m) =  1.001705496 + 0.00254669712 * I\n");
printf(" ellipj: dn(u,m) = %f + I %f\n", real(dn), imag(dn));

u = 0.2 + I * 0.6;
[sn,cn,dn] = ellipj(u,m);
printf("\n   u = %f + I * %f\n", real(u), imag(u));
printf("         sn(u,m) = 0.2369100139 + 0.6246336356 * I\n");
printf(" ellipj: sn(u,m) = %f + I %f\n", real(sn), imag(sn));

printf("         cn(u,m) = 1.16200643 - 0.1273503824 * I\n");
printf(" ellipj: cn(u,m) = %f + I %f\n", real(cn), imag(cn));

printf("         dn(u,m) = 1.004913944 - 0.004334880912 * I\n");
printf(" ellipj: dn(u,m) = %f + I %f\n", real(dn), imag(dn));

u = 0.8 + I * 0.8;
[sn,cn,dn] = ellipj(u,m);
printf("\n   u = %f + I * %f\n", real(u), imag(u));
printf("         sn(u,m) = 0.9588386397 + 0.6107824358 * I\n");
printf(" ellipj: sn(u,m) = %f + I %f\n", real(sn), imag(sn));

printf("         cn(u,m) = 0.9245978896 - 0.6334016187 * I\n");
printf(" ellipj: cn(u,m) = %f + I %f\n", real(cn), imag(cn));

printf("         dn(u,m) = 0.9920785856 - 0.01737733806 * I\n");
printf(" ellipj: dn(u,m) = %f + I %f\n", real(dn), imag(dn));

output_precision = 5
printf("-------------------------\n");
printf(" u real column, m scalar:\n");
printf(" u = [ 0., pi/6, pi/4, pi/2]\n");
u = [ 0., pi/6, pi/4, pi/2]
m = 0.
[sn, cn, dn] = ellipj(u,m)

printf("-------------------------\n");
printf(" u complex column, m scalar:\n");
printf(" u = [ 2*I, 6.+3*I, -4, I/2]\n");
u = [ 2*I, 6.+3*I, -4, I/2]
m = 0.
[sn, cn, dn] = ellipj(u,m)

printf("-------------------------\n");
printf(" u real scalar, m row:\n");
u = 10
m = [ 0., 0.3, 0.45, 0.77]
[sn, cn, dn] = ellipj(u,m)

printf("-------------------------\n");
printf(" u complex scalar, m row:\n");
u = 1.5+2.3*I
m = [ 0., 0.23, 0.345, 0.477]
[sn, cn, dn] = ellipj(u,m)

if 0
printf("-------------------------\n");
printf(" u real column, m row:\n");
u = [ 1.; 2.3; 0.545]
m = [ 0., 0.3, 0.5, 0.77]
[sn, cn, dn] = ellipj(u,m)

printf("-------------------------\n");
printf(" u complex column, m row:\n");
u = [ 1+2*I; 3+4*I; 5+6*I; 7+8*I; 9+10*I]
m = [ 0., 0.3, 0.45, 0.77]
[sn, cn, dn] = ellipj(u,m)
endif

printf("-------------------------\n");
printf(" u real matrix, m matrix:\n");
u = [ 1, 2.2, 3.3; 4.4, 5.5, 6.6]
m = [ 0.1, 0.22, 0.33; 0.44, 0.55, 0.66]
[sn, cn, dn] = ellipj(u,m)


printf("-------------------------\n");
printf(" u complex matrix, m matrix:\n");
u = [ 1, 2.2, 3.3; 4.4, 5.5, 6.6];
m = [ 0.1, 0.22, 0.33; 0.44, 0.55, 0.66]
u = u + m*I
[sn, cn, dn] = ellipj(u,m)

