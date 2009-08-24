md5="bbe8400992d788ad18503bc9eb7d21e0";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} arch_rnd (@var{a}, @var{b}, @var{t})
Simula una secuencia ARCH de longitud @var{t} con @var{b}
coeficientes AR y @var{a} coeficientes CH.  P.e., el resultado
@math{y(t)} sigue el modelo

@smallexample
y(t) = b(1) + b(2) * y(t-1) + @dots{} + b(lb) * y(t-lb+1) + e(t),
@end smallexample

@noindent
donde @math{e(t)}, dado @var{y} hasta el tiempo @math{t-1}, es
@math{N(0, h(t))}, con

@smallexample
h(t) = a(1) + a(2) * e(t-1)^2 + @dots{} + a(la) * e(t-la+1)^2
@end smallexample
@end deftypefn
