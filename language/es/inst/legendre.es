md5="adc2e4ea385c3883a121fd85c57954e3";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{L} =} legendre (@var{n}, @var{X})

Funci@'on de Legendre de grado n y orden m donde se devuelven todos
los valores de m = 0.. @var{n}. @var{n} debe ser un escalar en el intervalo
[0 .. 255]. El valor de retorno tiene una dimensi@'on m@'as que @var{x}.

@example
la fuci@'on Legendre de grado n y ordem m.

@group
 m        m       2  m/2   d^m
P(x) = (-1) * (1-x  )    * ----  P (x)
 n                         dx^m   n
@end group

Con:
Polinomio Legendre de grado n

@group
          1     d^n   2    n
P (x) = ------ [----(x - 1)  ] 
 n      2^n n!  dx^n
@end group

legendre (3,[-1.0 -0.9 -0.8]) matriz de retorno

@group
 x  |   -1.0   |   -0.9   |  -0.8
------------------------------------
m=0 | -1.00000 | -0.47250 | -0.08000
m=1 |  0.00000 | -1.99420 | -1.98000
m=2 |  0.00000 | -2.56500 | -4.32000
m=3 |  0.00000 | -1.24229 | -3.24000 
@end group
@end example
@end deftypefn
