md5="aa3b2aae346f646a0ce3464f38caf8f4";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} orth (@var{a}, @var{tol})
Retorna una base ortonormal del espacio de rangos de @var{a}. 

La dimensión del espacio de rangos se toma como el número de valores 
únicos de @var{a} mayores que @var{tol}. Si se omite el argumentos @var{tol}, 
se calcula de la siguiente forma 

@example
max (size (@var{a})) * max (svd (@var{a})) * eps
@end example
@end deftypefn
