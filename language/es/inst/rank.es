md5="b93362807a4e274ccea756d8a62b4170";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} rank (@var{a}, @var{tol})
Calcula el rango de @var{a} usando la factorizaci@'on de valor 
singular. El rango es el n@'umero de valores singulares @var{a} que 
son mayores que la tolerancia especificada @var{tol}. Si se omite 
el segundo argumento, se asume que es 

@example
tol = max (size (@var{a})) * sigma(1) * eps;
@end example

@noindent
donde @code{eps} es la precisi@'on de la m@'aquina y @code{sigma(1)} es 
el valor singular m@'as grande de @var{a}.
@end deftypefn
