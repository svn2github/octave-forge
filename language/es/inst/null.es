md5="0015fda876ee396e0b8376f655daf8f7";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} null (@var{a}, @var{tol})
Retorna una base ortonormal del espacio nulo de @var{a}. 

La dimensión del espacio nulo se toma como el número de valores únicos 
de @var{a} menores o iguales que @var{tol}. Si se omite el argumento @var{tol}, 
sa calcula de la siguiente forma 

@example
max (size (@var{a})) * max (svd (@var{a})) * eps
@end example
@end deftypefn
