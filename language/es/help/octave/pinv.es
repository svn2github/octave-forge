md5="28476365dfb2f94feb3bad27016e7b4e";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} pinv (@var{x}, @var{tol})
Retorna la pseudoinversa de @var{x}. Los valores singulares menores 
que @var{tol} se ignoran. 

Si se omite el segundo argumento, se asume que 

@example
tol = max (size (@var{x})) * sigma_max (@var{x}) * eps,
@end example

@noindent
donde @code{sigma_max (@var{x})} es el m@'aximo valor singular de @var{x}.
@end deftypefn
