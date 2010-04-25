md5="8ded3cc2cbd491b6eeab96b50a4e5ed8";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} polyvalm (@var{c}, @var{x})
Evalua un polinomio en sentido matricial. 

La función @code{polyvalm (@var{c}, @var{x})} evalua el polinomio en 
sentido matricial, p.e. se usa la multiplicación de matrices en lugar 
de la multiplicación elemento por elemento usada en @code{polyval}.

El argumento @var{x} debe ser una matriz cuadrada. 
@seealso{polyval, poly, roots, conv, deconv, residue, filter,
polyderiv, and polyinteg}
@end deftypefn
