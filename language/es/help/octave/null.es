md5="0015fda876ee396e0b8376f655daf8f7";rev="6288";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} null (@var{a}, @var{tol})
Retorna una base ortonormal del espacio nulo de @var{a}. 

La dimensi@'on del espacio nulo se toma como el n@'umero de valores @'unicos 
de @var{a} menores o iguales que @var{tol}. Si se omite el argumento @var{tol}, 
sa calcula de la siguiente forma 

@example
max (size (@var{a})) * max (svd (@var{a})) * eps
@end example
@end deftypefn
